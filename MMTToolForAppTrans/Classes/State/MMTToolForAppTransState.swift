import Foundation

public extension MMTToolForAppTrans {

	/// Shared language metadata used by the facade, localization lookup, and demo UI.
	public enum Language: Int, CaseIterable {
		// This list can be narrowed by external callers without changing the full language catalog.
		private static var configuredValidLanguages: [Language] = allLanguageList()

		case enUS = 0
		case de
		case es
		case fr
		case it
		case zhHans = 100
		case zhHant = 101

		/// Resolves the best runtime default language from the current device locale information.
		public static var systemLocal: Language {
			// Prefer Apple's ordered language list first so region-specific choices win over generic codes.
			if let preferredIdentifier = Locale.preferredLanguages.first,
			   let language = resolvedLanguage(identifier: preferredIdentifier) {
				return language
			}

			if #available(iOS 16.0, *) {
				return create(identifier: Locale.current.language.languageCode?.identifier)
			}

			return create(identifier: Locale.current.languageCode)
		}

		/// User-facing title used by the demo UI and any external language picker.
		public var titleValue: String {
			switch self {
			case .enUS:
				return "English"
			case .zhHans:
				return "简体中文"
			case .zhHant:
				return "繁體中文"
			case .fr:
				return "Français"
			case .de:
				return "Deutsch"
			case .es:
				return "Español"
			case .it:
				return "Italiano"
			}
		}

		/// Bundle table name used when reading flat `.strings` resources from the current localization bundle.
		public var tableName: String {
			switch self {
			case .enUS:
				return "EnLocalizable"
			case .zhHans:
				return "ZhHansLocalizable"
			case .zhHant:
				return "ZhHantLocalizable"
			case .fr:
				return "FrLocalizable"
			case .de:
				return "GeLocalizable"
			case .es:
				return "SpLocalizable"
			case .it:
				return "ItLocalizable"
			}
		}

		/// Country code reserved for App Store style integrations that need a storefront region.
		public var appStoreCountry: String {
			switch self {
			case .enUS, .zhHans, .zhHant:
				return "us"
			case .fr:
				return "fr"
			case .de:
				return "de"
			case .es:
				return "es"
			case .it:
				return "it"
			}
		}

		/// Public locale identifier used for runtime language matching.
		public var identifier: String {
			switch self {
			case .enUS:
				return "en_US"
			case .zhHans:
				return "zh-Hans"
			case .zhHant:
				return "zh-Hant"
			case .fr:
				return "fr"
			case .de:
				return "de"
			case .es:
				return "es"
			case .it:
				return "it"
			}
		}

		/// Server-side language code kept separate from the public locale identifier.
		public var serverLanguageIdentifier: String {
			switch self {
			case .enUS, .zhHans, .zhHant:
				return "en"
			case .fr:
				return "fr"
			case .de:
				return "de"
			case .es:
				return "es"
			case .it:
				return "it"
			}
		}

		/// Compact suffix used to build in-memory localization cache keys.
		var cacheSuffix: String {
			switch self {
			case .enUS:
				return "enUs"
			case .zhHans:
				return "zhHans"
			case .zhHant:
				return "zhHant"
			case .fr:
				return "fr"
			case .de:
				return "de"
			case .es:
				return "es"
			case .it:
				return "it"
			}
		}

		/// Creates a language from any supported locale identifier and falls back to English.
		public static func create(identifier: String?) -> Language {
			resolvedLanguage(identifier: identifier) ?? .enUS
		}

		/// Returns the currently allowed language subset configured by external callers.
		public static func validLanguageList() -> [Language] {
			let languages = configuredValidLanguages.filter { allLanguageList().contains($0) }
			return languages.isEmpty ? allLanguageList() : languages
		}

		/// Returns the full language catalog supported by the library.
		public static func allLanguageList() -> [Language] {
			[.enUS, .zhHans, .zhHant, .fr, .de, .es, .it]
		}

		/// Replaces the externally visible valid-language subset while removing duplicates and unknown values.
		static func setValidLanguageList(_ languages: [Language]) {
			let uniqueLanguages = Array(NSOrderedSet(array: languages)) as? [Language]
			configuredValidLanguages = uniqueLanguages?.filter { allLanguageList().contains($0) } ?? allLanguageList()
		}

