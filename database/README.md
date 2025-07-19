# SkillTalk Optimized Database

This directory contains the optimized database structure for the SkillTalk application.

## Structure

- `core/`: Core data without translations
- `languages/`: Language-specific translations
- `indexes/`: Indexes for quick lookups
- `metadata.json`: Database metadata
- `languages.json`: Available languages
- `cache_config.json`: Caching configuration
- `api_docs.json`: API documentation

## Usage

### Lazy Loading Pattern

1. Load the category list for the selected language
2. When a category is selected, load its subcategories
3. When a subcategory is selected, load its skills

### Language-Specific Loading

```dart
// Example in Flutter
final String languageCode = 'en'; // Current app language
final String categoryId = 'academic_intellectual';

// Load category with subcategories
final categoryData = await loadJsonFile('languages/$languageCode/hierarchy/$categoryId.json');

// When user selects a subcategory
final subcategoryId = 'academic_intellectual_economics';
final subcategoryData = await loadJsonFile('languages/$languageCode/hierarchy/$categoryId/$subcategoryId.json');
```

## Caching Strategy

Cache loaded data locally using Hive, Isar, or SharedPreferences to reduce network requests.

```dart
// Example caching in Flutter
Future<Map<String, dynamic>> loadCategoryData(String categoryId) async {
  final String cacheKey = 'category_$categoryId';
  
  // Check cache first
  final cachedData = await cacheService.get(cacheKey);
  if (cachedData != null) {
    return cachedData;
  }
  
  // If not in cache, load from network
  final data = await networkService.loadData('hierarchy/$categoryId.json');
  
  // Save to cache
  await cacheService.set(cacheKey, data, duration: Duration(days: 7));
  
  return data;
}
```

## Performance Considerations

- Load only what you need when you need it
- Cache frequently accessed data locally
- Use indexes for filtered queries
- Implement pagination for large subcategories
