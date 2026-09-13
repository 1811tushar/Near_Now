package com.nearnow.aiagent.entity;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name="vendor_review_cases")
public class VendorReviewCase {
    @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
    @Column(nullable=false) private Long vendorId;
    @Column(nullable=false) private String recommendation;
    @Column(nullable=false) private double confidence;
    @Column(length=5000) private String reasoning;
    @Column(length=10000) private String evidenceJson;
    @Column(nullable=false) private boolean requiresHumanApproval;
    @Column(nullable=false) private boolean businessRulePass;
    @Column(nullable=false) private String status = "PENDING_HUMAN";
    @Column(nullable=false, updatable=false) private Instant createdAt;
    @PrePersist void onCreate(){createdAt=Instant.now();}
    public Long getId(){return id;} public Long getVendorId(){return vendorId;} public String getRecommendation(){return recommendation;}
    public double getConfidence(){return confidence;} public String getReasoning(){return reasoning;} public String getEvidenceJson(){return evidenceJson;}
    public boolean isRequiresHumanApproval(){return requiresHumanApproval;} public boolean isBusinessRulePass(){return businessRulePass;}
    public String getStatus(){return status;} public Instant getCreatedAt(){return createdAt;}
    public void setVendorId(Long v){vendorId=v;} public void setRecommendation(String v){recommendation=v;} public void setConfidence(double v){confidence=v;}
    public void setReasoning(String v){reasoning=v;} public void setEvidenceJson(String v){evidenceJson=v;} public void setRequiresHumanApproval(boolean v){requiresHumanApproval=v;}
    public void setBusinessRulePass(boolean v){businessRulePass=v;} public void setStatus(String v){status=v;}
}
