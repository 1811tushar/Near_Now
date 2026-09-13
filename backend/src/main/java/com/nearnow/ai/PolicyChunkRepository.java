package com.nearnow.ai;

import com.pgvector.PGvector;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public class PolicyChunkRepository {
    private final JdbcTemplate jdbc;
    public PolicyChunkRepository(JdbcTemplate jdbc) { this.jdbc = jdbc; }
    public void upsert(String id, String title, String content, float[] embedding) {
        jdbc.update("INSERT INTO policy_chunks (id,title,content,embedding) VALUES (?,?,?,?) " +
                "ON CONFLICT (id) DO UPDATE SET title=EXCLUDED.title, content=EXCLUDED.content, embedding=EXCLUDED.embedding",
                id, title, content, new PGvector(embedding));
    }
    public List<PolicyChunk> nearest(float[] embedding, int limit) {
        return jdbc.query("SELECT id,title,content FROM policy_chunks ORDER BY embedding <=> ? LIMIT ?",
                (rs, row) -> new PolicyChunk(rs.getString("id"), rs.getString("title"), rs.getString("content")),
                new PGvector(embedding), limit);
    }
    public record PolicyChunk(String id, String title, String content) {}
}
