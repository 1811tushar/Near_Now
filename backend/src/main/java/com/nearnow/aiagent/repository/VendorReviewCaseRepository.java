package com.nearnow.aiagent.repository;
import com.nearnow.aiagent.entity.VendorReviewCase;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface VendorReviewCaseRepository extends JpaRepository<VendorReviewCase,Long> {
    List<VendorReviewCase> findByStatusOrderByCreatedAtAsc(String status);
}
