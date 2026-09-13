package com.nearnow.aiagent.repository;
import com.nearnow.aiagent.entity.FraudReviewCase;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface FraudReviewCaseRepository extends JpaRepository<FraudReviewCase,Long> {
    List<FraudReviewCase> findByStatusOrderByCreatedAtAsc(String status);
}
