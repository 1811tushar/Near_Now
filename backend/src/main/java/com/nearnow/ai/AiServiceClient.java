package com.nearnow.ai;

import com.fasterxml.jackson.databind.JsonNode;
import com.nearnow.ai.automation.DemandForecastRequest;
import com.nearnow.ai.automation.DemandForecastResponse;
import com.nearnow.ai.automation.VendorOnboardingFields;
import com.nearnow.ai.automation.VendorReportRequest;
import com.nearnow.ai.automation.VendorReportResponse;
import com.nearnow.ai.automation.VendorWeeklyStats;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.MediaType;
import org.springframework.http.client.MultipartBodyBuilder;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

/**
 * Sole HTTP entry point from Spring Boot to the internal AI service.
 *
 * This is the single consolidated client for all callers (vendor AI features,
 * automation/forecast/onboarding-OCR, and the order-support/fraud/vendor-review
 * agents). It previously existed as three separate classes
 * (com.nearnow.ai.AiServiceClient, com.nearnow.ai.automation.AiServiceClient,
 * com.nearnow.aiagent.service.AiServiceClient) that were merged into this one
 * during cleanup — same WebClient, same base URL/auth header, one bean.
 */
@Component
public class AiServiceClient {

    private final WebClient webClient;

    public AiServiceClient(
            WebClient.Builder webClientBuilder,
            @Value("${ai-service.base-url}") String baseUrl,
            @Value("${ai-service.internal-api-key}") String internalApiKey) {
        this.webClient = webClientBuilder
                .baseUrl(baseUrl)
                .defaultHeader("X-Internal-API-Key", internalApiKey)
                .build();
    }

    /** Generic authenticated POST helper for callers that want the reactive Mono directly. */
    public <T> Mono<T> post(String path, Object requestBody, Class<T> responseType) {
        return webClient.post()
                .uri(path)
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(requestBody)
                .retrieve()
                .bodyToMono(responseType);
    }

    /** Generic authenticated POST helper for callers that want a raw, blocking JsonNode result. */
    private JsonNode postJson(String path, Object requestBody) {
        return webClient.post()
                .uri(path)
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(requestBody)
                .retrieve()
                .bodyToMono(JsonNode.class)
                .block();
    }

    // ---- Order-support / fraud / vendor-review / shopping agents ----

    public JsonNode orderSupport(Object body) {
        return postJson("/ai/chat/order-support", body);
    }

    public JsonNode fraud(Object body) {
        return postJson("/ai/fraud/investigate", body);
    }

    public JsonNode vendorReview(Object body) {
        return postJson("/ai/vendor-review/evaluate", body);
    }

    public JsonNode shopping(Object body) {
        return postJson("/ai/chat/shopping", body);
    }

    // ---- Automation: weekly vendor report, onboarding OCR, demand forecast ----

    public String summarizeVendorReport(VendorWeeklyStats stats) {
        VendorReportRequest request = new VendorReportRequest(stats);
        VendorReportResponse response = webClient.post()
                .uri("/ai/vendor-report/summarize")
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(request)
                .retrieve()
                .bodyToMono(VendorReportResponse.class)
                .block();
        if (response == null || response.summary() == null || response.summary().isBlank()) {
            throw new IllegalStateException("AI service returned an empty vendor report");
        }
        return response.summary();
    }

    public VendorOnboardingFields extractVendorOnboardingFields(
            byte[] documentBytes, String filename, String contentType) {
        ByteArrayResource resource = new ByteArrayResource(documentBytes) {
            @Override
            public String getFilename() {
                return filename == null || filename.isBlank() ? "document" : filename;
            }
        };

        MultipartBodyBuilder builder = new MultipartBodyBuilder();
        builder.part("file", resource);

        return webClient.post()
                .uri("/ai/vendor-onboarding/extract")
                .contentType(MediaType.MULTIPART_FORM_DATA)
                .bodyValue(builder.build())
                .retrieve()
                .bodyToMono(VendorOnboardingFields.class)
                .block();
    }

    public DemandForecastResponse forecast(DemandForecastRequest request) {
        DemandForecastResponse response = webClient.post()
                .uri("/ai/demand-forecast/calculate")
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(request)
                .retrieve()
                .bodyToMono(DemandForecastResponse.class)
                .block();
        if (response == null) {
            throw new IllegalStateException("AI service returned no forecast response");
        }
        return response;
    }
}
