#!/usr/bin/env python3
"""
SkillTalk Database Upload Script for Firebase Firestore
Uploads the hierarchical skill database to Firebase Firestore
"""

import json
import os
import argparse
from typing import Dict, List, Any
import firebase_admin
from firebase_admin import credentials, firestore
import time

class SkillTalkFirebaseUploader:
    def __init__(self, service_account_key_path: str):
        """Initialize Firebase connection"""
        # Initialize Firebase Admin SDK
        cred = credentials.Certificate(service_account_key_path)
        firebase_admin.initialize_app(cred)
        self.db = firestore.client()
        
    def upload_categories(self, language: str) -> List[Dict[str, Any]]:
        """Upload categories for a language"""
        print(f"📤 Uploading categories for language: {language}")
        
        # Load categories from JSON
        categories_path = f"database/languages/{language}/categories.json"
        with open(categories_path, 'r', encoding='utf-8') as f:
            categories = json.load(f)
        
        # Upload to Firestore
        categories_ref = self.db.collection('categories')
        uploaded_categories = []
        
        for category in categories:
            # Transform category data
            category_data = {
                "id": category.get("id"),
                "english_name": category.get("englishName", category.get("name")),
                "icon": category.get("icon", "📁"),
                "sort_order": category.get("sortOrder", 0),
                "description": category.get("description"),
                "translations": category.get("translations"),
                "language": language,
                "created_at": firestore.SERVER_TIMESTAMP
            }
            
            # Upload to Firestore
            doc_ref = categories_ref.document(category.get("id"))
            doc_ref.set(category_data)
            uploaded_categories.append(category_data)
            print(f"  ✅ Uploaded category: {category.get('englishName', category.get('name'))}")
        
        print(f"📊 Uploaded {len(uploaded_categories)} categories")
        return uploaded_categories
    
    def upload_subcategories(self, language: str) -> List[Dict[str, Any]]:
        """Upload subcategories for a language"""
        print(f"📤 Uploading subcategories for language: {language}")
        
        # Load subcategories from JSON
        subcategories_path = f"database/languages/{language}/subcategories.json"
        with open(subcategories_path, 'r', encoding='utf-8') as f:
            subcategories = json.load(f)
        
        # Upload to Firestore
        subcategories_ref = self.db.collection('subcategories')
        uploaded_subcategories = []
        
        for subcategory in subcategories:
            # Extract category ID from subcategory ID (e.g., "academic_intellectual_economics" -> "academic_intellectual")
            subcategory_id = subcategory.get("id")
            category_id = "_".join(subcategory_id.split("_")[:-1]) if "_" in subcategory_id else subcategory_id
            
            # Transform subcategory data
            subcategory_data = {
                "id": subcategory_id,
                "category_id": category_id,
                "english_name": subcategory.get("englishName", subcategory.get("name")),
                "icon": subcategory.get("icon", "📂"),
                "sort_order": subcategory.get("sortOrder", 0),
                "description": subcategory.get("description"),
                "translations": subcategory.get("translations"),
                "language": language,
                "created_at": firestore.SERVER_TIMESTAMP
            }
            
            if not subcategory_id or "/" in subcategory_id:
                print(f"❌ Skipping invalid subcategory ID: {subcategory_id}")
                continue
            clean_subcategory_id = subcategory_id.replace(" ", "_").replace("-", "_").replace(".", "_").replace("/", "_")
            
            # Upload to Firestore
            doc_ref = subcategories_ref.document(clean_subcategory_id)
            doc_ref.set(subcategory_data)
            uploaded_subcategories.append(subcategory_data)
            print(f"  ✅ Uploaded subcategory: {subcategory.get('englishName', subcategory.get('name'))}")
        
        print(f"📊 Uploaded {len(uploaded_subcategories)} subcategories")
        return uploaded_subcategories
    
    def upload_skills(self, language: str) -> List[Dict[str, Any]]:
        """Upload skills for a language using hierarchy files"""
        print(f"📤 Uploading skills for language: {language}")
        
        # Upload to Firestore
        skills_ref = self.db.collection('skills')
        all_skills = []
        
        # Get all category hierarchy files
        hierarchy_path = f"database/languages/{language}/hierarchy"
        if not os.path.exists(hierarchy_path):
            print(f"❌ Hierarchy path not found: {hierarchy_path}")
            return []
        
        category_files = [f for f in os.listdir(hierarchy_path) if f.endswith('.json')]
        
        for category_file in category_files:
            category_id = category_file.replace('.json', '')
            print(f"  📁 Processing category: {category_id}")
            
            # Load category hierarchy
            category_path = os.path.join(hierarchy_path, category_file)
            with open(category_path, 'r', encoding='utf-8') as f:
                category_data = json.load(f)
            
            # Process subcategories
            for subcategory in category_data.get("subcategories", []):
                subcategory_id = subcategory.get("id")
                print(f"    📂 Processing subcategory: {subcategory_id}")
                
                # Load subcategory skills
                subcategory_path = os.path.join(hierarchy_path, category_id, f"{subcategory_id}.json")
                if os.path.exists(subcategory_path):
                    with open(subcategory_path, 'r', encoding='utf-8') as f:
                        subcategory_data = json.load(f)
                    
                    # Extract skills from subcategory
                    for skill in subcategory_data.get("skills", []):
                        # Transform skill data for Firebase
                        skill_data = {
                            "id": skill.get("id"),
                            "subcategory_id": subcategory_id,
                            "english_name": skill.get("name"),
                            "description": skill.get("description"),
                            "difficulty": skill.get("difficulty", "beginner"),
                            "popularity": skill.get("popularity", 1),
                            "tags": skill.get("tags", []),
                            "icon": skill.get("icon", "🎯"),
                            "translations": skill.get("translations"),
                            "language": language,
                            "created_at": firestore.SERVER_TIMESTAMP
                        }
                        
                        # Check for valid skill ID
                        skill_id = skill.get("id")
                        if not skill_id or "/" in skill_id:
                            print(f"      ❌ Skipping invalid skill ID: {skill_id}")
                            continue
                            
                        # Clean skill ID for Firestore (remove invalid characters)
                        clean_skill_id = skill_id.replace(" ", "_").replace("-", "_").replace(".", "_").replace("/", "_")
                        
                        # Upload to Firestore
                        doc_ref = skills_ref.document(clean_skill_id)
                        doc_ref.set(skill_data)
                        all_skills.append(skill_data)
                        
                        if len(all_skills) % 100 == 0:
                            print(f"      📊 Uploaded {len(all_skills)} skills so far...")
        
        print(f"📊 Uploaded {len(all_skills)} skills total")
        return all_skills
    
    def upload_database(self, language: str):
        """Upload complete database for a language"""
        print(f"🚀 Starting Firebase Firestore upload for language: {language}")
        print("=" * 60)
        
        try:
            # Upload categories
            categories = self.upload_categories(language)
            print()
            
            # Upload subcategories
            subcategories = self.upload_subcategories(language)
            print()
            
            # Upload skills
            skills = self.upload_skills(language)
            print()
            
            # Summary
            print("=" * 60)
            print(f"🎉 Firebase Firestore upload completed for {language}!")
            print(f"📊 Summary:")
            print(f"   • Categories: {len(categories)}")
            print(f"   • Subcategories: {len(subcategories)}")
            print(f"   • Skills: {len(skills)}")
            print(f"   • Total: {len(categories) + len(subcategories) + len(skills)} records")
            print()
            print("✅ Your SkillTalk database is now available on Firebase Firestore!")
            print("🔗 You can view the data in the Firebase Console > Firestore Database")
            
        except Exception as e:
            print(f"❌ Error during upload: {str(e)}")
            raise

def main():
    parser = argparse.ArgumentParser(description='Upload SkillTalk database to Firebase Firestore')
    parser.add_argument('--service-account-key', required=True, 
                       help='Path to Firebase service account key JSON file')
    parser.add_argument('--language', default='en', 
                       help='Language code to upload (default: en)')
    
    args = parser.parse_args()
    
    # Validate service account key file
    if not os.path.exists(args.service_account_key):
        print(f"❌ Service account key file not found: {args.service_account_key}")
        print("💡 Download your service account key from:")
        print("   Firebase Console > Project Settings > Service Accounts > Generate New Private Key")
        return
    
    # Create uploader and upload
    uploader = SkillTalkFirebaseUploader(args.service_account_key)
    uploader.upload_database(args.language)

if __name__ == "__main__":
    main() 