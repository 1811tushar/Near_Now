package com.nearnow.ai.automation;

import java.time.LocalDate;

public interface DailyDemandRow {
    Long getStoreId();
    Long getProductId();
    LocalDate getDay();
    long getQuantity();
}
