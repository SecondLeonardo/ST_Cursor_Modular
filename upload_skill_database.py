#!/usr/bin/env python3
"""
Skill Database Upload Script
Uploads skill database to both Supabase and Firebase

Usage:
    python upload_skill_database.py --supabase-url https://tjafdbkbrenhzmvqlfbm.supabase.co --supabase-key eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqYWZkYmticmVuaHptdnFsZmJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzNTQyODMsImV4cCI6MjA2NzkzMDI4M30.j0EUs4EZvRL9VSoRq0hWl79T1DlaW6l4cz3D5mmqHRQ --firebase-project YOUR_PROJECT
"""

import json
import os
import sys
import argparse
import requests
from typing import Dict, List, Any
import firebase_admin
from firebase_admin import credentials, firestore

class SkillDatabaseUploader:
    def __init__(self, supabase_url: str = None, supabase_key: str = None, firebase_project: str = None):
        self.supabase_url = supabase_url
        self.supabase_key = supabase_key
        self.firebase_project = firebase_project
        self.database_path = "database"
        
    def load_json_file(self, file_path: str) -> Any:
        """Load JSON file from database directory"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            print(f"❌ Error loading {file_path}: {e}")
            return None
    
    def upload_to_supabase(self, language: str):
        """Upload skill data to Supabase"""
        if not self.supabase_url or not self.supabase_key:
            print("⚠️  Supabase credentials not provided, skipping Supabase upload")
            return
        
        print(f"🚀 Uploading to Supabase for language: {language}")
        
        headers = {
            "apikey": self.supabase_key,
            "Authorization": f"Bearer {self.supabase_key}",
            "Content-Type": "application/json"
        }
        
        # Upload categories
        categories_file = f"{self.database_path}/languages/{language}/categories.json"
        if os.path.exists(categories_file):
            categories = self.load_json_file(categories_file)
            if categories:
                try:
                    response = requests.post(
                        f"{self.supabase_url}/categories",
                        headers=headers,
                        json=categories
                    )
                    if response.status_code == 201:
                        print(f"✅ Uploaded {len(categories)} categories to Supabase")
                    else:
                        print(f"❌ Failed to upload categories: {response.status_code}")
                except Exception as e:
                    print(f"❌ Error uploading categories to Supabase: {e}")
        
        # Upload subcategories
        subcategories_file = f"{self.database_path}/languages/{language}/subcategories.json"
        if os.path.exists(subcategories_file):
            subcategories = self.load_json_file(subcategories_file)
            if subcategories:
                try:
                    response = requests.post(
                        f"{self.supabase_url}/subcategories",
                        headers=headers,
                        json=subcategories
                    )
                    if response.status_code == 201:
                        print(f"✅ Uploaded {len(subcategories)} subcategories to Supabase")
                    else:
                        print(f"❌ Failed to upload subcategories: {response.status_code}")
                except Exception as e:
                    print(f"❌ Error uploading subcategories to Supabase: {e}")
        
        # Upload skills
        skills_file = f"{self.database_path}/languages/{language}/skills.json"
        if os.path.exists(skills_file):
            skills = self.load_json_file(skills_file)
            if skills:
                # Upload in batches to avoid payload size limits
                batch_size = 100
                for i in range(0, len(skills), batch_size):
                    batch = skills[i:i + batch_size]
                    try:
                        response = requests.post(
                            f"{self.supabase_url}/skills",
                            headers=headers,
                            json=batch
                        )
                        if response.status_code == 201:
                            print(f"✅ Uploaded batch {i//batch_size + 1} ({len(batch)} skills) to Supabase")
                        else:
                            print(f"❌ Failed to upload skills batch: {response.status_code}")
                    except Exception as e:
                        print(f"❌ Error uploading skills batch to Supabase: {e}")
    
    def upload_to_firebase(self, language: str):
        """Upload skill data to Firebase"""
        if not self.firebase_project:
            print("⚠️  Firebase project not provided, skipping Firebase upload")
            return
        
        print(f"🔥 Uploading to Firebase for language: {language}")
        
        try:
            # Initialize Firebase (you'll need to set up credentials)
            # cred = credentials.Certificate("path/to/serviceAccountKey.json")
            # firebase_admin.initialize_app(cred, {"projectId": self.firebase_project})
            
            db = firestore.client()
            
            # Upload categories
            categories_file = f"{self.database_path}/languages/{language}/categories.json"
            if os.path.exists(categories_file):
                categories = self.load_json_file(categories_file)
                if categories:
                    batch = db.batch()
                    for category in categories:
                        doc_ref = db.collection("skills").document("categories").collection(language).document(category["id"])
                        batch.set(doc_ref, category)
                    batch.commit()
                    print(f"✅ Uploaded {len(categories)} categories to Firebase")
            
            # Upload subcategories
            subcategories_file = f"{self.database_path}/languages/{language}/subcategories.json"
            if os.path.exists(subcategories_file):
                subcategories = self.load_json_file(subcategories_file)
                if subcategories:
                    batch = db.batch()
                    for subcategory in subcategories:
                        doc_ref = db.collection("skills").document("subcategories").collection(language).document(subcategory["id"])
                        batch.set(doc_ref, subcategory)
                    batch.commit()
                    print(f"✅ Uploaded {len(subcategories)} subcategories to Firebase")
            
            # Upload skills
            skills_file = f"{self.database_path}/languages/{language}/skills.json"
            if os.path.exists(skills_file):
                skills = self.load_json_file(skills_file)
                if skills:
                    batch = db.batch()
                    for skill in skills:
                        doc_ref = db.collection("skills").document("skills").collection(language).document(skill["id"])
                        batch.set(doc_ref, skill)
                    batch.commit()
                    print(f"✅ Uploaded {len(skills)} skills to Firebase")
                    
        except Exception as e:
            print(f"❌ Error uploading to Firebase: {e}")
    
    def upload_supported_languages(self):
        """Upload supported languages metadata"""
        languages_file = f"{self.database_path}/languages.json"
        if os.path.exists(languages_file):
            languages_data = self.load_json_file(languages_file)
            if languages_data:
                supported_languages = [lang["code"] for lang in languages_data if lang.get("isSupported", True)]
                
                # Upload to Supabase
                if self.supabase_url and self.supabase_key:
                    headers = {
                        "apikey": self.supabase_key,
                        "Authorization": f"Bearer {self.supabase_key}",
                        "Content-Type": "application/json"
                    }
                    try:
                        response = requests.post(
                            f"{self.supabase_url}/languages",
                            headers=headers,
                            json=[{"code": lang} for lang in supported_languages]
                        )
                        if response.status_code == 201:
                            print(f"✅ Uploaded {len(supported_languages)} supported languages to Supabase")
                    except Exception as e:
                        print(f"❌ Error uploading languages to Supabase: {e}")
                
                # Upload to Firebase
                if self.firebase_project:
                    try:
                        db = firestore.client()
                        doc_ref = db.collection("metadata").document("languages")
                        doc_ref.set({"supportedLanguages": supported_languages})
                        print(f"✅ Uploaded {len(supported_languages)} supported languages to Firebase")
                    except Exception as e:
                        print(f"❌ Error uploading languages to Firebase: {e}")
    
    def upload_all_languages(self):
        """Upload data for all supported languages"""
        languages_file = f"{self.database_path}/languages.json"
        if os.path.exists(languages_file):
            languages_data = self.load_json_file(languages_file)
            if languages_data:
                supported_languages = [lang["code"] for lang in languages_data if lang.get("isSupported", True)]
                
                print(f"📦 Found {len(supported_languages)} supported languages")
                
                for language in supported_languages:
                    print(f"\n🌐 Processing language: {language}")
                    self.upload_to_supabase(language)
                    self.upload_to_firebase(language)
                
                print(f"\n📋 Uploading supported languages metadata")
                self.upload_supported_languages()
                
                print(f"\n✅ Upload complete for all languages!")
            else:
                print("❌ Failed to load languages.json")
        else:
            print("❌ languages.json not found")
    
    def create_supabase_tables(self):
        """Create the necessary tables in Supabase"""
        if not self.supabase_url or not self.supabase_key:
            print("⚠️  Supabase credentials not provided, skipping table creation")
            return
        
        print("🏗️  Creating Supabase tables...")
        
        # SQL to create tables
        create_tables_sql = """
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
        """
        
        # Execute SQL (you'll need to run this in Supabase SQL editor)
        print("📝 Please run the following SQL in your Supabase SQL editor:")
        print(create_tables_sql)

def main():
    parser = argparse.ArgumentParser(description="Upload skill database to Supabase and Firebase")
    parser.add_argument("--supabase-url", help="Supabase project URL")
    parser.add_argument("--supabase-key", help="Supabase API key")
    parser.add_argument("--firebase-project", help="Firebase project ID")
    parser.add_argument("--create-tables", action="store_true", help="Create Supabase tables")
    parser.add_argument("--language", help="Upload specific language only")
    
    args = parser.parse_args()
    
    uploader = SkillDatabaseUploader(
        supabase_url=args.supabase_url,
        supabase_key=args.supabase_key,
        firebase_project=args.firebase_project
    )
    
    if args.create_tables:
        uploader.create_supabase_tables()
        return
    
    if args.language:
        print(f"🌐 Uploading data for language: {args.language}")
        uploader.upload_to_supabase(args.language)
        uploader.upload_to_firebase(args.language)
    else:
        uploader.upload_all_languages()

if __name__ == "__main__":
    main() 