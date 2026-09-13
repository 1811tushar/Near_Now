package com.nearnow.vendor;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.time.Instant;

public interface PurchaseOrderRepository extends JpaRepository<PurchaseOrder, Long> {

    List<PurchaseOrder> findByVendorIdOrderByCreatedAtDesc(Long vendorId);

    List<PurchaseOrder> findByStoreIdOrderByCreatedAtDesc(Long storeId);

    /**
     * Used to avoid raising a second PENDING purchase order for the same
     * store+product while one is already in flight (PENDING/ACCEPTED/
     * DISPATCHED) — prevents duplicate auto-generated POs from stacking
     * up every time stock dips further below the threshold.
     */
    boolean existsByStoreIdAndProductIdAndStatusIn(Long storeId, Long productId, List<PurchaseOrderStatus> statuses);
    long countByVendorIdAndCreatedAtBetween(Long vendorId, Instant start, Instant end);

    long countByVendorIdAndStatusAndCreatedAtBetween(
            Long vendorId, PurchaseOrderStatus status, Instant start, Instant end);

}
