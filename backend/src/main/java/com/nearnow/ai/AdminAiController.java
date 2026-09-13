package com.nearnow.admin;

import com.nearnow.ai.AiServiceClient;
import com.nearnow.common.dto.ApiResponse;
import jakarta.validation.constraints.NotBlank;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

/** Admin-only passthrough; Spring Security's existing /api/admin/** rule protects it. */
@RestController
@RequestMapping("/api/admin/ai")
public class AdminAiController {
    private final AiServiceClient aiServiceClient;
    public AdminAiController(AiServiceClient aiServiceClient) { this.aiServiceClient = aiServiceClient; }
    @PostMapping("/ask-policy")
    public ResponseEntity<ApiResponse<Map>> askPolicy(@RequestBody PolicyQuestion request) {
        Map answer = aiServiceClient.post("/ai/admin/ask-policy", Map.of("question", request.question()), Map.class).block();
        return ResponseEntity.ok(ApiResponse.success(answer));
    }
    public record PolicyQuestion(@NotBlank String question) {}
}
