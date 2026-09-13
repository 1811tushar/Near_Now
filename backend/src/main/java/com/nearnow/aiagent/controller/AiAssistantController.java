package com.nearnow.aiagent.controller;
import com.nearnow.ai.AiServiceClient;
import com.nearnow.auth.UserRepository;
import com.nearnow.common.dto.ApiResponse;
import com.nearnow.common.exception.ResourceNotFoundException;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
@RestController @RequestMapping("/api/ai/chat")
public class AiAssistantController {
 private final UserRepository users; private final AiServiceClient ai;
 public AiAssistantController(UserRepository users,AiServiceClient ai){this.users=users;this.ai=ai;}
 @PostMapping("/order-support") public ResponseEntity<ApiResponse<?>> orderSupport(Authentication auth,@RequestBody Map<String,String> b){return call(auth,b,"order");}
 @PostMapping("/shopping") public ResponseEntity<ApiResponse<?>> shopping(Authentication auth,@RequestBody Map<String,String> b){return call(auth,b,"shopping");}
 private ResponseEntity<ApiResponse<?>> call(Authentication a,Map<String,String>b,String type){Long uid=users.findByEmail(a.getName()).orElseThrow(()->new ResourceNotFoundException("User not found")).getId(); String s=b.get("sessionId"),m=b.get("message"); if(s==null||m==null||m.isBlank())throw new IllegalArgumentException("sessionId and message are required"); Object r="order".equals(type)?ai.orderSupport(Map.of("user_id",uid,"session_id",s,"message",m)):ai.shopping(Map.of("user_id",uid,"session_id",s,"message",m)); return ResponseEntity.ok(ApiResponse.success(r));}
}
