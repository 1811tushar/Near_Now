package com.nearnow.warehouse;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

/**
 * What the warehouse manager submits after physically scanning/counting
 * a delivery against a DISPATCHED purchase order. receivedQuantity can
 * differ from the PO's requested quantity (e.g. a partial or damaged
 * delivery) — whatever number is entered here is what gets credited to
 * StockLevel, not the originally-requested quantity.
 */
public class ReceivePurchaseOrderRequestDTO {

    @NotNull
    @Min(0)
    private Integer receivedQuantity;

    public ReceivePurchaseOrderRequestDTO() {
    }

    public Integer getReceivedQuantity() { return receivedQuantity; }
    public void setReceivedQuantity(Integer receivedQuantity) { this.receivedQuantity = receivedQuantity; }
}
