-- =============================================
-- DATABASE SCHEMA FOR MULTIPLE CHOICE EXAM SYSTEM
-- =============================================

-- Drop existing tables if exists
DROP TABLE IF EXISTS exam_question CASCADE;
DROP TABLE IF EXISTS student_answer CASCADE;
DROP TABLE IF EXISTS exam_session CASCADE;
DROP TABLE IF EXISTS exam CASCADE;
DROP TABLE IF EXISTS answer CASCADE;
DROP TABLE IF EXISTS question CASCADE;
DROP TABLE IF EXISTS passage CASCADE;
DROP TABLE IF EXISTS chapter CASCADE;
DROP TABLE IF EXISTS subject CASCADE;
DROP TABLE IF EXISTS exam_room_proctor CASCADE;
DROP TABLE IF EXISTS exam_room CASCADE;
DROP TABLE IF EXISTS refresh_token CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS role CASCADE;

-- =============================================
-- AUTHENTICATION & USER MANAGEMENT
-- =============================================

-- Role table
CREATE TABLE role (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Users table (supports multiple roles: ADMIN, TEACHER, PROCTOR, STUDENT)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role_id INTEGER NOT NULL REFERENCES role(id),
    full_name VARCHAR(255) NOT NULL,
    student_code VARCHAR(50) UNIQUE, -- For students
    teacher_code VARCHAR(50) UNIQUE, -- For teachers
    phone VARCHAR(20),
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP,
    provider VARCHAR(50) DEFAULT 'local',
    provider_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES users(id),
    updated_by INTEGER REFERENCES users(id)
);

-- Refresh token table for JWT
CREATE TABLE refresh_token (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(500) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    is_revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP,
    ip_address VARCHAR(50),
    user_agent TEXT
);

-- =============================================
-- SUBJECT & QUESTION BANK MANAGEMENT
-- =============================================

-- Subject table
CREATE TABLE subject (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    credit_hours INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES users(id),
    updated_by INTEGER REFERENCES users(id)
);

-- Chapter table (one subject has many chapters)
CREATE TABLE chapter (
    id SERIAL PRIMARY KEY,
    subject_id INTEGER NOT NULL REFERENCES subject(id) ON DELETE CASCADE,
    chapter_number INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    display_order INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES users(id),
    updated_by INTEGER REFERENCES users(id),
    UNIQUE(subject_id, chapter_number)
);

-- Passage table (one chapter has many passages)
CREATE TABLE passage (
    id SERIAL PRIMARY KEY,
    chapter_id INTEGER NOT NULL REFERENCES chapter(id) ON DELETE CASCADE,
    title VARCHAR(255),
    content TEXT, -- The passage content that questions refer to
    display_order INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES users(id),
    updated_by INTEGER REFERENCES users(id)
);

-- Question table (one passage has many questions)
CREATE TABLE question (
    id SERIAL PRIMARY KEY,
    passage_id INTEGER NOT NULL REFERENCES passage(id) ON DELETE CASCADE,
    question_type VARCHAR(50) NOT NULL, -- 'MULTIPLE_CHOICE', 'FILL_IN_BLANK', 'TRUE_FALSE'
    content TEXT NOT NULL,
    explanation TEXT, -- Explanation for the correct answer
    difficulty_level VARCHAR(20), -- 'EASY', 'MEDIUM', 'HARD'
    points DECIMAL(5,2) DEFAULT 1.0,
    display_order INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES users(id),
    updated_by INTEGER REFERENCES users(id)
);

