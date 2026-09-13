package com.nearnow.warehouse;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

/**
 * Admin-set reorder threshold for one store+product combination. When
 * StockLevel.quantity for that pair drops below this number, the system
 * auto-generates a PurchaseOrder to the product's assigned vendor.
 * threshold = 0 means "auto-restock disabled" for this store+product.
 */
public class ThresholdUpdateRequestDTO {

    @NotNull
    @Min(0)
    private Integer threshold;

    public ThresholdUpdateRequestDTO() {
    }

    public Integer getThreshold() { return threshold; }
    public void setThreshold(Integer threshold) { this.threshold = threshold; }
}
