-- SkillTalk Database Setup for Supabase
-- Run this in your Supabase SQL Editor at: https://tjafdbkbrenhzmvqlfbm.supabase.co

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
    id TEXT PRIMARY KEY,
    english_name TEXT NOT NULL,
    icon TEXT,
    sort_order INTEGER DEFAULT 0,
    description TEXT,
    translations JSONB,
    language TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create subcategories table
CREATE TABLE IF NOT EXISTS subcategories (
    id TEXT PRIMARY KEY,
    category_id TEXT NOT NULL REFERENCES categories(id),
    english_name TEXT NOT NULL,
    icon TEXT,
    sort_order INTEGER DEFAULT 0,
    description TEXT,
    translations JSONB,
    language TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create skills table
CREATE TABLE IF NOT EXISTS skills (
    id TEXT PRIMARY KEY,
    subcategory_id TEXT NOT NULL REFERENCES subcategories(id),
    english_name TEXT NOT NULL,
    difficulty TEXT NOT NULL CHECK (difficulty IN ('beginner', 'intermediate', 'advanced', 'expert')),
    popularity INTEGER DEFAULT 0,
    icon TEXT,
    tags TEXT[],
    translations JSONB,
    language TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create languages table
CREATE TABLE IF NOT EXISTS languages (
    code TEXT PRIMARY KEY,
    name TEXT,
    native_name TEXT,
    is_supported BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_categories_language ON categories(language);
CREATE INDEX IF NOT EXISTS idx_subcategories_category_id ON subcategories(category_id);
CREATE INDEX IF NOT EXISTS idx_subcategories_language ON subcategories(language);
CREATE INDEX IF NOT EXISTS idx_skills_subcategory_id ON skills(subcategory_id);
CREATE INDEX IF NOT EXISTS idx_skills_language ON skills(language);
CREATE INDEX IF NOT EXISTS idx_skills_difficulty ON skills(difficulty);
CREATE INDEX IF NOT EXISTS idx_skills_popularity ON skills(popularity);

-- Enable Row Level Security (RLS)
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE subcategories ENABLE ROW LEVEL SECURITY;
ALTER TABLE skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE languages ENABLE ROW LEVEL SECURITY;

-- Fix RLS Policies for SkillTalk Database
-- Run this in your Supabase SQL Editor

-- Drop existing policies
DROP POLICY IF EXISTS "Allow public read access" ON categories;
DROP POLICY IF EXISTS "Allow public read access" ON subcategories;
DROP POLICY IF EXISTS "Allow public read access" ON skills;
DROP POLICY IF EXISTS "Allow public read access" ON languages;

-- Create new policies that allow both read and insert
CREATE POLICY "Allow public read and insert" ON categories FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public read and insert" ON subcategories FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public read and insert" ON skills FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public read and insert" ON languages FOR ALL USING (true) WITH CHECK (true);

-- Insert supported languages (30 languages from SkillTalk database)
INSERT INTO languages (code, name, native_name, is_supported) VALUES
('en', 'English', 'English', true),
('es', 'Spanish', 'Español', true),
('fr', 'French', 'Français', true),
('de', 'German', 'Deutsch', true),
('it', 'Italian', 'Italiano', true),
('pt', 'Portuguese', 'Português', true),
('ru', 'Russian', 'Русский', true),
('zh', 'Chinese', '中文', true),
('ja', 'Japanese', '日本語', true),
('ko', 'Korean', '한국어', true),
('ar', 'Arabic', 'العربية', true),
('hi', 'Hindi', 'हिन्दी', true),
('bn', 'Bengali', 'বাংলা', true),
('tr', 'Turkish', 'Türkçe', true),
('nl', 'Dutch', 'Nederlands', true),
('pl', 'Polish', 'Polski', true),
('sv', 'Swedish', 'Svenska', true),
('vi', 'Vietnamese', 'Tiếng Việt', true),
('th', 'Thai', 'ไทย', true),
('id', 'Indonesian', 'Bahasa Indonesia', true),
('fa', 'Persian', 'فارسی', true),
('pa', 'Punjabi', 'ਪੰਜਾਬੀ', true),
('sw', 'Swahili', 'Kiswahili', true),
('ha', 'Hausa', 'Hausa', true),
('am', 'Amharic', 'አማርኛ', true),
('yo', 'Yoruba', 'Yorùbá', true),
('te', 'Telugu', 'తెలుగు', true),
('mr', 'Marathi', 'मराठी', true),
('ta', 'Tamil', 'தமிழ்', true),
('gu', 'Gujarati', 'ગુજરાતી', true)
ON CONFLICT (code) DO NOTHING; 