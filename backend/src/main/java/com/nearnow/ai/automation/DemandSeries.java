package com.nearnow.ai.automation;

import java.util.List;

public record DemandSeries(
        Long store_id,
        Long product_id,
        int current_stock,
        int current_threshold,
        List<DemandPoint> daily_demand
) {}
