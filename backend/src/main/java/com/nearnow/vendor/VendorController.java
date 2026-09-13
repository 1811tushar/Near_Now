package com.nearnow.vendor;

import com.nearnow.ai.AiServiceClient;
import com.nearnow.common.dto.ApiResponse;
import com.nearnow.common.dto.PagedResponseDTO;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.http.MediaType;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.bind.annotation.RequestPart;
import com.nearnow.ai.automation.VendorOnboardingFields;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/vendor")
public class VendorController {

    private final VendorService vendorService;
    private final AiServiceClient aiServiceClient;

    public VendorController(VendorService vendorService, AiServiceClient aiServiceClient) {
        this.vendorService = vendorService;
        this.aiServiceClient = aiServiceClient;
    }

    @GetMapping("/profile")
    public ResponseEntity<ApiResponse<VendorResponseDTO>> getProfile(Authentication authentication) {
        return ResponseEntity.ok(ApiResponse.success(
                vendorService.getProfile(authentication.getName())
        ));
    }

    @PutMapping("/profile")
    public ResponseEntity<ApiResponse<VendorResponseDTO>> updateProfile(
            Authentication authentication,
            @Valid @RequestBody VendorProfileRequestDTO request) {
        return ResponseEntity.ok(ApiResponse.success(
                vendorService.updateProfile(authentication.getName(), request),
                "Vendor profile updated"
        ));
    }


    @PostMapping(value = "/onboarding/document", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<VendorOnboardingFields>> extractOnboardingDocument(
            @RequestPart("file") MultipartFile file) throws java.io.IOException {
        if (file.isEmpty()) {
            throw new IllegalArgumentException("Document file is empty");
        }
        VendorOnboardingFields fields = aiServiceClient.extractVendorOnboardingFields(
                file.getBytes(), file.getOriginalFilename(), file.getContentType());
        return ResponseEntity.ok(ApiResponse.success(fields,
                "Document extracted. Review the fields before submitting the vendor form."));
    }

    @GetMapping("/products")
    public ResponseEntity<ApiResponse<List<VendorProductResponseDTO>>> getProducts(
            Authentication authentication) {
        return ResponseEntity.ok(ApiResponse.success(
                vendorService.getProducts(authentication.getName())
        ));
    }

    @PutMapping("/products/{id}")
    public ResponseEntity<ApiResponse<VendorProductResponseDTO>> updateProduct(
            Authentication authentication,
            @PathVariable Long id,
            @Valid @RequestBody VendorProductUpdateRequestDTO request) {
        return ResponseEntity.ok(ApiResponse.success(
                vendorService.updateProduct(authentication.getName(), id, request),
                "Product updated"
        ));
    }

    @PostMapping("/ai/generate-description")
    public ResponseEntity<ApiResponse<ProductDescriptionResponseDTO>> generateProductDescription(
            @Valid @RequestBody GenerateProductDescriptionRequestDTO request) {
        ProductDescriptionResponseDTO description = aiServiceClient
                .post("/ai/generate-description", request, ProductDescriptionResponseDTO.class)
                .block();
        return ResponseEntity.ok(ApiResponse.success(description));
    }

    @GetMapping("/purchase-orders")
    public ResponseEntity<ApiResponse<List<PurchaseOrderResponseDTO>>> getPurchaseOrders(Authentication authentication){
        return ResponseEntity.ok(ApiResponse.success(vendorService.getPurchaseOrders(authentication.getName())));
    }

    @PutMapping("/purchase-orders/{id}/accept")
    public ResponseEntity<ApiResponse<PurchaseOrderResponseDTO>> acceptPurchaseOrder(Authentication authentication, @PathVariable Long id){
        return ResponseEntity.ok(ApiResponse.success(vendorService.acceptPurchaseOrder(authentication.getName(), id), "Purchase order accepted"));
    }

    @PutMapping("/purchase-orders/{id}/reject")
    public ResponseEntity<ApiResponse<PurchaseOrderResponseDTO>> rejectPurchaseOrder(Authentication authentication, @PathVariable Long id){
        return ResponseEntity.ok(ApiResponse.success(vendorService.rejectPurchaseOrder(authentication.getName(), id), "Purchase order rejected"));
    }

    @PutMapping("/purchase-orders/{id}/dispatch")
    public ResponseEntity<ApiResponse<PurchaseOrderResponseDTO>> dispatchPurchaseOrder(
            Authentication authentication,
            @PathVariable Long id,
            @Valid @RequestBody DispatchPurchaseOrderRequestDTO request){
        return ResponseEntity.ok(ApiResponse.success(vendorService.dispatchPurchaseOrder(authentication.getName(), id, request), "Purchase order dispatched"));
    }

    @GetMapping("/orders")
    public ResponseEntity<ApiResponse<PagedResponseDTO<VendorOrderResponseDTO>>> getOrders(
            Authentication authentication,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        int safeSize = Math.min(Math.max(size, 1), 100);
        Pageable pageable = PageRequest.of(Math.max(page, 0), safeSize, Sort.by("createdAt").descending());
        Page<VendorOrderResponseDTO> orders = vendorService.getOrders(authentication.getName(), pageable);
        return ResponseEntity.ok(ApiResponse.success(PagedResponseDTO.from(orders, orders.getContent())));
    }
}
