#!/bin/bash

# Script to add Supabase Swift Package Manager dependencies to Xcode project
# This script adds the required Supabase packages to the project

echo "🔧 Adding Supabase dependencies to Xcode project..."

# Navigate to the project directory
cd "$(dirname "$0")"

# Check if we're in the right directory
if [ ! -f "SkillTalk.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: Not in the correct project directory"
    exit 1
fi

# Create a temporary script to add packages via Xcode command line
cat > add_packages.swift << 'EOF'
import Foundation
import XcodeProj

// This script would need to be run with Xcode's command line tools
// For now, we'll provide instructions for manual addition

print("""
📦 Supabase Package Dependencies to Add:

1. Open SkillTalk.xcworkspace in Xcode
2. Go to File > Add Package Dependencies
3. Add the following packages:

   Main Supabase Package:
   - URL: https://github.com/supabase-community/supabase-swift
   - Version: Up to next major (latest stable)
   - Products to include: Supabase

   Alternative (if the above doesn't work):
   - URL: https://github.com/supabase/supabase-swift
   - Version: Up to next major (latest stable)
   - Products to include: Supabase

4. Make sure the packages are added to the SkillTalk target
5. Clean and rebuild the project

Note: The specific Auth and Storage products should be included automatically
with the main Supabase package.
""")
EOF

echo "📋 Instructions for adding Supabase dependencies:"
echo ""
echo "1. Open SkillTalk.xcworkspace in Xcode (not .xcodeproj)"
echo "2. Go to File > Add Package Dependencies"
echo "3. Add: https://github.com/supabase-community/supabase-swift"
echo "4. Select version: Up to next major"
echo "5. Make sure 'Supabase' product is selected"
echo "6. Add to SkillTalk target"
echo "7. Clean build folder (Product > Clean Build Folder)"
echo "8. Build again"
echo ""

# Alternative: Try to add via xcodebuild if available
if command -v xcodebuild &> /dev/null; then
    echo "🔍 Checking current package dependencies..."
    xcodebuild -workspace SkillTalk.xcworkspace -scheme SkillTalk -showBuildSettings | grep -i package || echo "No package dependencies found"
fi

echo "✅ Script completed. Please follow the manual steps above." 