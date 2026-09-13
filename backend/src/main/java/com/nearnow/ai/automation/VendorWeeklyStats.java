package com.nearnow.ai.automation;

import com.fasterxml.jackson.annotation.JsonProperty;

public record VendorWeeklyStats(
        @JsonProperty("vendor_id") Long vendorId,
        @JsonProperty("vendor_name") String vendorName,
        @JsonProperty("week_start") String weekStart,
        @JsonProperty("week_end") String weekEnd,
        @JsonProperty("orders_containing_vendor_products") long ordersContainingVendorProducts,
        @JsonProperty("orders_fulfilled") long ordersFulfilled,
        @JsonProperty("orders_cancelled") long ordersCancelled,
        @JsonProperty("purchase_orders_created") long purchaseOrdersCreated,
        @JsonProperty("purchase_orders_accepted") long purchaseOrdersAccepted,
        @JsonProperty("purchase_orders_dispatched") long purchaseOrdersDispatched,
        @JsonProperty("purchase_orders_received") long purchaseOrdersReceived,
        @JsonProperty("purchase_orders_rejected") long purchaseOrdersRejected
) {}
