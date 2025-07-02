import Foundation

/// LocalizationHelper provides utility functions for managing multi-language support
/// across all reference databases in SkillTalk
class LocalizationHelper {
    
    // MARK: - Singleton
    static let shared = LocalizationHelper()
    private init() {}
    
    // MARK: - Supported Languages
    
    /// Complete list of the 30 languages supported by SkillTalk
    /// Updated to match the exact language codes from the server database
    static let supportedLanguages = [
        "en", "es", "fr", "de", "it", "pt", "ru", "zh", "ja", "ko",
        "ar", "hi", "bn", "tr", "nl", "pl", "sv", "vi", "th", "id", 
        "fa", "pa", "sw", "ha", "am", "yo", "te", "mr", "ta", "gu"
    ]
    
    /// Get the current system language code
    static var systemLanguage: String {
        return Locale.current.languageCode ?? "en"
    }
    
    /// Get the appropriate fallback language for a given language code
    static func getFallbackLanguage(for languageCode: String) -> String {
        // If the requested language is supported, use it
        if supportedLanguages.contains(languageCode) {
            return languageCode
        }
        
        // Otherwise, try common fallbacks
        switch languageCode {
        case "zh-CN", "zh-Hans", "cmn":
            return "zh"
        case "zh-TW", "zh-Hant":
            return "zh"
        case "pt-BR", "pt-PT":
            return "pt"
        case "es-ES", "es-MX", "es-AR":
            return "es"
        default:
            return "en" // Default to English
        }
    }
    
    /// Get supported language code (with fallback logic)
    static func getSupportedLanguageCode(for languageCode: String) -> String {
        return getFallbackLanguage(for: languageCode)
    }
    
    /// Validate if a language code is supported
    static func isLanguageSupported(_ languageCode: String) -> Bool {
        return supportedLanguages.contains(languageCode)
    }
    
    // MARK: - Translation Management
    
    /// Create a LocalizedString with sample translations for common languages
    static func createLocalizedString(
        englishText: String,
        translations: [String: String] = [:]
    ) -> LocalizedString {
        var allTranslations = translations
        allTranslations["en"] = englishText
        
        return LocalizedString(
            defaultText: englishText,
            defaultLanguage: "en",
            translations: allTranslations
        )
    }
    
    /// Get the best available translation for a localized string
    static func getBestTranslation(
        from localizedString: LocalizedString,
        for languageCode: String
    ) -> String {
        let targetLanguage = getFallbackLanguage(for: languageCode)
        return localizedString.localized(for: targetLanguage)
    }
    
    // MARK: - Language Names Helper
    
    /// Get localized language names for the language selection UI
    static func getLanguageDisplayNames(localizedFor languageCode: String = "en") -> [String: String] {
        // This would eventually be populated from a translation file
        // For now, return English names as a starting point
        return [
            "en": "English",
            "es": "Spanish", 
            "fr": "French",
            "de": "German",
            "zh": "Chinese",
            "ar": "Arabic",
            "ru": "Russian",
            "ja": "Japanese",
            "pt": "Portuguese",
            "hi": "Hindi",
            "ko": "Korean",
            "it": "Italian",
            "tr": "Turkish",
            "fa": "Persian",
            "th": "Thai",
            "vi": "Vietnamese",
            "pl": "Polish",
            "nl": "Dutch",
            "sv": "Swedish",
            "da": "Danish",
            "no": "Norwegian",
            "fi": "Finnish",
            "he": "Hebrew",
            "uk": "Ukrainian",
            "cs": "Czech",
            "hu": "Hungarian",
            "el": "Greek",
            "bg": "Bulgarian",
            "hr": "Croatian",
            "sk": "Slovak"
        ]
    }
    
    // MARK: - Country Names Helper
    
