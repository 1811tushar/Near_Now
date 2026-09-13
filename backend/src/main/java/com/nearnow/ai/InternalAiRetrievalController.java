package com.nearnow.ai;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.List;
import java.util.Map;

/** Private service-to-service retrieval surface; do not expose to Flutter/portal. */
@RestController
@RequestMapping("/api/internal/ai/retrieval")
public class InternalAiRetrievalController {
    private final SemanticSearchService searchService;
    private final PolicyKnowledgeService policyKnowledgeService;
    private final String internalApiKey;

    public InternalAiRetrievalController(SemanticSearchService searchService, PolicyKnowledgeService policyKnowledgeService,
                                         @Value("${ai-service.internal-api-key}") String internalApiKey) {
        this.searchService = searchService;
        this.policyKnowledgeService = policyKnowledgeService;
        this.internalApiKey = internalApiKey;
    }

    @PostMapping("/search-candidates")
    public Map<String, List<Long>> searchCandidates(@RequestHeader("X-Internal-API-Key") String key,
                                                     @RequestBody SearchCandidateRequest request) {
        requireInternalKey(key);
        int limit = Math.min(Math.max(request.limit(), 1), 50);
        return Map.of("vector_product_ids", searchService.vectorCandidateIds(request.query(), limit),
                "keyword_product_ids", searchService.keywordCandidateIds(request.query(), limit));
    }

    @GetMapping("/similar-product-ids")
    public Map<String, List<Long>> similar(@RequestHeader("X-Internal-API-Key") String key,
                                            @RequestParam Long productId, @RequestParam(defaultValue = "10") int limit) {
        requireInternalKey(key);
        return Map.of("product_ids", searchService.similarProductIds(productId, Math.min(Math.max(limit, 1), 20)));
    }

    private void requireInternalKey(String supplied) {
        if (!MessageDigest.isEqual(supplied.getBytes(StandardCharsets.UTF_8), internalApiKey.getBytes(StandardCharsets.UTF_8))) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
        }
    }

    public record SearchCandidateRequest(String query, int limit) {}
    @GetMapping("/policy-chunks")
    public Map<String, List<Map<String, String>>> policyChunks(@RequestHeader("X-Internal-API-Key") String key,
            @RequestParam String q, @RequestParam(defaultValue = "4") int limit) {
        requireInternalKey(key);
        return Map.of("chunks", policyKnowledgeService.search(q, Math.min(Math.max(limit, 1), 6)).stream()
                .map(chunk -> Map.of("document_id", chunk.id(), "title", chunk.title(), "content", chunk.content())).toList());
    }
}
