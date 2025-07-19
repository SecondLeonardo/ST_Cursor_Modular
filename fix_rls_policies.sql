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