package com.nearnow.aiagent.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nearnow.ai.AiServiceClient;
import com.nearnow.aiagent.entity.FraudReviewCase;
import com.nearnow.aiagent.repository.FraudReviewCaseRepository;
import com.nearnow.order.Order;
import com.nearnow.order.OrderRepository;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.*;

@Service
public class FraudScreeningService {
    private static final BigDecimal AMOUNT_THRESHOLD = new BigDecimal("5000");
    private final OrderRepository orders; private final AiServiceClient ai; private final FraudReviewCaseRepository cases; private final ObjectMapper mapper;
    public FraudScreeningService(OrderRepository orders,AiServiceClient ai,FraudReviewCaseRepository cases,ObjectMapper mapper){this.orders=orders;this.ai=ai;this.cases=cases;this.mapper=mapper;}

    /** Cheap deterministic gate. Runs for every newly placed order; LLM is invoked only when true. */
    public boolean shouldInvestigate(Order order){
        long recent = orders.countByUserIdAndCreatedAtGreaterThanEqual(order.getUser().getId(), Instant.now().minus(1, ChronoUnit.HOURS));
        return order.getTotalAmount().compareTo(AMOUNT_THRESHOLD) >= 0 || recent >= 4;
    }

    @Async("notificationExecutor")
    @Transactional
    public void investigateAsync(Long orderId, String trigger){
        try {
            JsonNode r = ai.fraud(Map.of("order_id",orderId,"trigger_reason",trigger));
            FraudReviewCase c=new FraudReviewCase(); c.setOrderId(orderId);
            c.setRecommendation(r.path("recommendation").asText("FLAG")); c.setConfidence(r.path("confidence").asDouble(0.0));
            c.setReasoning(r.path("reasoning").asText()); c.setEvidenceJson(mapper.writeValueAsString(r.path("evidence")));
            c.setRequiresHumanApproval(true); c.setStatus("PENDING_HUMAN"); cases.save(c);
        } catch(Exception e) { /* rule flag remains observable in logs; no order action is taken */ }
    }
}