    /// Get sample translations for common countries
    /// This demonstrates how country name translations would be structured
    static func getSampleCountryTranslations() -> [String: [String: String]] {
        return [
            "us": [
                "en": "United States",
                "es": "Estados Unidos",
                "fr": "États-Unis",
                "de": "Vereinigte Staaten",
                "zh": "美国",
                "ar": "الولايات المتحدة",
                "ru": "Соединенные Штаты",
                "ja": "アメリカ合衆国"
            ],
            "gb": [
                "en": "United Kingdom", 
                "es": "Reino Unido",
                "fr": "Royaume-Uni",
                "de": "Vereinigtes Königreich",
                "zh": "英国",
                "ar": "المملكة المتحدة",
                "ru": "Великобритания",
                "ja": "イギリス"
            ],
            "ca": [
                "en": "Canada",
                "es": "Canadá", 
                "fr": "Canada",
                "de": "Kanada",
                "zh": "加拿大",
                "ar": "كندا",
                "ru": "Канада",
                "ja": "カナダ"
            ],
            "de": [
                "en": "Germany",
                "es": "Alemania",
                "fr": "Allemagne", 
                "de": "Deutschland",
                "zh": "德国",
                "ar": "ألمانيا",
                "ru": "Германия",
                "ja": "ドイツ"
            ],
            "fr": [
                "en": "France",
                "es": "Francia",
                "fr": "France",
                "de": "Frankreich",
                "zh": "法国", 
                "ar": "فرنسا",
                "ru": "Франция",
                "ja": "フランス"
            ],
            "jp": [
                "en": "Japan",
                "es": "Japón",
                "fr": "Japon",
                "de": "Japan",
                "zh": "日本",
                "ar": "اليابان",
                "ru": "Япония",
                "ja": "日本"
            ],
            "cn": [
                "en": "China",
                "es": "China",
                "fr": "Chine",
                "de": "China",
                "zh": "中国",
                "ar": "الصين",
                "ru": "Китай",
                "ja": "中国"
            ],
            "br": [
                "en": "Brazil",
                "es": "Brasil",
                "fr": "Brésil",
                "de": "Brasilien",
                "zh": "巴西",
                "ar": "البرازيل",
                "ru": "Бразилия",
                "ja": "ブラジル"
            ],
            "ru": [
                "en": "Russia",
                "es": "Rusia",
                "fr": "Russie",
                "de": "Russland",
                "zh": "俄罗斯",
                "ar": "روسيا",
                "ru": "Россия",
                "ja": "ロシア"
            ],
            "in": [
                "en": "India",
                "es": "India",
                "fr": "Inde",
                "de": "Indien",
                "zh": "印度",
                "ar": "الهند",
                "ru": "Индия",
                "ja": "インド"
            ],
            "kr": [
                "en": "South Korea",
                "es": "Corea del Sur",
                "fr": "Corée du Sud",
                "de": "Südkorea",
                "zh": "韩国",
                "ar": "كوريا الجنوبية",
                "ru": "Южная Корея",
                "ja": "韓国"
            ]
        ]
    }
    
    // MARK: - City Names Helper
    
    /// Get sample translations for major cities
    /// This demonstrates how city name translations would be structured
    static func getSampleCityTranslations() -> [String: [String: String]] {
        return [
            "nyc-us": [
                "en": "New York",
                "es": "Nueva York",
                "fr": "New York",
                "de": "New York",
                "zh": "纽约",
                "ar": "نيويورك",
                "ru": "Нью-Йорк",
                "ja": "ニューヨーク"
            ],
            "london-gb": [
                "en": "London",
                "es": "Londres",
                "fr": "Londres",
                "de": "London",
                "zh": "伦敦",
                "ar": "لندن",
                "ru": "Лондон",
                "ja": "ロンドン"
            ],
            "tokyo-jp": [
                "en": "Tokyo",
                "es": "Tokio",
                "fr": "Tokyo",
                "de": "Tokio",
                "zh": "东京",
                "ar": "طوكيو",
                "ru": "Токио",
                "ja": "東京"
            ],
            "paris-fr": [
                "en": "Paris",
                "es": "París",
                "fr": "Paris",
                "de": "Paris",
                "zh": "巴黎",
                "ar": "باريس",
                "ru": "Париж",
                "ja": "パリ"
            ],
            "berlin-de": [
                "en": "Berlin",
                "es": "Berlín",
                "fr": "Berlin",
                "de": "Berlin",
                "zh": "柏林",
                "ar": "برلين",
                "ru": "Берлин",
                "ja": "ベルリン"
            ],
            "moscow-ru": [
                "en": "Moscow",
                "es": "Moscú",
                "fr": "Moscou",
                "de": "Moskau",
                "zh": "莫斯科",
                "ar": "موسكو",
                "ru": "Москва",
                "ja": "モスクワ"
            ],
            "beijing-cn": [
                "en": "Beijing",
                "es": "Pekín",
                "fr": "Pékin",
                "de": "Peking",
                "zh": "北京",
                "ar": "بكين",
                "ru": "Пекин",
                "ja": "北京"
            ],
            "seoul-kr": [
                "en": "Seoul",
                "es": "Seúl",
                "fr": "Séoul",
                "de": "Seoul",
                "zh": "首尔",
                "ar": "سيول",
                "ru": "Сеул",
                "ja": "ソウル"
            ],
            "mumbai-in": [
                "en": "Mumbai",
                "es": "Bombay",
                "fr": "Mumbai",
                "de": "Mumbai",
                "zh": "孟买",
                "ar": "مومباي",
                "ru": "Мумбаи",
                "ja": "ムンバイ"
            ],
            "toronto-ca": [
                "en": "Toronto",
                "es": "Toronto",
                "fr": "Toronto",
                "de": "Toronto",
                "zh": "多伦多",
                "ar": "تورونتو",
                "ru": "Торонто",
                "ja": "トロント"
            ]
        ]
    }
    