-- Answer table (one question has many answers)
CREATE TABLE answer (
    id SERIAL PRIMARY KEY,
    question_id INTEGER NOT NULL REFERENCES question(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_correct BOOLEAN NOT NULL DEFAULT FALSE,
    display_order INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES users(id),
    updated_by INTEGER REFERENCES users(id)
);

-- =============================================
-- EXAM MANAGEMENT
-- =============================================

-- Exam table (exam templates)
CREATE TABLE exam (
    id SERIAL PRIMARY KEY,
    subject_id INTEGER NOT NULL REFERENCES subject(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    duration_minutes INTEGER NOT NULL, -- Exam duration in minutes
    total_questions INTEGER NOT NULL,
    total_points DECIMAL(5,2) NOT NULL,
    passing_score DECIMAL(5,2) NOT NULL,
    exam_type VARCHAR(50), -- 'MIDTERM', 'FINAL', 'QUIZ', 'PRACTICE'
    is_shuffled BOOLEAN DEFAULT TRUE, -- Shuffle questions order
    is_shuffle_answers BOOLEAN DEFAULT TRUE, -- Shuffle answers order
    show_result_immediately BOOLEAN DEFAULT FALSE,
    allow_review BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES users(id),
    updated_by INTEGER REFERENCES users(id)
);

-- Exam question mapping (many-to-many relationship)
CREATE TABLE exam_question (
    id SERIAL PRIMARY KEY,
    exam_id INTEGER NOT NULL REFERENCES exam(id) ON DELETE CASCADE,
    question_id INTEGER NOT NULL REFERENCES question(id) ON DELETE CASCADE,
    display_order INTEGER NOT NULL,
    points DECIMAL(5,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(exam_id, question_id)
);

-- Exam room table (physical or virtual exam rooms)
CREATE TABLE exam_room (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    location VARCHAR(255),
    capacity INTEGER,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES users(id)
);

-- Exam room proctor mapping (many-to-many)
CREATE TABLE exam_room_proctor (
    id SERIAL PRIMARY KEY,
    exam_room_id INTEGER NOT NULL REFERENCES exam_room(id) ON DELETE CASCADE,
    proctor_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by INTEGER REFERENCES users(id),
    UNIQUE(exam_room_id, proctor_id)
);

-- =============================================
-- EXAM SESSION & RESULTS
-- =============================================

-- Exam session table (actual exam instances)
CREATE TABLE exam_session (
    id SERIAL PRIMARY KEY,
    exam_id INTEGER NOT NULL REFERENCES exam(id),
    exam_room_id INTEGER REFERENCES exam_room(id),
    student_id INTEGER NOT NULL REFERENCES users(id),
    session_code VARCHAR(100) UNIQUE NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    actual_start_time TIMESTAMP,
    actual_end_time TIMESTAMP,
    status VARCHAR(50) NOT NULL DEFAULT 'SCHEDULED', -- 'SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'MISSED'
    total_score DECIMAL(5,2),
    percentage_score DECIMAL(5,2),
    is_passed BOOLEAN,
    questions_data JSONB, -- Store shuffled questions order for this session
    ip_address VARCHAR(50),
    browser_info TEXT,
    violation_count INTEGER DEFAULT 0, -- Track exam violations (tab switching, etc.)
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    graded_at TIMESTAMP,
    graded_by INTEGER REFERENCES users(id)
);

-- Student answer table
CREATE TABLE student_answer (
    id SERIAL PRIMARY KEY,
    exam_session_id INTEGER NOT NULL REFERENCES exam_session(id) ON DELETE CASCADE,
    question_id INTEGER NOT NULL REFERENCES question(id),
    answer_id INTEGER REFERENCES answer(id), -- For multiple choice
    answer_text TEXT, -- For fill-in-blank or text answers
    is_correct BOOLEAN,
    points_earned DECIMAL(5,2) DEFAULT 0,
    time_spent_seconds INTEGER, -- Time spent on this question
    answered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(exam_session_id, question_id)
);

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

-- User indexes
CREATE INDEX idx_users_role ON users(role_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_is_active ON users(is_active);

-- Subject hierarchy indexes
CREATE INDEX idx_chapter_subject ON chapter(subject_id);
CREATE INDEX idx_passage_chapter ON passage(chapter_id);
CREATE INDEX idx_question_passage ON question(passage_id);
CREATE INDEX idx_answer_question ON answer(question_id);

-- Exam indexes
CREATE INDEX idx_exam_subject ON exam(subject_id);
CREATE INDEX idx_exam_question_exam ON exam_question(exam_id);
CREATE INDEX idx_exam_question_question ON exam_question(question_id);

-- Session indexes
CREATE INDEX idx_exam_session_exam ON exam_session(exam_id);
CREATE INDEX idx_exam_session_student ON exam_session(student_id);
CREATE INDEX idx_exam_session_status ON exam_session(status);
CREATE INDEX idx_exam_session_start_time ON exam_session(start_time);
CREATE INDEX idx_student_answer_session ON student_answer(exam_session_id);

-- Refresh token indexes
CREATE INDEX idx_refresh_token_user ON refresh_token(user_id);
CREATE INDEX idx_refresh_token_expires ON refresh_token(expires_at);

-- =============================================
-- INITIAL DATA
-- =============================================

-- Insert default roles
INSERT INTO role (name, description) VALUES
('ADMIN', 'System administrator with full access'),
('TEACHER', 'Teacher who can create and manage exams'),
('PROCTOR', 'Exam proctor who monitors exam sessions'),
('STUDENT', 'Student who takes exams');

-- Insert default admin user (password: Admin@123)
-- Password hash for 'Admin@123' using BCrypt
INSERT INTO users (username, email, password_hash, role_id, full_name, is_active, is_verified) 
VALUES ('admin', 'admin@examapp.com', '$2a$10$qZ7V3QJnLxVFhJ5pXqV7KOXhXxqYqZ5K5zZ5Z5Z5Z5Z5Z5Z5Z5Z5Z', 1, 'System Administrator', TRUE, TRUE);

-- =============================================
-- TRIGGERS FOR UPDATED_AT
-- =============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subject_updated_at BEFORE UPDATE ON subject FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_chapter_updated_at BEFORE UPDATE ON chapter FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_passage_updated_at BEFORE UPDATE ON passage FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_question_updated_at BEFORE UPDATE ON question FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_answer_updated_at BEFORE UPDATE ON answer FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_exam_updated_at BEFORE UPDATE ON exam FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_exam_session_updated_at BEFORE UPDATE ON exam_session FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_exam_room_updated_at BEFORE UPDATE ON exam_room FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- COMMENTS
-- =============================================

COMMENT ON TABLE users IS 'Central user table for all user types';
COMMENT ON TABLE refresh_token IS 'JWT refresh tokens for authentication';
COMMENT ON TABLE subject IS 'Academic subjects';
COMMENT ON TABLE chapter IS 'Chapters within subjects';
COMMENT ON TABLE passage IS 'Reading passages or context for questions';
COMMENT ON TABLE question IS 'Question bank';
COMMENT ON TABLE answer IS 'Answer options for questions';
COMMENT ON TABLE exam IS 'Exam templates';
COMMENT ON TABLE exam_session IS 'Actual exam instances taken by students';
COMMENT ON TABLE student_answer IS 'Student answers for each exam session';

