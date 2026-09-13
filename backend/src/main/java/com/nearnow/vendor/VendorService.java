package com.nearnow.vendor;

import com.nearnow.auth.User;
import com.nearnow.auth.UserRepository;
import com.nearnow.common.exception.InvalidOperationException;
import com.nearnow.common.exception.ResourceNotFoundException;
import com.nearnow.order.Order;
import com.nearnow.order.OrderItem;
import com.nearnow.order.OrderRepository;
import com.nearnow.product.Product;
import com.nearnow.product.ProductRepository;
import com.nearnow.warehouse.StockLevelRepository;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Caching;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

/**
 * Vendor business rules and ownership checks.
 *
 * A vendor can only mutate products whose Product.vendor points at the
 * authenticated vendor. A warehouse-managed product keeps StockLevel as
 * the inventory source of truth, so the vendor may change price but cannot
 * overwrite physical stock through the product row.
 */
@Service
public class VendorService {

    private final VendorRepository vendorRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;
    private final OrderRepository orderRepository;
    private final StockLevelRepository stockLevelRepository;
    private final PurchaseOrderRepository purchaseOrderRepository;

    public VendorService(VendorRepository vendorRepository,
                         UserRepository userRepository,
                         ProductRepository productRepository,
                         OrderRepository orderRepository,
                         StockLevelRepository stockLevelRepository, PurchaseOrderRepository purchaseOrderRepository) {
        this.vendorRepository = vendorRepository;
        this.userRepository = userRepository;
        this.productRepository = productRepository;
        this.orderRepository = orderRepository;
        this.stockLevelRepository = stockLevelRepository;
        this.purchaseOrderRepository = purchaseOrderRepository;
    }

    @Transactional(readOnly = true)
    public VendorResponseDTO getProfile(String email) {
        return toVendorDTO(getVendor(email));
    }

    @Transactional
    public VendorResponseDTO updateProfile(String email, VendorProfileRequestDTO request) {
        Vendor vendor = getVendor(email);
        vendor.setBusinessName(request.getBusinessName());
        vendor.setBusinessAddress(request.getBusinessAddress());
        vendor.setGstNumber(request.getGstNumber());
        return toVendorDTO(vendorRepository.save(vendor));
    }

    @Transactional(readOnly = true)
    public List<VendorProductResponseDTO> getProducts(String email) {
        Vendor vendor = getVendor(email);
        return productRepository.findByVendorIdOrderByNameAsc(vendor.getId())
                .stream()
                .map(this::toProductDTO)
                .toList();
    }

    @Transactional
    @Caching(evict = {
            @CacheEvict(value = "products", key = "#productId"),
            @CacheEvict(value = "products", key = "'featured'")
    })
    public VendorProductResponseDTO updateProduct(String email, Long productId, VendorProductUpdateRequestDTO request) {
        Vendor vendor = getVendor(email);
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new ResourceNotFoundException("Product not found: " + productId));

        assertOwnsProduct(vendor, product);

        if (!product.isActive()) {
            throw new InvalidOperationException("Product is inactive. Reactivate it through the admin workflow.");
        }
        if (request.getSalePrice().compareTo(request.getPrice()) > 0
                && request.getSalePrice().compareTo(BigDecimal.ZERO) > 0) {
            throw new InvalidOperationException("Sale price cannot be greater than product price");
        }

        product.setPrice(request.getPrice());
        product.setSalePrice(request.getSalePrice());

        // If warehouse rows exist, StockLevel is authoritative. Allowing a
        // vendor to mutate Product.stock here would create two competing
        // sources of truth and could silently undo warehouse adjustments.
        if (stockLevelRepository.existsByProductId(productId)) {
            if (request.getStock() != product.getStock()) {
                throw new InvalidOperationException(
                        "This product is warehouse-managed. Update stock through the warehouse stock endpoint."
                );
            }
        } else {
            product.setStock(request.getStock());
        }