    // MARK: - Occupation Names Helper
    
    /// Get sample translations for common occupations
    /// This demonstrates how occupation translations would be structured  
    static func getSampleOccupationTranslations() -> [String: [String: String]] {
        return [
            "software_engineer": [
                "en": "Software Engineer",
                "es": "Ingeniero de Software",
                "fr": "Ingénieur Logiciel",
                "de": "Software-Ingenieur",
                "zh": "软件工程师",
                "ar": "مهندس برمجيات",
                "ru": "Инженер-программист",
                "ja": "ソフトウェアエンジニア"
            ],
            "doctor": [
                "en": "Doctor",
                "es": "Médico",
                "fr": "Médecin",
                "de": "Arzt",
                "zh": "医生",
                "ar": "طبيب",
                "ru": "Врач",
                "ja": "医師"
            ],
            "teacher": [
                "en": "Teacher",
                "es": "Maestro",
                "fr": "Enseignant",
                "de": "Lehrer",
                "zh": "教师",
                "ar": "معلم",
                "ru": "Учитель",
                "ja": "教師"
            ],
            "lawyer": [
                "en": "Lawyer",
                "es": "Abogado",
                "fr": "Avocat",
                "de": "Anwalt",
                "zh": "律师",
                "ar": "محامي",
                "ru": "Юрист",
                "ja": "弁護士"
            ],
            "nurse": [
                "en": "Nurse",
                "es": "Enfermero",
                "fr": "Infirmier",
                "de": "Krankenpfleger",
                "zh": "护士",
                "ar": "ممرض",
                "ru": "Медсестра",
                "ja": "看護師"
            ]
        ]
    }
    
    // MARK: - Future Translation Loading
    
    /// Placeholder for future translation file loading
    /// This would load translations from JSON files organized by language
    static func loadTranslationsFromFile(
        for resourceType: ReferenceDataType,
        languageCode: String
    ) async throws -> [String: String] {
        // Future implementation would load from:
        // translations/{languageCode}/{resourceType}.json
        
        // For now, return empty dictionary
        return [:]
    }
    
    // MARK: - Sample Hobby Translations
    
