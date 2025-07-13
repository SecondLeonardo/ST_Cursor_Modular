# Skill Database Configuration

This directory contains configuration files for the SkillTalk skill database services.

## Security Notice

⚠️ **Never commit sensitive credentials to version control!**

The Firebase service account credentials file has been removed from git and added to `.gitignore` to prevent accidental exposure.

## Configuration Setup

### 1. Environment Variables (Recommended)

Set these environment variables in your development environment:

```bash
# Supabase Configuration
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_ANON_KEY="your-anon-key"
export SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"

# Firebase Configuration
export FIREBASE_PROJECT_ID="your-project-id"
```

### 2. Firebase Service Account (Development Only)

For local development, place your Firebase service account JSON file in the app bundle:

1. Download your Firebase service account key from the Firebase Console
2. Rename it to `firebase-adminsdk.json` or keep the original name
3. Add it to your Xcode project (drag and drop into the project)
4. Make sure it's added to your app target
5. The file will be automatically detected by the configuration

**Important**: This file should only be used for development. In production, use environment variables or secure key management.

### 3. Configuration Validation

The app will automatically validate your configuration on startup:

```swift
let status = SkillDatabaseConfig.status
switch status {
case .valid:
    print("✅ Configuration is valid")
case .partial(let errors):
    print("⚠️ Configuration is partially valid: \(errors)")
case .invalid(let errors):
    print("❌ Configuration is invalid: \(errors)")
}
```

## Service Priority

The multi-provider service uses this priority order:

1. **Supabase** (Primary) - Fast, reliable, with real-time capabilities
2. **Firebase** (Fallback) - Backup service if Supabase is unavailable
3. **Local JSON** (Last Resort) - Bundled data if both cloud services fail

## Health Monitoring

You can monitor service health using the `SkillServiceHealthView`:

- Check service status and response times
- View cache statistics
- Clear caches when needed
- Test individual services

## Troubleshooting

### Common Issues

1. **"SUPABASE_URL not configured"**
   - Set the `SUPABASE_URL` environment variable
   - Or update the default value in `SkillDatabaseConfig.swift`

2. **"FIREBASE_PROJECT_ID not configured"**
   - Set the `FIREBASE_PROJECT_ID` environment variable
   - Or update the default value in `SkillDatabaseConfig.swift`

3. **Firebase service account not found**
   - Ensure the JSON file is added to your Xcode project
   - Check that it's included in your app target
   - Verify the file name matches the expected pattern

### Debug Mode

In debug builds, you can access the service health monitor from the skill selection screen (look for the heart icon).

## Production Deployment

For production deployment:

1. Use environment variables for all sensitive configuration
2. Never include service account files in the app bundle
3. Use secure key management services (AWS Secrets Manager, Azure Key Vault, etc.)
4. Enable proper authentication and authorization
5. Monitor service health and performance

## Support

If you encounter configuration issues:

1. Check the console logs for detailed error messages
2. Verify your environment variables are set correctly
3. Test individual services using the health monitor
4. Review the service logs for specific error details 