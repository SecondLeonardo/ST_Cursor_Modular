#!/bin/bash

# Script to fix duplicate package dependency issues in Xcode project
echo "🔧 Fixing package dependency issues..."

# Navigate to project directory
cd "$(dirname "$0")"

# 1. Clean all derived data and caches
echo "🧹 Cleaning derived data and caches..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/com.apple.dt.Xcode/*

# 2. Remove existing package references
echo "🗑️ Removing existing package references..."
rm -rf SkillTalk.xcworkspace/xcshareddata/swiftpm
rm -rf SkillTalk.xcodeproj/project.xcworkspace/xcshareddata/swiftpm
find . -name "Package.resolved" -delete

# 3. Clean CocoaPods
echo "🧹 Cleaning CocoaPods..."
pod deintegrate
pod cache clean --all

# 4. Reinstall CocoaPods
echo "📦 Reinstalling CocoaPods..."
pod install --repo-update

# 5. Create a temporary script to add Supabase properly
cat > add_supabase_properly.swift << 'EOF'
import Foundation

print("""
📋 MANUAL STEPS TO ADD SUPABASE PROPERLY:

1. Open SkillTalk.xcworkspace in Xcode
2. Go to File > Add Package Dependencies
3. In the search field, paste: https://github.com/supabase-community/supabase-swift
4. Click "Add Package"
5. Select version: "Up to next major" (latest stable)
6. Make sure ONLY the "Supabase" product is selected
7. Click "Add Package"
8. In the target selection, make sure it's added to "SkillTalk" target
9. Click "Add Package"

IMPORTANT NOTES:
- Do NOT add multiple versions of the same package
- Do NOT add individual Auth/Storage products separately
- The main Supabase package includes all necessary components
- If you see any duplicate entries, remove them first

After adding:
1. Clean Build Folder (Product > Clean Build Folder)
2. Build the project (Cmd+B)
""")
EOF

echo "✅ Package dependency cleanup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Open SkillTalk.xcworkspace in Xcode"
echo "2. Follow the manual steps above to add Supabase properly"
echo "3. Clean and build the project"
echo ""
echo "🔍 If you still see duplicate GUID errors:"
echo "1. Close Xcode completely"
echo "2. Delete ~/Library/Developer/Xcode/DerivedData"
echo "3. Reopen the workspace and try again" 