    /// Sample translations for popular hobbies across multiple languages
    /// These demonstrate the multi-language capability for hobby localization
    static let hobbyTranslations: [String: LocalizedString] = [
        
        // Popular Technology Hobbies
        "programming": LocalizedString(englishName: "Programming", translations: [
            "es": "Programación",
            "fr": "Programmation", 
            "de": "Programmierung",
            "it": "Programmazione",
            "pt": "Programação",
            "ja": "プログラミング",
            "ko": "프로그래밍",
            "zh": "编程"
        ]),
        
        "photography": LocalizedString(englishName: "Photography", translations: [
            "es": "Fotografía",
            "fr": "Photographie",
            "de": "Fotografie", 
            "it": "Fotografia",
            "pt": "Fotografia",
            "ja": "写真撮影",
            "ko": "사진",
            "zh": "摄影"
        ]),
        
        "video-games": LocalizedString(englishName: "Video Games", translations: [
            "es": "Videojuegos",
            "fr": "Jeux Vidéo",
            "de": "Videospiele",
            "it": "Videogiochi", 
            "pt": "Videogames",
            "ja": "ビデオゲーム",
            "ko": "비디오 게임",
            "zh": "电子游戏"
        ]),
        
        // Popular Arts & Creative Hobbies
        "painting": LocalizedString(englishName: "Painting", translations: [
            "es": "Pintura",
            "fr": "Peinture",
            "de": "Malerei",
            "it": "Pittura",
            "pt": "Pintura",
            "ja": "絵画",
            "ko": "그림",
            "zh": "绘画"
        ]),
        
        "music": LocalizedString(englishName: "Music", translations: [
            "es": "Música",
            "fr": "Musique",
            "de": "Musik",
            "it": "Musica",
            "pt": "Música",
            "ja": "音楽",
            "ko": "음악",
            "zh": "音乐"
        ]),
        
        "guitar": LocalizedString(englishName: "Guitar", translations: [
            "es": "Guitarra",
            "fr": "Guitare",
            "de": "Gitarre",
            "it": "Chitarra",
            "pt": "Violão",
            "ja": "ギター",
            "ko": "기타",
            "zh": "吉他"
        ]),
        
        // Popular Sports & Fitness Hobbies
        "swimming": LocalizedString(englishName: "Swimming", translations: [
            "es": "Natación",
            "fr": "Natation",
            "de": "Schwimmen",
            "it": "Nuoto",
            "pt": "Natação",
            "ja": "水泳",
            "ko": "수영",
            "zh": "游泳"
        ]),
        
        "running": LocalizedString(englishName: "Running", translations: [
            "es": "Correr",
            "fr": "Course",
            "de": "Laufen",
            "it": "Corsa",
            "pt": "Corrida",
            "ja": "ランニング",
            "ko": "달리기", 
            "zh": "跑步"
        ]),
        
        "yoga": LocalizedString(englishName: "Yoga", translations: [
            "es": "Yoga",
            "fr": "Yoga",
            "de": "Yoga",
            "it": "Yoga",
            "pt": "Yoga",
            "ja": "ヨガ",
            "ko": "요가",
            "zh": "瑜伽"
        ]),
        
        // Popular Learning & Social Hobbies
        "reading": LocalizedString(englishName: "Reading", translations: [
            "es": "Lectura",
            "fr": "Lecture",
            "de": "Lesen",
            "it": "Lettura",
            "pt": "Leitura",
            "ja": "読書",
            "ko": "독서",
            "zh": "阅读"
        ]),
        
        "cooking": LocalizedString(englishName: "Cooking", translations: [
            "es": "Cocina",
            "fr": "Cuisine",
            "de": "Kochen",
            "it": "Cucina",
            "pt": "Cozinha",
            "ja": "料理",
            "ko": "요리",
            "zh": "烹饪"
        ]),
        
        "travel": LocalizedString(englishName: "Travel", translations: [
            "es": "Viajes",
            "fr": "Voyage", 
            "de": "Reisen",
            "it": "Viaggi",
            "pt": "Viagem",
            "ja": "旅行",
            "ko": "여행",
            "zh": "旅行"
        ]),
        
        "movies": LocalizedString(englishName: "Movies", translations: [
            "es": "Películas",
            "fr": "Films",
            "de": "Filme",
            "it": "Film",
            "pt": "Filmes",
            "ja": "映画",
            "ko": "영화",
            "zh": "电影"
        ])
    ]
    
    // MARK: - Sample Category Translations
    