		/// Matches a locale string against the configured language subset.
		/// Chinese is split first, then generic matching compares both client and server identifiers.
		static func resolvedLanguage(identifier: String?) -> Language? {
			guard let normalizedIdentifier = normalize(identifier) else {
				return nil
			}

			// Chinese needs an explicit script/region split before the generic identifier matching below.
			if normalizedIdentifier.hasPrefix("zhhans") || normalizedIdentifier.hasPrefix("zhcn") {
				return .zhHans
			}

			if normalizedIdentifier.hasPrefix("zhhant") || normalizedIdentifier.hasPrefix("zhtw") || normalizedIdentifier.hasPrefix("zhhk") {
				return .zhHant
			}

			// Match against both the public locale identifier and the server-side language code.
			return validLanguageList().first { language in
				guard let normalizedLanguageIdentifier = normalize(language.identifier),
					  let normalizedServerIdentifier = normalize(language.serverLanguageIdentifier) else {
					return false
				}

				return normalizedIdentifier.contains(normalizedLanguageIdentifier)
					|| normalizedLanguageIdentifier.contains(normalizedIdentifier)
					|| normalizedIdentifier == normalizedServerIdentifier
			}
		}

		/// Normalizes locale text so different separators and casing can be compared safely.
		private static func normalize(_ identifier: String?) -> String? {
			guard let identifier, identifier.isEmpty == false else {
				return nil
			}

			return identifier
				.replacingOccurrences(of: "-", with: "")
				.replacingOccurrences(of: "_", with: "")
				.lowercased()
		}
	}
}

/// Shared runtime state used by the facade and internal modules.
final class MMTToolForAppTransState {

	/// Cache entry storing the resolved string plus its latest access order for LRU eviction.
	struct LocalizationCacheValue {
		var value: String
		var lastAccessOrder: Int
	}

	static let shared = MMTToolForAppTransState()

	private static let maxLocalizationCacheCount = 200

	var currentLanguage: MMTToolForAppTrans.Language = .enUS
	var currentImportFile: MMTToolForAppTrans.ImportFile?
	var currentLocalizationBundle: Bundle?
	var localizationValueMap: [String: LocalizationCacheValue] = [:]
	var accessOrderSeed: Int = 0

	var isLanguageConfigured: Bool = false

	/// Reads a cached localization value and refreshes its access order so it stays recent.
	func localizationCacheValue(for key: String) -> String? {
		guard var cachedValue = localizationValueMap[key] else {
			return nil
		}

		cachedValue.lastAccessOrder = nextAccessOrder()
		localizationValueMap[key] = cachedValue
		return cachedValue.value
	}

	/// Stores a resolved localization value and immediately enforces the cache size limit.
	func storeLocalizationCacheValue(_ value: String, for key: String) {
		localizationValueMap[key] = LocalizationCacheValue(value: value, lastAccessOrder: nextAccessOrder())
		trimLocalizationCacheIfNeeded()
	}

	/// Clears cached localized values when the active bundle or language scope changes significantly.
	func clearLocalizationCache() {
		localizationValueMap.removeAll()
		accessOrderSeed = 0
	}

	/// Produces a monotonically increasing access token for standard LRU eviction.
	private func nextAccessOrder() -> Int {
		accessOrderSeed += 1
		return accessOrderSeed
	}

	/// Removes the least recently accessed item when the cache grows past its fixed capacity.
	private func trimLocalizationCacheIfNeeded() {
		guard localizationValueMap.count > Self.maxLocalizationCacheCount,
			  let removableKey = localizationValueMap.min(by: { lhs, rhs in
				lhs.value.lastAccessOrder < rhs.value.lastAccessOrder
			})?.key else {
			return
		}

		localizationValueMap.removeValue(forKey: removableKey)
	}

	/// Resolves the default runtime language through the centralized Language helper.
	func resolvePreferredLanguage() -> MMTToolForAppTrans.Language {
		MMTToolForAppTrans.Language.systemLocal
	}

	/// Reuses the shared identifier matching rules when callers pass an explicit locale string.
	func resolveLanguage(from languageIdentifier: String) -> MMTToolForAppTrans.Language? {
		MMTToolForAppTrans.Language.resolvedLanguage(identifier: languageIdentifier)
	}

	private init() {}
}