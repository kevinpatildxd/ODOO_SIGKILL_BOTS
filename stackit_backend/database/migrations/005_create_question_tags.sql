-- Migration: Create Question-Tags Junction Table

-- Up Migration
CREATE TABLE IF NOT EXISTS question_tags (
    question_id INTEGER REFERENCES questions(id) ON DELETE CASCADE,
    tag_id INTEGER REFERENCES tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (question_id, tag_id)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_question_tags_tag_id ON question_tags(tag_id);
-- question_id is already indexed as part of the primary key

-- Down Migration
-- DROP TABLE IF EXISTS question_tags CASCADE;
