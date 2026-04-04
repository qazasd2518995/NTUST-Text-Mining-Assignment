-- ═══════════════════════════════════════════════════
-- Supabase Setup: Text Mining Assignment Submission
-- Run this in Supabase SQL Editor (Dashboard > SQL)
-- ═══════════════════════════════════════════════════

-- 1. Create text_mining_submissions table
CREATE TABLE IF NOT EXISTS text_mining_submissions (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id TEXT NOT NULL,
    student_name TEXT NOT NULL,
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    file_url TEXT,
    file_size BIGINT,
    week INTEGER NOT NULL,
    submitted_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Enable Row Level Security
ALTER TABLE text_mining_submissions ENABLE ROW LEVEL SECURITY;

-- 3. Allow anonymous inserts (for student submissions)
CREATE POLICY "Allow anonymous insert" ON text_mining_submissions
    FOR INSERT
    TO anon
    WITH CHECK (true);

-- 4. Allow anonymous select (optional: for confirmation)
CREATE POLICY "Allow anonymous select" ON text_mining_submissions
    FOR SELECT
    TO anon
    USING (true);

-- 5. Create storage bucket for assignments (if not exists)
INSERT INTO storage.buckets (id, name, public)
VALUES ('assignments', 'assignments', true)
ON CONFLICT (id) DO NOTHING;

-- 6. Allow anonymous uploads to assignments bucket (if policy doesn't exist)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'objects' AND policyname = 'Allow anonymous upload'
    ) THEN
        CREATE POLICY "Allow anonymous upload" ON storage.objects
            FOR INSERT TO anon WITH CHECK (bucket_id = 'assignments');
    END IF;
END $$;

-- 7. Allow public read access (if policy doesn't exist)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'objects' AND policyname = 'Allow public read'
    ) THEN
        CREATE POLICY "Allow public read" ON storage.objects
            FOR SELECT TO anon USING (bucket_id = 'assignments');
    END IF;
END $$;
