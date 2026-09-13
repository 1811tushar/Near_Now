package com.nearnow.review;

import com.nearnow.ai.AiServiceClient;
import com.nearnow.common.dto.ApiResponse;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/reviews")
public class ReviewController {

    private final ReviewService reviewService;
    private final AiServiceClient aiServiceClient;

    public ReviewController(ReviewService reviewService, AiServiceClient aiServiceClient) {
        this.reviewService = reviewService;
        this.aiServiceClient = aiServiceClient;
    }

    // Protected (needs Authentication to know who's submitting + for
    // the purchase-check) — see SecurityConfig for the explicit path
    // that keeps this OUT of the public list, unlike GET below.
    @PostMapping("/product/{productId}")
    public ResponseEntity<ApiResponse<ReviewResponseDTO>> submitReview(
            Authentication authentication, @PathVariable Long productId,
            @Valid @RequestBody ReviewRequestDTO request) {
        return ResponseEntity.ok(ApiResponse.success(
                reviewService.submitReview(authentication.getName(), productId, request), "Review submitted"));
    }

    // Public — anyone browsing a product should see its reviews, same
    // reasoning as Product/Category being fully public.
    @GetMapping("/product/{productId}")
    public ResponseEntity<ApiResponse<List<ReviewResponseDTO>>> getReviews(@PathVariable Long productId) {
        return ResponseEntity.ok(ApiResponse.success(reviewService.getReviewsByProduct(productId)));
    }
    @GetMapping("/product/{productId}/summary")
    public ResponseEntity<ApiResponse<ReviewSummaryResponseDTO>> summarizeReviews(@PathVariable Long productId) {
        List<String> reviewTexts = reviewService.getReviewsByProduct(productId).stream()
                .map(ReviewResponseDTO::getComment)
                .filter(comment -> comment != null && !comment.isBlank())
                .toList();
        if (reviewTexts.isEmpty()) {
            throw new com.nearnow.common.exception.InvalidOperationException("This product has no written reviews to summarize");
        }
        ReviewSummaryResponseDTO summary = aiServiceClient
                .post("/ai/summarize-reviews", Map.of("review_texts", reviewTexts), ReviewSummaryResponseDTO.class)
                .block();
        return ResponseEntity.ok(ApiResponse.success(summary));
    }

}
