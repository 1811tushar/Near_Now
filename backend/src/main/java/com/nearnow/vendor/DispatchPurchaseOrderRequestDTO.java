package com.nearnow.vendor;

import jakarta.validation.constraints.NotBlank;

/**
 * The vendor's delivery-challan / consignment-note details, submitted
 * when they dispatch stock against an ACCEPTED purchase order.
 */
public class DispatchPurchaseOrderRequestDTO {

    @NotBlank
    private String vehicleNumber;

    @NotBlank
    private String driverName;

    @NotBlank
    private String driverPhone;

    public DispatchPurchaseOrderRequestDTO() {
    }

    public String getVehicleNumber() { return vehicleNumber; }
    public void setVehicleNumber(String vehicleNumber) { this.vehicleNumber = vehicleNumber; }

    public String getDriverName() { return driverName; }
    public void setDriverName(String driverName) { this.driverName = driverName; }

    public String getDriverPhone() { return driverPhone; }
    public void setDriverPhone(String driverPhone) { this.driverPhone = driverPhone; }
}