        Product saved = productRepository.save(product);
        return toProductDTO(saved);
    }

    @Transactional(readOnly = true)
    public List<PurchaseOrderResponseDTO> getPurchaseOrders(String email) {
        Vendor vendor = getVendor(email);
        return purchaseOrderRepository.findByVendorIdOrderByCreatedAtDesc(vendor.getId())
                .stream().map(this::toPurchaseOrderDTO).toList();
    }

    @Transactional
    public PurchaseOrderResponseDTO acceptPurchaseOrder(String email, Long poId) {
        Vendor vendor = getVendor(email);
        PurchaseOrder po = getOwnedPurchaseOrder(vendor, poId);
        if (po.getStatus() != PurchaseOrderStatus.PENDING) {
            throw new InvalidOperationException("Only a pending purchase order can be accepted");
        }
        po.setStatus(PurchaseOrderStatus.ACCEPTED);
        return toPurchaseOrderDTO(purchaseOrderRepository.save(po));
    }

    @Transactional
    public PurchaseOrderResponseDTO rejectPurchaseOrder(String email, Long poId) {
        Vendor vendor = getVendor(email);
        PurchaseOrder po = getOwnedPurchaseOrder(vendor, poId);
        if (po.getStatus() != PurchaseOrderStatus.PENDING) {
            throw new InvalidOperationException("Only a pending purchase order can be rejected");
        }
        po.setStatus(PurchaseOrderStatus.REJECTED);
        return toPurchaseOrderDTO(purchaseOrderRepository.save(po));
    }

    /**
     * The vendor's delivery-challan submission — marks the PO as shipped.
     * Only allowed from ACCEPTED, so a vendor can't dispatch stock they
     * never confirmed they had.
     */
    @Transactional
    public PurchaseOrderResponseDTO dispatchPurchaseOrder(String email, Long poId, DispatchPurchaseOrderRequestDTO request) {
        Vendor vendor = getVendor(email);
        PurchaseOrder po = getOwnedPurchaseOrder(vendor, poId);
        if (po.getStatus() != PurchaseOrderStatus.ACCEPTED) {
            throw new InvalidOperationException("Purchase order must be accepted before it can be dispatched");
        }
        po.setVehicleNumber(request.getVehicleNumber());
        po.setDriverName(request.getDriverName());
        po.setDriverPhone(request.getDriverPhone());
        po.setStatus(PurchaseOrderStatus.DISPATCHED);
        return toPurchaseOrderDTO(purchaseOrderRepository.save(po));
    }

    private PurchaseOrder getOwnedPurchaseOrder(Vendor vendor, Long poId) {
        PurchaseOrder po = purchaseOrderRepository.findById(poId)
                .orElseThrow(() -> new ResourceNotFoundException("Purchase order not found"));
        if (!po.getVendor().getId().equals(vendor.getId())) {
            throw new ResourceNotFoundException("Purchase order not found");
        }
        return po;
    }

    private PurchaseOrderResponseDTO toPurchaseOrderDTO(PurchaseOrder po) {
        return new PurchaseOrderResponseDTO(
                po.getId(), po.getProduct().getId(), po.getProduct().getName(),
                po.getStore().getId(), po.getStore().getName(),
                po.getQuantity(), po.getNote(), po.getStatus(),
                po.getVehicleNumber(), po.getDriverName(), po.getDriverPhone(),
                po.getCreatedAt()
        );
    }

    @Transactional(readOnly = true)
    public Page<VendorOrderResponseDTO> getOrders(String email, Pageable pageable) {
        Vendor vendor = getVendor(email);
        return orderRepository.findDistinctOrdersContainingVendor(vendor.getId(), pageable)
                .map(order -> toVendorOrderDTO(order, vendor.getId()));
    }

    private Vendor getVendor(String email) {
        Vendor vendor = vendorRepository.findByUserEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Vendor profile not found"));
        if (!vendor.isActive()) {
            throw new InvalidOperationException("Vendor account is inactive");
        }
        return vendor;
    }

    private void assertOwnsProduct(Vendor vendor, Product product) {
        if (product.getVendor() == null
                || !product.getVendor().getId().equals(vendor.getId())) {
            throw new ResourceNotFoundException("Product not found: " + product.getId());
        }
    }

    private VendorProductResponseDTO toProductDTO(Product product) {
        return new VendorProductResponseDTO(
                product.getId(),
                product.getName(),
                product.getBarcode(),
                product.getPrice(),
                product.getSalePrice(),
                product.getStock(),
                stockLevelRepository.existsByProductId(product.getId()),
                product.isActive()
        );
    }

    private VendorOrderResponseDTO toVendorOrderDTO(Order order, Long vendorId) {
        List<VendorOrderItemResponseDTO> items = order.getItems().stream()
                .filter(item -> item.getProduct() != null
                        && item.getProduct().getVendor() != null
                        && item.getProduct().getVendor().getId().equals(vendorId))
                .map(this::toVendorOrderItemDTO)
                .toList();

        return new VendorOrderResponseDTO(order.getId(), order.getStatus(), order.getCreatedAt(), items);
    }

    private VendorOrderItemResponseDTO toVendorOrderItemDTO(OrderItem item) {
        return new VendorOrderItemResponseDTO(
                item.getProduct().getId(),
                item.getName(),
                item.getPrice(),
                item.getQuantity(),
                item.getItemTotal()
        );
    }

    private VendorResponseDTO toVendorDTO(Vendor vendor) {
        User user = vendor.getUser();
        return new VendorResponseDTO(
                vendor.getId(),
                user.getId(),
                user.getEmail(),
                vendor.getBusinessName(),
                vendor.getBusinessAddress(),
                vendor.getGstNumber(),
                vendor.isActive()
        );
    }
}
