package com.nearnow.vendor;

import com.nearnow.product.Product;
import com.nearnow.warehouse.Store;
import jakarta.persistence.*;

import java.time.Instant;

/**
 * A restock order the SYSTEM raises against a vendor for a specific
 * store, once that store's stock for a product drops below its
 * configured reorder threshold (see StockLevel.reorderThreshold).
 *
 * This replaces the old vendor-initiated RestockRequest. Real
 * quick-commerce platforms (Blinkit-style) run a first-party (1P)
 * inventory model: the platform decides what to reorder and when —
 * vendors only fulfill what's asked, they don't propose it themselves.
 *
 * Lifecycle: PENDING (system-created, threshold breach) -> ACCEPTED
 * (vendor confirms they can supply it) -> DISPATCHED (vendor ships,
 * filling in the delivery-challan fields below) -> RECEIVED (warehouse
 * scans/verifies the delivery, stock is credited) — or REJECTED at the
 * PENDING stage if the vendor genuinely can't fulfill it.
 */
@Entity
@Table(name = "purchase_orders")
public class PurchaseOrder {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "vendor_id", nullable = false)
    private Vendor vendor;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "store_id", nullable = false)
    private Store store;

    @Column(nullable = false)
    private int quantity;

    @Column(length = 1000)
    private String note;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PurchaseOrderStatus status = PurchaseOrderStatus.PENDING;

    // Delivery-challan / consignment-note fields — filled in by the
    // vendor when they dispatch the order (status -> DISPATCHED).
    private String vehicleNumber;
    private String driverName;
    private String driverPhone;

    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    protected PurchaseOrder() {
    }

    public PurchaseOrder(Vendor vendor, Product product, Store store, int quantity, String note) {
        this.vendor = vendor;
        this.product = product;
        this.store = store;
        this.quantity = quantity;
        this.note = note;
    }

    @PrePersist
    protected void onCreate() {
        createdAt = Instant.now();
    }

    public Long getId() { return id; }
    public Vendor getVendor() { return vendor; }
    public Product getProduct() { return product; }
    public Store getStore() { return store; }
    public int getQuantity() { return quantity; }
    public String getNote() { return note; }
    public PurchaseOrderStatus getStatus() { return status; }
    public String getVehicleNumber() { return vehicleNumber; }
    public String getDriverName() { return driverName; }
    public String getDriverPhone() { return driverPhone; }
    public Instant getCreatedAt() { return createdAt; }

    public void setStatus(PurchaseOrderStatus status) { this.status = status; }
    public void setVehicleNumber(String vehicleNumber) { this.vehicleNumber = vehicleNumber; }
    public void setDriverName(String driverName) { this.driverName = driverName; }
    public void setDriverPhone(String driverPhone) { this.driverPhone = driverPhone; }
}
