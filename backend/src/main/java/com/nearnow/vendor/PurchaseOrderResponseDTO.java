package com.nearnow.vendor;

import java.time.Instant;

public class PurchaseOrderResponseDTO {

    private final Long id;
    private final Long productId;
    private final String productName;
    private final Long storeId;
    private final String storeName;
    private final int quantity;
    private final String note;
    private final PurchaseOrderStatus status;
    private final String vehicleNumber;
    private final String driverName;
    private final String driverPhone;
    private final Instant createdAt;

    public PurchaseOrderResponseDTO(Long id, Long productId, String productName,
                                     Long storeId, String storeName, int quantity,
                                     String note, PurchaseOrderStatus status,
                                     String vehicleNumber, String driverName, String driverPhone,
                                     Instant createdAt) {
        this.id = id;
        this.productId = productId;
        this.productName = productName;
        this.storeId = storeId;
        this.storeName = storeName;
        this.quantity = quantity;
        this.note = note;
        this.status = status;
        this.vehicleNumber = vehicleNumber;
        this.driverName = driverName;
        this.driverPhone = driverPhone;
        this.createdAt = createdAt;
    }

    public Long getId() { return id; }
    public Long getProductId() { return productId; }
    public String getProductName() { return productName; }
    public Long getStoreId() { return storeId; }
    public String getStoreName() { return storeName; }
    public int getQuantity() { return quantity; }
    public String getNote() { return note; }
    public PurchaseOrderStatus getStatus() { return status; }
    public String getVehicleNumber() { return vehicleNumber; }
    public String getDriverName() { return driverName; }
    public String getDriverPhone() { return driverPhone; }
    public Instant getCreatedAt() { return createdAt; }
}
