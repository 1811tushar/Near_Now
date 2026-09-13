package com.nearnow.aiagent.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nearnow.ai.AiServiceClient;
import com.nearnow.aiagent.entity.VendorReviewCase;
import com.nearnow.aiagent.repository.VendorReviewCaseRepository;
import com.nearnow.vendor.Vendor;
import com.nearnow.vendor.VendorRepository;
import com.nearnow.common.exception.ResourceNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.*;

@Service
public class VendorReviewService {
    private static final double AUTO_APPROVE_CONFIDENCE = 0.90;
    private final VendorRepository vendors; private final AiServiceClient ai; private final VendorReviewCaseRepository cases; private final ObjectMapper mapper;
    public VendorReviewService(VendorRepository vendors,AiServiceClient ai,VendorReviewCaseRepository cases,ObjectMapper mapper){this.vendors=vendors;this.ai=ai;this.cases=cases;this.mapper=mapper;}

    @Transactional
    public VendorReviewCase evaluate(Long vendorId, Map<String,Object> documentFields){
        Vendor v=vendors.findById(vendorId).orElseThrow(()->new ResourceNotFoundException("Vendor not found: "+vendorId));
        Map<String,Object> body=new HashMap<>(); body.put("vendor_id",vendorId); body.put("business_name",v.getBusinessName());
        body.put("business_address",v.getBusinessAddress()); body.put("gst_number",v.getGstNumber()); body.put("document_fields",documentFields);
        JsonNode r=ai.vendorReview(body);
        VendorReviewCase c=new VendorReviewCase(); c.setVendorId(vendorId); c.setRecommendation(r.path("recommendation").asText("ESCALATE"));
        c.setConfidence(r.path("confidence").asDouble(0)); c.setReasoning(r.path("reasoning").asText()); c.setEvidenceJson(write(r.path("evidence")));
        c.setBusinessRulePass(r.path("business_rule_pass").asBoolean(false));
        boolean autoApprove="APPROVE".equals(c.getRecommendation()) && c.isBusinessRulePass() && c.getConfidence()>=AUTO_APPROVE_CONFIDENCE;
        c.setRequiresHumanApproval(!autoApprove); c.setStatus(autoApprove?"AUTO_APPROVED":"PENDING_HUMAN");
        if(autoApprove) v.setActive(true); vendors.save(v); return cases.save(c);
    }
    private String write(JsonNode n){try{return mapper.writeValueAsString(n);}catch(Exception e){return "[]";}}
    @Transactional public VendorReviewCase apply(Long id, boolean approve){
        VendorReviewCase c=cases.findById(id).orElseThrow(()->new ResourceNotFoundException("Vendor review not found"));
        Vendor v=vendors.findById(c.getVendorId()).orElseThrow(()->new ResourceNotFoundException("Vendor not found"));
        v.setActive(approve); vendors.save(v); c.setStatus(approve?"HUMAN_APPROVED":"HUMAN_REJECTED"); return cases.save(c);
    }
}
