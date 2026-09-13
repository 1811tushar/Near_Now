package com.nearnow.aiagent.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.nearnow.aiagent.entity.*;
import com.nearnow.aiagent.repository.*;
import com.nearnow.aiagent.service.VendorReviewService;
import com.nearnow.common.dto.ApiResponse;
import com.nearnow.common.exception.ResourceNotFoundException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/admin/ai")
public class AiReviewAdminController {
    private final FraudReviewCaseRepository fraud; private final VendorReviewCaseRepository vendor; private final VendorReviewService vendorReview; private final ObjectMapper mapper;
    public AiReviewAdminController(FraudReviewCaseRepository fraud,VendorReviewCaseRepository vendor,VendorReviewService vendorReview,ObjectMapper mapper){this.fraud=fraud;this.vendor=vendor;this.vendorReview=vendorReview;this.mapper=mapper;}
    @GetMapping("/fraud-reviews") public ResponseEntity<ApiResponse<List<FraudReviewCase>>> fraudQueue(){return ResponseEntity.ok(ApiResponse.success(fraud.findByStatusOrderByCreatedAtAsc("PENDING_HUMAN")));}
    @PostMapping("/fraud-reviews/{id}/resolve") public ResponseEntity<ApiResponse<FraudReviewCase>> resolveFraud(@PathVariable Long id,@RequestParam boolean clear){FraudReviewCase c=fraud.findById(id).orElseThrow(()->new ResourceNotFoundException("Fraud case not found")); c.setStatus(clear?"CLEARED":"BLOCK_RECOMMENDATION_PENDING"); return ResponseEntity.ok(ApiResponse.success(fraud.save(c),"Fraud review resolved"));}
    @GetMapping("/vendor-reviews") public ResponseEntity<ApiResponse<List<VendorReviewCase>>> vendorQueue(){return ResponseEntity.ok(ApiResponse.success(vendor.findByStatusOrderByCreatedAtAsc("PENDING_HUMAN")));}
    @PostMapping("/vendor-reviews/evaluate/{vendorId}") public ResponseEntity<ApiResponse<VendorReviewCase>> evaluate(@PathVariable Long vendorId,@RequestBody(required=false) Map<String,Object> documentFields){return ResponseEntity.ok(ApiResponse.success(vendorReview.evaluate(vendorId,documentFields==null?Map.of():documentFields)));}
    @PostMapping("/vendor-reviews/{id}/resolve") public ResponseEntity<ApiResponse<VendorReviewCase>> resolveVendor(@PathVariable Long id,@RequestParam boolean approve){return ResponseEntity.ok(ApiResponse.success(vendorReview.apply(id,approve),"Vendor review resolved"));}
}
