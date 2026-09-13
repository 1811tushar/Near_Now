package com.nearnow.aiagent.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

public final class AiDtos {
    private AiDtos() {}

    public record FraudCaseResponse(Long id, Long orderId, String recommendation, double confidence,
                                    String reasoning, List<String> evidence, boolean requiresHumanApproval,
                                    String status) {}

    public record VendorReviewResponse(Long id, Long vendorId, String recommendation, double confidence,
                                       String reasoning, List<String> evidence, boolean requiresHumanApproval,
                                       boolean businessRulePass, String status) {}

    public record VendorReviewInput(String businessName, String businessAddress, String gstNumber,
                                    java.util.Map<String,Object> documentFields) {}

    public record OrderInvestigation(Long orderId, Long userId, BigDecimal totalAmount, String status,
                                     Instant createdAt, List<Long> vendorIds) {}
}
