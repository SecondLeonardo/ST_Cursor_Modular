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
