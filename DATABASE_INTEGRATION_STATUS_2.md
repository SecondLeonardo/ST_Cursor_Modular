# SkillTalk Database Integration plan

Great, here’s a focused, step-by-step plan to **fully complete Step 1.3: Database Integration** for SkillTalk, using the provided references and following your modular architecture. I’ll break down the work into clear, actionable sub-steps, and for each, I’ll describe the implementation approach and what code/files need to be created or updated. **No UI code will be added outside the module’s scope.**

---

## **Step 1.3: Database Integration — Implementation Plan**

### **1. Integrate Skill Database from `/database` Directory (Server-Side, Not Bundled)**

#### **A. Server-Side API (Not Bundled)**
- **Goal:** The iOS app should fetch skills, categories, subcategories, and translations from a server API, not from bundled files.
- **Action:**
  - If you don’t have a backend yet, create a minimal REST API (Node.js, Vapor, or Python FastAPI) that exposes endpoints:
    - `/api/skills/categories`
    - `/api/skills/subcategories?categoryId=`
    - `/api/skills?subcategoryId=`
    - `/api/skills/translations?lang=`
    - `/api/languages`
    - `/api/countries`
    - `/api/cities`
    - `/api/occupations`
    - `/api/hobbies`
  - The API should read from the `/database` directory and return JSON.

#### **B. iOS Data Layer**
- **Goal:** All skill data is loaded from the server API, not from local files.
- **Action:**
  - In `SkillTalk/SkillTalk/Data/Services/ReferenceData/`, create or update:
    - `SkillAPIService.swift` (handles all API calls for skills, categories, subcategories, translations)
    - `ReferenceDataService.swift` (handles API calls for languages, countries, cities, occupations, hobbies)
  - Use `URLSession` for network requests, and Codable models for parsing.

---

### **2. Implement Complete Reference Data Services**

- **Goal:** Provide services for languages, countries, cities, occupations, and hobbies.
- **Action:**
  - In `ReferenceDataService.swift`, add methods:
    - `fetchLanguages()`
    - `fetchCountries()`
    - `fetchCities(countryCode: String)`
    - `fetchOccupations()`
    - `fetchHobbies()`
  - Each method should call the corresponding API endpoint and cache results in memory for performance.

---

### **3. Fix Language Database to Show Actual Language Names**

- **Goal:** Users see language names (e.g., "English", "Español"), not codes.
- **Action:**
  - Ensure the `/database/languages.json` or `/api/languages` returns both code and display name.
  - In your models, use:
    ```swift
    struct Language: Codable {
        let code: String
        let name: String
    }
    ```
  - Update all language selection logic to use `name` for display.

---

### **4. Create Proper Skill Database Service with Caching and Optimization**

- **Goal:** Efficient, optimized access to skill data with caching.
- **Action:**
  - In `SkillAPIService.swift`, implement:
    - In-memory cache for categories, subcategories, and skills (with TTL, e.g., 1 hour).
    - Lazy loading: only fetch subcategories/skills when needed.
    - Methods:
      - `fetchCategories(language: String)`
      - `fetchSubcategories(categoryId: String, language: String)`
      - `fetchSkills(subcategoryId: String, language: String)`
      - `searchSkills(query: String, language: String)`
      - `fetchPopularSkills(language: String, limit: Int)`
  - Use the structure and best practices from `@prd_core_feature_part2.txt` and `@skill system`.

---

### **5. Implement Skill Search and Filtering Functionality**

- **Goal:** Allow searching and filtering skills by name, tag, popularity, etc.
- **Action:**
  - In `SkillAPIService.swift`, add:
    - `searchSkills(query: String, language: String, filters: [String: String])`
  - The API should support search and filtering (if not, implement it server-side or filter client-side after fetching).

---

### **6. Add Skill Selection UI Components for Onboarding and Profile (Module-Scoped Only)**

- **Goal:** Only add UI components that are part of this module, following the modular plan.
- **Action:**
  - In the onboarding/profile module, add:
    - `SkillCategorySelectorView`
    - `SkillSubcategorySelectorView`
    - `SkillSelectorView`
  - Each view should use the services above to fetch and display data, using progressive disclosure (Category → Subcategory → Skill).
  - **Do not add UI for other modules.**

---

### **7. Create Skill Compatibility Matrix for Matching**

- **Goal:** Provide a service to calculate compatibility between skills.
- **Action:**
  - In `SkillCompatibilityService.swift` (new file in Data/Services), implement:
    - `calculateCompatibility(expertSkillId: String, targetSkillId: String) -> Float`
    - Use the compatibility matrix from `/database/indexes/` or fetch from `/api/skills/compatibility?expertSkillId=&targetSkillId=`
    - Use the logic from `@prd_skills_matching.txt` and `@skill system`.

---

### **8. Implement Progressive Disclosure for Skill Selection**

- **Goal:** Users select skills step-by-step: Category → Subcategory → Skill.
- **Action:**
  - The UI components above should only show the next level after the previous is selected.
  - Use the data services to fetch only what’s needed at each step.

---

### **9. Add Skill Analytics and Tracking**

- **Goal:** Track skill selection, search, and matching analytics.
- **Action:**
  - In `SkillAnalyticsService.swift` (new file in Data/Services), implement:
    - `trackSkillSelectionTime(start: Date, end: Date)`
    - `trackSkillSearch(query: String, resultCount: Int)`
    - `trackSkillMatch(expertSkillId: String, targetSkillId: String, compatibility: Float)`
  - Send analytics to your backend or log locally for now.

---

### **10. Create Data Access Layer with Repository Pattern**

- **Goal:** All data access goes through repositories, not directly through services.
- **Action:**
  - In `Data/Repository/`, create or update:
    - `SkillRepository.swift`
    - `ReferenceDataRepository.swift`
  - Each repository should use the corresponding service and expose only the needed methods to the rest of the app.

---

### **11. Implement Offline Caching for Skill Database**

- **Goal:** App works offline with last-fetched data.
- **Action:**
  - Use `UserDefaults` or local file storage to cache the last successful API responses.
  - On app launch, load from cache if offline, and update cache when online.

---

### **12. Add Skill Database Health Monitoring and Failover**

- **Goal:** Detect and handle API failures gracefully.
- **Action:**
  - In each service, add error handling and fallback to offline cache if API is unavailable.
  - Optionally, implement a health check endpoint on the server and monitor it in the app.

---

## **Summary Table: Files/Classes to Create or Update**

| File/Service                        | Purpose                                      |
|--------------------------------------|----------------------------------------------|
| SkillAPIService.swift                | Fetch skills/categories/subcategories        |
| ReferenceDataService.swift           | Fetch languages/countries/cities/occupations |
| SkillRepository.swift                | Repository for skill data                    |
| ReferenceDataRepository.swift        | Repository for reference data                |
| SkillCompatibilityService.swift      | Calculate skill compatibility                |
| SkillAnalyticsService.swift          | Track analytics                              |
| SkillCategorySelectorView.swift      | UI: Select category (module only)            |
| SkillSubcategorySelectorView.swift   | UI: Select subcategory (module only)         |
| SkillSelectorView.swift              | UI: Select skill (module only)               |

---

## **Next Steps**

1. **Start with the server API if not already present.**
2. **Implement the data and repository layers as described.**
3. **Add only the UI components for skill selection, scoped to this module.**
4. **Test with real data from the `/database` directory via the API.**
5. **Add analytics, offline caching, and health monitoring.**

---

**Ready for code implementation? Let me know which part you want to start with, or if you want code templates for any of the above files!**