    /// Sample translations for hobby categories 
    static let hobbyCategories: [String: LocalizedString] = [
        "Sports": LocalizedString(englishName: "Sports", translations: [
            "es": "Deportes",
            "fr": "Sports",
            "de": "Sport",
            "it": "Sport",
            "pt": "Esportes",
            "ja": "スポーツ",
            "ko": "스포츠",
            "zh": "运动"
        ]),
        
        "Arts": LocalizedString(englishName: "Arts", translations: [
            "es": "Artes",
            "fr": "Arts",
            "de": "Kunst",
            "it": "Arti",
            "pt": "Artes",
            "ja": "アート",
            "ko": "예술",
            "zh": "艺术"
        ]),
        
        "Music": LocalizedString(englishName: "Music", translations: [
            "es": "Música",
            "fr": "Musique",
            "de": "Musik",
            "it": "Musica",
            "pt": "Música",
            "ja": "音楽",
            "ko": "음악",
            "zh": "音乐"
        ]),
        
        "Technology": LocalizedString(englishName: "Technology", translations: [
            "es": "Tecnología",
            "fr": "Technologie",
            "de": "Technologie",
            "it": "Tecnologia",
            "pt": "Tecnologia",
            "ja": "テクノロジー",
            "ko": "기술",
            "zh": "科技"
        ]),
        
        "Learning": LocalizedString(englishName: "Learning", translations: [
            "es": "Aprendizaje",
            "fr": "Apprentissage",
            "de": "Lernen",
            "it": "Apprendimento",
            "pt": "Aprendizagem",
            "ja": "学習",
            "ko": "학습",
            "zh": "学习"
        ]),
        
        "Outdoor": LocalizedString(englishName: "Outdoor", translations: [
            "es": "Aire Libre",
            "fr": "Plein Air",
            "de": "Outdoor",
            "it": "All'aperto",
            "pt": "Ao Ar Livre",
            "ja": "アウトドア",
            "ko": "야외 활동",
            "zh": "户外"
        ]),
        
        "Food": LocalizedString(englishName: "Food", translations: [
            "es": "Comida",
            "fr": "Cuisine",
            "de": "Essen",
            "it": "Cibo",
            "pt": "Comida",
            "ja": "食べ物",
            "ko": "음식",
            "zh": "美食"
        ]),
        
        "Collecting": LocalizedString(englishName: "Collecting", translations: [
            "es": "Coleccionismo",
            "fr": "Collection",
            "de": "Sammeln",
            "it": "Collezionismo",
            "pt": "Colecionismo",
            "ja": "コレクション",
            "ko": "수집",
            "zh": "收藏"
        ]),
        
        "Social": LocalizedString(englishName: "Social", translations: [
            "es": "Social",
            "fr": "Social",
            "de": "Sozial",
            "it": "Sociale",
            "pt": "Social",
            "ja": "ソーシャル",
            "ko": "사회 활동",
            "zh": "社交"
        ])
    ]
    
    // MARK: - Sample Occupation Translations
    
