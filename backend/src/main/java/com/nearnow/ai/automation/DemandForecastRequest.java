package com.nearnow.ai.automation;

import java.util.List;

public record DemandForecastRequest(
        List<DemandSeries> series,
        String method,
        int window
) {}
