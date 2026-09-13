package com.nearnow.aiagent.controller;

import com.nearnow.common.exception.ResourceNotFoundException;
import com.nearnow.order.*;
import com.nearnow.payment.PaymentRepository;
import com.nearnow.payment.PaymentStatus;
import com.nearnow.product.Product;
import com.nearnow.vendor.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.Instant;
import java.util.*;

@RestController
@RequestMapping("/api/internal/ai")
public class AiInternalController {
    private final OrderRepository orders; private final VendorRepository vendors; private final PurchaseOrderRepository pos; private final PaymentRepository payments;
    private final String key;
    public AiInternalController(OrderRepository orders,VendorRepository vendors,PurchaseOrderRepository pos,PaymentRepository payments,@Value("${ai.internal-api-key:}") String key){this.orders=orders;this.vendors=vendors;this.pos=pos;this.payments=payments;this.key=key;}
    private void auth(String supplied){if(key.isBlank()||!key.equals(supplied)) throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.UNAUTHORIZED,"Invalid internal key");}

    @GetMapping("/orders/{id}") public ResponseEntity<?> order(@RequestHeader("X-Internal-API-Key") String k,@PathVariable Long id,@RequestParam(required=false) Long userId){auth(k); Order o=orders.findById(id).orElseThrow(()->new ResourceNotFoundException("Order not found")); if(userId!=null&&!o.getUser().getId().equals(userId)) throw new ResourceNotFoundException("Order not found"); return ResponseEntity.ok(Map.of("id",o.getId(),"userId",o.getUser().getId(),"totalAmount",o.getTotalAmount(),"status",o.getStatus(),"createdAt",o.getCreatedAt()));}
    @GetMapping("/orders/{id}/refund-eligibility") public ResponseEntity<?> refund(@RequestHeader("X-Internal-API-Key") String k,@PathVariable Long id,@RequestParam(required=false) Long userId){auth(k); Order o=orders.findById(id).orElseThrow(()->new ResourceNotFoundException("Order not found")); if(userId!=null&&!o.getUser().getId().equals(userId)) throw new ResourceNotFoundException("Order not found"); boolean eligible=o.getStatus()==OrderStatus.DELIVERED && payments.findByOrderId(id).map(p->p.getStatus()==PaymentStatus.PAID).orElse(false); return ResponseEntity.ok(Map.of("orderId",id,"eligible",eligible,"reason",eligible?"Delivered and paid":"Only delivered paid orders are currently eligible"));}
    @GetMapping("/orders/{id}/investigation") public ResponseEntity<?> investigation(@RequestHeader("X-Internal-API-Key") String k,@PathVariable Long id){auth(k); Order o=orders.findById(id).orElseThrow(()->new ResourceNotFoundException("Order not found")); Set<Long> vendorIds=new HashSet<>(); for(OrderItem i:o.getItems()) if(i.getProduct()!=null&&i.getProduct().getVendor()!=null) vendorIds.add(i.getProduct().getVendor().getId()); return ResponseEntity.ok(Map.of("orderId",id,"userId",o.getUser().getId(),"totalAmount",o.getTotalAmount(),"status",o.getStatus(),"createdAt",o.getCreatedAt(),"vendorIds",vendorIds));}
    @GetMapping("/users/{userId}/orders") public ResponseEntity<?> userOrders(@RequestHeader("X-Internal-API-Key") String k,@PathVariable Long userId){auth(k); return ResponseEntity.ok(orders.findByUserIdOrderByCreatedAtDesc(userId).stream().limit(20).map(o->Map.of("id",o.getId(),"totalAmount",o.getTotalAmount(),"status",o.getStatus(),"createdAt",o.getCreatedAt())).toList());}
    @GetMapping("/vendors/{vendorId}/history") public ResponseEntity<?> vendorHistory(@RequestHeader("X-Internal-API-Key") String k,@PathVariable Long vendorId){auth(k); Vendor v=vendors.findById(vendorId).orElseThrow(()->new ResourceNotFoundException("Vendor not found")); List<PurchaseOrder> po=pos.findByVendorIdOrderByCreatedAtDesc(vendorId); return ResponseEntity.ok(Map.of("vendorId",vendorId,"businessName",v.getBusinessName(),"active",v.isActive(),"purchaseOrders",po.stream().limit(30).map(p->Map.of("id",p.getId(),"status",p.getStatus(),"quantity",p.getQuantity(),"createdAt",p.getCreatedAt())).toList()));}
}