    /// Sample translations for popular occupations across multiple languages
    /// These demonstrate the multi-language capability for profession localization
    static let occupationTranslations: [String: LocalizedString] = [
        
        // Popular Technology Occupations
        "software-engineer": LocalizedString(englishName: "Software Engineer", translations: [
            "es": "Ingeniero de Software",
            "fr": "Ingénieur Logiciel",
            "de": "Software-Ingenieur",
            "it": "Ingegnere del Software",
            "pt": "Engenheiro de Software",
            "ja": "ソフトウェアエンジニア",
            "ko": "소프트웨어 엔지니어",
            "zh": "软件工程师"
        ]),
        
        "data-scientist": LocalizedString(englishName: "Data Scientist", translations: [
            "es": "Científico de Datos",
            "fr": "Scientifique des Données",
            "de": "Datenwissenschaftler",
            "it": "Scienziato dei Dati",
            "pt": "Cientista de Dados",
            "ja": "データサイエンティスト",
            "ko": "데이터 사이언티스트",
            "zh": "数据科学家"
        ]),
        
        // Popular Healthcare Occupations
        "doctor": LocalizedString(englishName: "Doctor", translations: [
            "es": "Doctor",
            "fr": "Médecin",
            "de": "Arzt",
            "it": "Medico",
            "pt": "Médico",
            "ja": "医師",
            "ko": "의사",
            "zh": "医生"
        ]),
        
        "nurse": LocalizedString(englishName: "Nurse", translations: [
            "es": "Enfermero/a",
            "fr": "Infirmier/ière",
            "de": "Krankenpfleger/in",
            "it": "Infermiere/a",
            "pt": "Enfermeiro/a",
            "ja": "看護師",
            "ko": "간호사",
            "zh": "护士"
        ]),
        
        // Popular Education Occupations
        "teacher": LocalizedString(englishName: "Teacher", translations: [
            "es": "Profesor/a",
            "fr": "Enseignant/e",
            "de": "Lehrer/in",
            "it": "Insegnante",
            "pt": "Professor/a",
            "ja": "教師",
            "ko": "교사",
            "zh": "教师"
        ]),
        
        "professor": LocalizedString(englishName: "Professor", translations: [
            "es": "Profesor Universitario",
            "fr": "Professeur",
            "de": "Professor",
            "it": "Professore",
            "pt": "Professor Universitário",
            "ja": "教授",
            "ko": "교수",
            "zh": "教授"
        ]),
        
        // Popular Business Occupations
        "accountant": LocalizedString(englishName: "Accountant", translations: [
            "es": "Contador",
            "fr": "Comptable",
            "de": "Buchhalter",
            "it": "Contabile",
            "pt": "Contador",
            "ja": "会計士",
            "ko": "회계사",
            "zh": "会计师"
        ]),
        
        "entrepreneur": LocalizedString(englishName: "Entrepreneur", translations: [
            "es": "Empresario",
            "fr": "Entrepreneur",
            "de": "Unternehmer",
            "it": "Imprenditore",
            "pt": "Empresário",
            "ja": "起業家",
            "ko": "기업가",
            "zh": "企业家"
        ]),
        
        // Popular Legal Occupations
        "lawyer": LocalizedString(englishName: "Lawyer", translations: [
            "es": "Abogado",
            "fr": "Avocat",
            "de": "Anwalt",
            "it": "Avvocato",
            "pt": "Advogado",
            "ja": "弁護士",
            "ko": "변호사",
            "zh": "律师"
        ]),
        
        // Popular Creative Occupations
        "artist": LocalizedString(englishName: "Artist", translations: [
            "es": "Artista",
            "fr": "Artiste",
            "de": "Künstler",
            "it": "Artista",
            "pt": "Artista",
            "ja": "アーティスト",
            "ko": "예술가",
            "zh": "艺术家"
        ]),
        
        "architect": LocalizedString(englishName: "Architect", translations: [
            "es": "Arquitecto",
            "fr": "Architecte",
            "de": "Architekt",
            "it": "Architetto",
            "pt": "Arquiteto",
            "ja": "建築家",
            "ko": "건축가",
            "zh": "建筑师"
        ]),
        
        // Popular Engineering Occupations
        "civil-engineer": LocalizedString(englishName: "Civil Engineer", translations: [
            "es": "Ingeniero Civil",
            "fr": "Ingénieur Civil",
            "de": "Bauingenieur",
            "it": "Ingegnere Civile",
            "pt": "Engenheiro Civil",
            "ja": "土木技師",
            "ko": "토목 엔지니어",
            "zh": "土木工程师"
        ]),
        
        "mechanical-engineer": LocalizedString(englishName: "Mechanical Engineer", translations: [
            "es": "Ingeniero Mecánico",
            "fr": "Ingénieur Mécanique",
            "de": "Maschinenbauingenieur",
            "it": "Ingegnere Meccanico",
            "pt": "Engenheiro Mecânico",
            "ja": "機械技師",
            "ko": "기계 엔지니어",
            "zh": "机械工程师"
        ])
    ]
    
    // MARK: - Sample Occupation Category Translations
    
