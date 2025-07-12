-- Migration: Create Answers Table

-- Up Migration
CREATE TABLE IF NOT EXISTS answers (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    question_id INTEGER REFERENCES questions(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    is_accepted BOOLEAN DEFAULT FALSE,
    vote_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_answers_question_id ON answers(question_id);
CREATE INDEX IF NOT EXISTS idx_answers_user_id ON answers(user_id);
CREATE INDEX IF NOT EXISTS idx_answers_created_at ON answers(created_at DESC);

-- Add foreign key to questions for accepted answers (after both tables exist)
ALTER TABLE questions 
ADD CONSTRAINT fk_questions_accepted_answer
FOREIGN KEY (accepted_answer_id) 
REFERENCES answers(id) ON DELETE SET NULL;

-- Down Migration
-- ALTER TABLE questions DROP CONSTRAINT IF EXISTS fk_questions_accepted_answer;
-- DROP TABLE IF EXISTS answers CASCADE;
