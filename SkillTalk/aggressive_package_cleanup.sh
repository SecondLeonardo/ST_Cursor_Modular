#!/bin/bash

# Aggressive package dependency cleanup script
echo "🧹 Performing aggressive package dependency cleanup..."

# Navigate to project directory
cd "$(dirname "$0")"

# 1. Kill all Xcode processes
echo "🔄 Killing Xcode processes..."
pkill -f "Xcode" || true
sleep 2

# 2. Clean all possible caches
echo "🧹 Cleaning all caches..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/com.apple.dt.Xcode/*
rm -rf ~/Library/Developer/Xcode/UserData/IDEPreferencesController.xcuserstate
rm -rf ~/Library/Developer/Xcode/UserData/IDEWorkspaceChecks.plist

# 3. Remove all package-related files
echo "🗑️ Removing package references..."
rm -rf SkillTalk.xcworkspace/xcshareddata/swiftpm
rm -rf SkillTalk.xcodeproj/project.xcworkspace/xcshareddata/swiftpm
find . -name "Package.resolved" -delete
find . -name "*.xcodeproj" -exec rm -rf {}/project.xcworkspace/xcshareddata/swiftpm \; 2>/dev/null || true

# 4. Clean CocoaPods completely
echo "🧹 Cleaning CocoaPods..."
pod deintegrate
pod cache clean --all
rm -rf Pods/
rm -f Podfile.lock

# 5. Remove any remaining package references from project files
echo "🔧 Cleaning project files..."

# Create a backup of the project file
cp SkillTalk.xcodeproj/project.pbxproj SkillTalk.xcodeproj/project.pbxproj.backup

# Remove package references from project file using sed
sed -i '' '/XCRemoteSwiftPackageReference/d' SkillTalk.xcodeproj/project.pbxproj
sed -i '' '/XCSwiftPackageProductDependency/d' SkillTalk.xcodeproj/project.pbxproj
sed -i '' '/packageProductDependencies/d' SkillTalk.xcodeproj/project.pbxproj

# 6. Reinstall CocoaPods
echo "📦 Reinstalling CocoaPods..."
pod install --repo-update

# 7. Create a clean workspace state
echo "🔧 Creating clean workspace state..."
mkdir -p SkillTalk.xcworkspace/xcshareddata/swiftpm

# 8. Create instructions for manual package addition
cat > MANUAL_PACKAGE_SETUP.md << 'EOF'
# Manual Package Setup Instructions

## After running the cleanup script:

1. **Open SkillTalk.xcworkspace** in Xcode (NOT .xcodeproj)
2. **Wait for Xcode to fully load** (this may take a minute)
3. **Go to File > Add Package Dependencies**
4. **Add Supabase package:**
   - URL: `https://github.com/supabase-community/supabase-swift`
   - Version: "Up to next major" (latest stable)
   - Product: Select ONLY "Supabase" (not individual Auth/Storage products)
   - Target: Add to "SkillTalk" target
5. **Clean Build Folder** (Product > Clean Build Folder)
6. **Build the project** (Cmd+B)

## Important Notes:
- Do NOT add multiple versions of the same package
- Do NOT add individual Auth/Storage products separately
- The main Supabase package includes all necessary components
- If you see any duplicate entries, remove them first

## If you still get GUID errors:
1. Close Xcode completely
2. Delete ~/Library/Developer/Xcode/DerivedData
3. Reopen the workspace and try again
EOF

echo "✅ Aggressive cleanup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Open SkillTalk.xcworkspace in Xcode"
echo "2. Follow the instructions in MANUAL_PACKAGE_SETUP.md"
echo "3. Add Supabase package manually"
echo ""
echo "🔍 If you still encounter issues:"
echo "1. Close Xcode completely"
echo "2. Delete ~/Library/Developer/Xcode/DerivedData"
echo "3. Restart your Mac if necessary"
echo "4. Reopen the workspace and try again" 