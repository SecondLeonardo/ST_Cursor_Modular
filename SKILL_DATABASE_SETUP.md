# Skill Database Setup Guide

This guide will help you set up a complete multi-provider skill database system with Supabase as primary and Firebase as fallback.

## 🎯 Overview

The system uses a **multi-provider strategy** (R0.9) with:
- **Primary**: Supabase (PostgreSQL)
- **Fallback**: Firebase (Firestore)
- **Local**: JSON files (offline backup)

## 📋 Prerequisites

1. **Supabase Account**: [supabase.com](https://supabase.com)
2. **Firebase Account**: [firebase.google.com](https://firebase.google.com)
3. **Python 3.7+**: For the upload script
4. **Your skill database**: Located in `/database/languages/`

## 🚀 Step-by-Step Setup

### 1. Set Up Supabase

#### 1.1 Create Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Note your project URL and API key

#### 1.2 Create Database Tables
Run the upload script to generate the SQL:

```bash
python upload_skill_database.py --create-tables
```

Copy the generated SQL and run it in your Supabase SQL editor.

#### 1.3 Configure Row Level Security (RLS)
In Supabase SQL editor, run:

```sql
-- Enable RLS on all tables
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE subcategories ENABLE ROW LEVEL SECURITY;
ALTER TABLE skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE languages ENABLE ROW LEVEL SECURITY;

-- Create policies for public read access
CREATE POLICY "Allow public read access" ON categories FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON subcategories FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON skills FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON languages FOR SELECT USING (true);
```

### 2. Set Up Firebase

#### 2.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project
3. Enable Firestore Database
4. Set up security rules for public read access

#### 2.2 Configure Firestore Security Rules
In Firebase Console > Firestore Database > Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow public read access to skills data
    match /skills/{document=**} {
      allow read: if true;
    }
    
    // Allow public read access to metadata
    match /metadata/{document} {
      allow read: if true;
    }
  }
}
```

#### 2.3 Download Service Account Key
1. Go to Project Settings > Service Accounts
2. Generate new private key
3. Save as `serviceAccountKey.json`

### 3. Upload Your Database

#### 3.1 Install Python Dependencies
```bash
pip install requests firebase-admin
```

#### 3.2 Upload to Both Services
```bash
# Upload all languages
python upload_skill_database.py \
  --supabase-url "https://your-project.supabase.co/rest/v1" \
  --supabase-key "your-supabase-anon-key" \
  --firebase-project "your-firebase-project-id"

# Or upload specific language
python upload_skill_database.py \
  --supabase-url "https://your-project.supabase.co/rest/v1" \
  --supabase-key "your-supabase-anon-key" \
  --firebase-project "your-firebase-project-id" \
  --language "en"
```

### 4. Configure iOS App

#### 4.1 Update Configuration
Edit `SkillTalk/Core/Services/Configuration/SkillDatabaseConfiguration.swift`:

```swift
struct Supabase {
    static let baseURL = "https://your-project.supabase.co/rest/v1"
    static let apiKey = "your-supabase-anon-key"
}

struct Firebase {
    static let projectID = "your-firebase-project-id"
}
```

#### 4.2 Initialize Multi-Provider Service
In your app initialization:

```swift
// Create individual services
let supabaseService = SupabaseSkillDatabaseService(
    baseURL: SkillDatabaseConfiguration.Supabase.baseURL,
    apiKey: SkillDatabaseConfiguration.Supabase.apiKey
)

let firebaseService = FirebaseSkillDatabaseService()

let localService = LocalSkillService()

// Create multi-provider service
let skillDatabaseService = MultiSkillDatabaseService(
    primaryService: supabaseService,
    fallbackService: firebaseService,
    localService: localService
)
```

#### 4.3 Update OnboardingViewModel
Replace the current skill service with the multi-provider service:

```swift
class OnboardingViewModel: ObservableObject {
    private let skillDatabaseService: SkillDatabaseServiceProtocol
    
    init(skillDatabaseService: SkillDatabaseServiceProtocol = MultiSkillDatabaseService(
        primaryService: SupabaseSkillDatabaseService(
            baseURL: SkillDatabaseConfiguration.Supabase.baseURL,
            apiKey: SkillDatabaseConfiguration.Supabase.apiKey
        ),
        fallbackService: FirebaseSkillDatabaseService(),
        localService: LocalSkillService()
    )) {
        self.skillDatabaseService = skillDatabaseService
    }
    
    // Update your skill loading methods to use skillDatabaseService
}
```

## 🔧 Testing

### 1. Test Supabase Connection
```bash
curl -X GET "https://your-project.supabase.co/rest/v1/categories?language=eq.en" \
  -H "apikey: your-supabase-anon-key" \
  -H "Authorization: Bearer your-supabase-anon-key"
```

### 2. Test Firebase Connection
```bash
# Use Firebase CLI or test in console
firebase firestore:get /skills/categories/en
```

### 3. Test iOS App
1. Build and run the app
2. Go through onboarding
3. Check console logs for service usage
4. Verify skills are loading from the correct provider

## 📊 Monitoring

The multi-provider service includes health monitoring:

```swift
// Check service health
let health = await skillDatabaseService.checkHealth()
print("Service health: \(health)")

// Get service statistics
let stats = await skillDatabaseService.getServiceStats()
print("Total skills: \(stats.totalSkills)")
```

## 🚨 Troubleshooting

### Common Issues

#### 1. Supabase Connection Failed
- Check your project URL and API key
- Verify RLS policies are configured correctly
- Check network connectivity

#### 2. Firebase Connection Failed
- Verify Firebase project ID
- Check service account key is valid
- Ensure Firestore is enabled

#### 3. No Skills Loading
- Check console logs for provider fallback
- Verify database upload was successful
- Test individual services

#### 4. Performance Issues
- Check cache configuration
- Monitor network requests
- Consider preloading popular data

### Debug Commands

```bash
# Test Supabase tables
curl -X GET "https://your-project.supabase.co/rest/v1/categories" \
  -H "apikey: your-key"

# Test Firebase collections
firebase firestore:get /skills/categories/en

# Check database files
ls -la database/languages/en/
```

## 📈 Performance Optimization

### 1. Caching Strategy
- Categories: 1 hour cache
- Skills: 1 hour cache
- Popular skills: 30 minutes cache

### 2. Preloading
```swift
// Preload user's language
await skillDatabaseService.preloadLanguage("en")
```

### 3. Batch Loading
- Load categories first
- Load subcategories on demand
- Load skills in batches

## 🔒 Security Considerations

### 1. API Keys
- Store keys securely (not in source code)
- Use environment variables
- Rotate keys regularly

### 2. Data Access
- Read-only access for skill data
- No user data in skill database
- Separate user data storage

### 3. Rate Limiting
- Implement request throttling
- Monitor API usage
- Set up alerts for abuse

## 📝 Next Steps

1. **Set up monitoring**: Add analytics for service usage
2. **Implement caching**: Add persistent local cache
3. **Add offline support**: Sync when online
4. **Optimize queries**: Add database indexes
5. **Add translations**: Implement multi-language support

## 🆘 Support

If you encounter issues:

1. Check the console logs for error messages
2. Verify your configuration is correct
3. Test individual services separately
4. Check the troubleshooting section above
5. Review the service health monitoring

---

**Remember**: The multi-provider strategy ensures your app will always have access to skill data, even if one service is down! 