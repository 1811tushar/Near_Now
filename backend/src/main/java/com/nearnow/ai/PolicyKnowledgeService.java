package com.nearnow.ai;

import jakarta.annotation.PostConstruct;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.List;

@Service
public class PolicyKnowledgeService {
    private static final List<String> DOCS = List.of("return-policy", "delivery-policy", "refund-policy");
    private final PolicyChunkRepository repository;
    private final LocalEmbeddingService embeddings;
    public PolicyKnowledgeService(PolicyChunkRepository repository, LocalEmbeddingService embeddings) {
        this.repository = repository; this.embeddings = embeddings;
    }
    @PostConstruct
    void seedBundledPolicies() throws IOException {
        for (String name : DOCS) {
            String content = new ClassPathResource("policies/" + name + ".md").getContentAsString(StandardCharsets.UTF_8);
            repository.upsert(name, title(name), content, embeddings.embed(content));
        }
    }
    public List<PolicyChunkRepository.PolicyChunk> search(String question, int limit) {
        return repository.nearest(embeddings.embed(question), limit);
    }
    private String title(String name) { return name.replace("-", " ").replaceFirst("^.", name.substring(0, 1).toUpperCase()); }
}