    /// Sample translations for occupation categories
    static let occupationCategories: [String: LocalizedString] = [
        "Technology": LocalizedString(englishName: "Technology", translations: [
            "es": "Tecnología",
            "fr": "Technologie",
            "de": "Technologie",
            "it": "Tecnologia",
            "pt": "Tecnologia",
            "ja": "テクノロジー",
            "ko": "기술",
            "zh": "科技"
        ]),
        
        "Healthcare": LocalizedString(englishName: "Healthcare", translations: [
            "es": "Salud",
            "fr": "Santé",
            "de": "Gesundheitswesen",
            "it": "Sanità",
            "pt": "Saúde",
            "ja": "医療",
            "ko": "의료",
            "zh": "医疗"
        ]),
        
        "Education": LocalizedString(englishName: "Education", translations: [
            "es": "Educación",
            "fr": "Éducation",
            "de": "Bildung",
            "it": "Istruzione",
            "pt": "Educação",
            "ja": "教育",
            "ko": "교육",
            "zh": "教育"
        ]),
        
        "Business": LocalizedString(englishName: "Business", translations: [
            "es": "Negocios",
            "fr": "Affaires",
            "de": "Geschäft",
            "it": "Affari",
            "pt": "Negócios",
            "ja": "ビジネス",
            "ko": "비즈니스",
            "zh": "商业"
        ]),
        
        "Legal": LocalizedString(englishName: "Legal", translations: [
            "es": "Legal",
            "fr": "Juridique",
            "de": "Recht",
            "it": "Legale",
            "pt": "Jurídico",
            "ja": "法律",
            "ko": "법률",
            "zh": "法律"
        ]),
        
        "Creative": LocalizedString(englishName: "Creative", translations: [
            "es": "Creativo",
            "fr": "Créatif",
            "de": "Kreativ",
            "it": "Creativo",
            "pt": "Criativo",
            "ja": "クリエイティブ",
            "ko": "창조적",
            "zh": "创意"
        ]),
        
        "Engineering": LocalizedString(englishName: "Engineering", translations: [
            "es": "Ingeniería",
            "fr": "Ingénierie",
            "de": "Ingenieurwesen",
            "it": "Ingegneria",
            "pt": "Engenharia",
            "ja": "エンジニアリング",
            "ko": "엔지니어링",
            "zh": "工程"
        ]),
        
        "Service": LocalizedString(englishName: "Service", translations: [
            "es": "Servicios",
            "fr": "Services",
            "de": "Dienstleistung",
            "it": "Servizi",
            "pt": "Serviços",
            "ja": "サービス",
            "ko": "서비스",
            "zh": "服务"
        ]),
        
        "Transportation": LocalizedString(englishName: "Transportation", translations: [
            "es": "Transporte",
            "fr": "Transport",
            "de": "Transport",
            "it": "Trasporti",
            "pt": "Transporte",
            "ja": "交通",
            "ko": "운송",
            "zh": "交通运输"
        ]),
        
        "Science": LocalizedString(englishName: "Science", translations: [
            "es": "Ciencia",
            "fr": "Sciences",
            "de": "Wissenschaft",
            "it": "Scienza",
            "pt": "Ciência",
            "ja": "科学",
            "ko": "과학",
            "zh": "科学"
        ]),
        
        "Public Safety": LocalizedString(englishName: "Public Safety", translations: [
            "es": "Seguridad Pública",
            "fr": "Sécurité Publique",
            "de": "Öffentliche Sicherheit",
            "it": "Sicurezza Pubblica",
            "pt": "Segurança Pública",
            "ja": "公共安全",
            "ko": "공공 안전",
            "zh": "公共安全"
        ])
    ]
    
    // MARK: - Translation File Management
    
    /// Translation file structure for server-side loading
    struct TranslationFile {
        let languageCode: String
        let referenceType: ReferenceDataType
        let version: String
        let lastUpdated: Date
        
        var fileName: String {
            return "\(languageCode).json"
        }
        
        var filePath: String {
            return "translations/\(referenceType.rawValue)/\(fileName)"
        }
    }
    
    /// Translation loading result
    struct TranslationLoadResult {
        let languageCode: String
        let referenceType: ReferenceDataType
        let translations: [String: String]  // key -> translated text
        let categories: [String: String]?   // category translations
        let loadedAt: Date
        let success: Bool
        let error: Error?
    }
    
    /// Get all translation files needed for a reference type
    static func getRequiredTranslationFiles(for referenceType: ReferenceDataType) -> [TranslationFile] {
        return supportedLanguages.map { languageCode in
            TranslationFile(
                languageCode: languageCode,
                referenceType: referenceType,
                version: "1.0",
                lastUpdated: Date()
            )
        }
    }
    
    /// Get priority languages for initial loading (most common first)
    static let priorityLanguages = [
        "en", "es", "fr", "de", "zh", "ja", "ko", "ar", "ru", "pt", "hi", "it"
    ]
    
    /// Check if a language is in the priority list
    static func isPriorityLanguage(_ languageCode: String) -> Bool {
        return priorityLanguages.contains(languageCode)
    }
}

// MARK: - Reference Data Types

enum ReferenceDataType: String, CaseIterable {
    case languages = "languages"
    case countries = "countries" 
    case cities = "cities"
    case occupations = "occupations"
    case hobbies = "hobbies"
    
    var displayName: String {
        switch self {
        case .languages: return "Languages"
        case .countries: return "Countries"
        case .cities: return "Cities" 
        case .occupations: return "Occupations"
        case .hobbies: return "Hobbies"
        }
    }
} 