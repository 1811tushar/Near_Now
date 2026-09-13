CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS product_embeddings (
    product_id BIGINT PRIMARY KEY,
    embedding vector(128) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_product_embeddings_vector
    ON product_embeddings USING hnsw (embedding vector_cosine_ops);

ALTER TABLE users ADD COLUMN IF NOT EXISTS auth_version BIGINT NOT NULL DEFAULT 0;


CREATE TABLE IF NOT EXISTS policy_chunks (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    embedding vector(128) NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_policy_chunks_vector
    ON policy_chunks USING hnsw (embedding vector_cosine_ops);
