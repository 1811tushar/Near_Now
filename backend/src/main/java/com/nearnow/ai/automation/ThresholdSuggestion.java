package com.nearnow.ai.automation;

public record ThresholdSuggestion(
        Long store_id,
        Long product_id,
        int suggested_threshold,
        double average_daily_demand,
        double forecast_daily_demand
) {}
