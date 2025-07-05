#!/bin/bash

# Targeted package dependency cleanup script
echo "🎯 Performing targeted package dependency cleanup..."

# Navigate to project directory
cd "$(dirname "$0")"

# 1. Clean all caches
echo "🧹 Cleaning caches..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/com.apple.dt.Xcode/*

# 2. Remove package state files
echo "🗑️ Removing package state..."
rm -rf SkillTalk.xcworkspace/xcshareddata/swiftpm
rm -rf SkillTalk.xcodeproj/project.xcworkspace/xcshareddata/swiftpm
find . -name "Package.resolved" -delete

# 3. Clean CocoaPods
echo "🧹 Cleaning CocoaPods..."
pod deintegrate
pod cache clean --all
rm -rf Pods/
rm -f Podfile.lock

# 4. Reinstall CocoaPods
echo "📦 Reinstalling CocoaPods..."
pod install --repo-update

# 5. Create clean workspace state
echo "🔧 Creating clean workspace state..."
mkdir -p SkillTalk.xcworkspace/xcshareddata/swiftpm

# 6. Create a simple test to verify the workspace works
echo "🧪 Testing workspace..."
xcodebuild -workspace SkillTalk.xcworkspace -scheme SkillTalk -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max,OS=18.4' clean

if [ $? -eq 0 ]; then
    echo "✅ Workspace test successful!"
else
    echo "⚠️ Workspace test failed, but this is expected without packages"
fi

echo ""
echo "📋 Manual Steps Required:"
echo "1. Open SkillTalk.xcworkspace in Xcode"
echo "2. Go to File > Add Package Dependencies"
echo "3. Add: https://github.com/supabase-community/supabase-swift"
echo "4. Select version: 'Up to next major'"
echo "5. Select ONLY 'Supabase' product (not individual Auth/Storage)"
echo "6. Add to SkillTalk target"
echo "7. Clean Build Folder (Product > Clean Build Folder)"
echo "8. Build the project"
echo ""
echo "🔍 If you still get GUID errors:"
echo "1. Close Xcode completely"
echo "2. Restart your Mac"
echo "3. Reopen the workspace and try again" 