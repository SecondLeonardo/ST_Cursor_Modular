#!/usr/bin/env python3
"""
SkillTalk Database Upload Script
Uploads the hierarchical skill database to Supabase
"""

import json
import os
import requests
import argparse
from typing import Dict, List, Any
import time

class SkillTalkDatabaseUploader:
    def __init__(self, supabase_url: str, supabase_key: str):
        self.supabase_url = supabase_url
        self.supabase_key = supabase_key
        self.headers = {
            "apikey": supabase_key,
            "Authorization": f"Bearer {supabase_key}",
            "Content-Type": "application/json",
            "Prefer": "return=minimal"
        }
        
    def upload_categories(self, language: str) -> List[Dict[str, Any]]:
        """Upload categories for a language"""
        print(f"📤 Uploading categories for language: {language}")
        
        # Load categories from the flat file
        categories_file = f"database/languages/{language}/categories.json"
        if not os.path.exists(categories_file):
            print(f"❌ Categories file not found: {categories_file}")
            return []
            
        with open(categories_file, 'r', encoding='utf-8') as f:
            categories = json.load(f)
        
        # Transform categories to match Supabase schema
        transformed_categories = []
        for category in categories:
            transformed_category = {
                "id": category.get("id"),
                "english_name": category.get("name"),
                "icon": category.get("icon", "📁"),
                "sort_order": category.get("sortOrder", 0),
                "description": category.get("description"),
                "translations": category.get("translations"),
                "language": language
            }
            transformed_categories.append(transformed_category)
        
        # Upload categories
        try:
            response = requests.post(
                f"{self.supabase_url}/categories",
                headers=self.headers,
                json=transformed_categories
            )
            
            if response.status_code == 201:
                print(f"✅ Uploaded {len(transformed_categories)} categories for {language}")
                return transformed_categories
            else:
                print(f"❌ Failed to upload categories: {response.status_code} - {response.text}")
                return []
                
        except Exception as e:
            print(f"❌ Error uploading categories: {e}")
            return []
    
    def upload_subcategories(self, language: str, categories: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Upload subcategories for a language using hierarchy files"""
        print(f"📤 Uploading subcategories for language: {language}")
        
        hierarchy_dir = f"database/languages/{language}/hierarchy"
        if not os.path.exists(hierarchy_dir):
            print(f"❌ Hierarchy directory not found: {hierarchy_dir}")
            return []
        
        all_subcategories = []
        
        # Process each category hierarchy file
        for category in categories:
            category_id = category["id"]
            hierarchy_file = f"{hierarchy_dir}/{category_id}.json"
            
            if not os.path.exists(hierarchy_file):
                print(f"⚠️  Hierarchy file not found for category {category_id}")
                continue
                
            with open(hierarchy_file, 'r', encoding='utf-8') as f:
                hierarchy_data = json.load(f)
            
            # Extract subcategories from hierarchy
            for subcategory in hierarchy_data.get("subcategories", []):
                transformed_subcategory = {
                    "id": subcategory.get("id"),
                    "category_id": category_id,
                    "english_name": subcategory.get("name"),
                    "icon": subcategory.get("icon", "📂"),
                    "sort_order": subcategory.get("sortOrder", 0),
                    "description": subcategory.get("description"),
                    "translations": subcategory.get("translations"),
                    "language": language
                }
                all_subcategories.append(transformed_subcategory)
        
        # Upload subcategories in batches
        batch_size = 100
        for i in range(0, len(all_subcategories), batch_size):
            batch = all_subcategories[i:i + batch_size]
            
            try:
                response = requests.post(
                    f"{self.supabase_url}/subcategories",
                    headers=self.headers,
                    json=batch
                )
                
                if response.status_code == 201:
                    print(f"✅ Uploaded batch {i//batch_size + 1} ({len(batch)} subcategories)")
                else:
                    print(f"❌ Failed to upload subcategories batch: {response.status_code} - {response.text}")
                    return []
                    
            except Exception as e:
                print(f"❌ Error uploading subcategories batch: {e}")
                return []
        
        print(f"✅ Uploaded {len(all_subcategories)} subcategories for {language}")
        return all_subcategories
    
    def upload_skills(self, language: str, categories: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Upload skills for a language using hierarchy files"""
        print(f"📤 Uploading skills for language: {language}")
        
        hierarchy_dir = f"database/languages/{language}/hierarchy"
        if not os.path.exists(hierarchy_dir):
            print(f"❌ Hierarchy directory not found: {hierarchy_dir}")
            return []
        
        all_skills = []
        
        # Process each category hierarchy file
        for category in categories:
            category_id = category["id"]
            hierarchy_file = f"{hierarchy_dir}/{category_id}.json"
            
            if not os.path.exists(hierarchy_file):
                continue
                
            with open(hierarchy_file, 'r', encoding='utf-8') as f:
                hierarchy_data = json.load(f)
            
            # Process each subcategory
            for subcategory in hierarchy_data.get("subcategories", []):
                subcategory_id = subcategory["id"]
                subcategory_dir = f"{hierarchy_dir}/{category_id}/{subcategory_id}.json"
                
                if not os.path.exists(subcategory_dir):
                    print(f"⚠️  Subcategory file not found: {subcategory_dir}")
                    continue
                
                with open(subcategory_dir, 'r', encoding='utf-8') as f:
                    subcategory_data = json.load(f)
                
                # Extract skills from subcategory
                for skill in subcategory_data.get("skills", []):
                    transformed_skill = {
                        "id": skill.get("id"),
                        "subcategory_id": subcategory_id,
                        "english_name": skill.get("name"),
                        "description": skill.get("description"),
                        "difficulty": skill.get("difficulty", "beginner"),
                        "popularity": skill.get("popularity", 1),
                        "tags": skill.get("tags", []),
                        "icon": skill.get("icon", "🎯"),
                        "translations": skill.get("translations", {}),
                        "language": language
                    }
                    all_skills.append(transformed_skill)
        
        # Upload skills in batches
        batch_size = 50  # Smaller batch size for skills
        for i in range(0, len(all_skills), batch_size):
            batch = all_skills[i:i + batch_size]
            
            try:
                response = requests.post(
                    f"{self.supabase_url}/skills",
                    headers=self.headers,
                    json=batch
                )
                
                if response.status_code == 201:
                    print(f"✅ Uploaded skills batch {i//batch_size + 1} ({len(batch)} skills)")
                else:
                    print(f"❌ Failed to upload skills batch: {response.status_code} - {response.text}")
                    return []
                    
            except Exception as e:
                print(f"❌ Error uploading skills batch: {e}")
                return []
        
        print(f"✅ Uploaded {len(all_skills)} skills for {language}")
        return all_skills
    
    def upload_language(self, language: str):
        """Upload all data for a specific language"""
        print(f"\n🌐 Processing language: {language}")
        
        # Step 1: Upload categories
        categories = self.upload_categories(language)
        if not categories:
            print(f"❌ Failed to upload categories for {language}")
            return
        
        # Step 2: Upload subcategories
        subcategories = self.upload_subcategories(language, categories)
        if not subcategories:
            print(f"❌ Failed to upload subcategories for {language}")
            return
        
        # Step 3: Upload skills
        skills = self.upload_skills(language, categories)
        if not skills:
            print(f"❌ Failed to upload skills for {language}")
            return
        
        print(f"\n✅ Successfully uploaded all data for {language}")
        print(f"   📊 Categories: {len(categories)}")
        print(f"   📊 Subcategories: {len(subcategories)}")
        print(f"   📊 Skills: {len(skills)}")

def main():
    parser = argparse.ArgumentParser(description="Upload SkillTalk database to Supabase")
    parser.add_argument("--supabase-url", required=True, help="Supabase REST API URL")
    parser.add_argument("--supabase-key", required=True, help="Supabase anon key")
    parser.add_argument("--language", default="en", help="Language to upload (default: en)")
    
    args = parser.parse_args()
    
    uploader = SkillTalkDatabaseUploader(args.supabase_url, args.supabase_key)
    uploader.upload_language(args.language)

if __name__ == "__main__":
    main() 