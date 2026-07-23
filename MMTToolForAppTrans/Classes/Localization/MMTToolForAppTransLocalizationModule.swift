import Foundation
import OSLog

private let localizationLog = OSLog(subsystem: "com.mmttool.apptrans", category: "Localization")

/// Resolves final localized values by combining cache, bundle resources, and storage fallback.
final class MMTToolForAppTransLocalizationModule {

	private let storageModule = MMTToolForAppTransStorageModule()
	private let state = MMTToolForAppTransState.shared

	/// Resolves a key with the requested language first, then falls back to English and other available values.
	func localizedString(forKey key: String?, language: MMTToolForAppTrans.Language) -> String? {
		guard let key, key.isEmpty == false else {
			os_log(.debug, log: localizationLog, "❌ Empty key, returning as-is")
			return key
		}

		let normalizedKey = key.mmt_normalizedLocalizationKey
		guard normalizedKey.isEmpty == false else {
			os_log(.debug, log: localizationLog, "❌ Key normalized to empty, returning as-is")
			return normalizedKey
		}

		let resolvedLanguage = normalizedLookupLanguage(from: language)
		let didFallbackLanguage = resolvedLanguage != language

		os_log(.debug, log: localizationLog, "🔍 localizedString key=\"%@\" requested=%@ resolved=%@ fallback=%{BOOL}d", normalizedKey, language.cacheSuffix, resolvedLanguage.cacheSuffix, didFallbackLanguage)

		// Cache keys are language-aware so the same logical key can coexist across multiple languages.
		let localizedCacheKey = buildLocalizedCacheKey(from: normalizedKey, language: resolvedLanguage)

		if let cachedValue = state.localizationCacheValue(for: localizedCacheKey) {
			os_log(.debug, log: localizationLog, "✅ Cache HIT: %@ => %@", localizedCacheKey, cachedValue)
			return cachedValue
		}
		os_log(.debug, log: localizationLog, "❌ Cache MISS: %@", localizedCacheKey)

		// Bundle values are preferred while the bundle-based integration path is the primary runtime source.
		if let bundleValue = localizedValue(from: state.currentLocalizationBundle, key: normalizedKey, language: resolvedLanguage) {
			os_log(.debug, log: localizationLog, "✅ Bundle HIT (requested): %@ => %@", normalizedKey, bundleValue)
			state.storeLocalizationCacheValue(bundleValue, for: localizedCacheKey)
			return bundleValue
		}
		os_log(.debug, log: localizationLog, "❌ Bundle MISS (requested language)")

		if let bundleValue = localizedValue(from: state.currentLocalizationBundle, key: normalizedKey, language: .enUS) {
			os_log(.debug, log: localizationLog, "✅ Bundle HIT (enUS fallback): %@ => %@", normalizedKey, bundleValue)
			state.storeLocalizationCacheValue(bundleValue, for: localizedCacheKey)
			return bundleValue
		}
		os_log(.debug, log: localizationLog, "❌ Bundle MISS (enUS fallback)")

		if let bundleValue = firstAvailableValue(from: state.currentLocalizationBundle, key: normalizedKey) {
			os_log(.debug, log: localizationLog, "✅ Bundle HIT (first available): %@ => %@", normalizedKey, bundleValue)
			state.storeLocalizationCacheValue(bundleValue, for: localizedCacheKey)
			return bundleValue
		}
		os_log(.debug, log: localizationLog, "❌ Bundle full MISS - falling back to storage")

		// If the bundle path does not answer the key, fall back to the persisted WCDB record.
		guard let item = storageModule.localizationItem(forKey: normalizedKey) else {
			os_log(.debug, log: localizationLog, "❌ Storage also MISS - returning original key: %@", normalizedKey)
			return normalizedKey
		}
		os_log(.debug, log: localizationLog, "✅ Storage FOUND item for key: %@", normalizedKey)

		// Storage remains the fallback path so existing WCDB data can still answer unresolved bundle keys.
		guard let resolvedValue = localizedValue(from: item, language: resolvedLanguage)
			?? localizedValue(from: item, language: .enUS)
			?? firstAvailableStoredValue(from: item) else {
				os_log(.debug, log: localizationLog, "❌ Storage has no value for any language - returning key: %@", normalizedKey)
				return normalizedKey
		}

		os_log(.debug, log: localizationLog, "✅ Resolved from storage: %@ => %@", normalizedKey, resolvedValue)
		state.storeLocalizationCacheValue(resolvedValue, for: localizedCacheKey)
		return resolvedValue
	}

	/// Builds the in-memory cache key from the original key and the normalized runtime language suffix.
	private func buildLocalizedCacheKey(from key: String, language: MMTToolForAppTrans.Language) -> String {
		key + "." + language.cacheSuffix
	}

	/// Forces lookups to English when callers pass a language outside the configured runtime subset.
	private func normalizedLookupLanguage(from language: MMTToolForAppTrans.Language) -> MMTToolForAppTrans.Language {
		MMTToolForAppTrans.Language.validLanguageList().contains(language) ? language : .enUS
	}

	/// Reads the language-specific column from the WCDB model.
	private func localizedValue(from item: MMTToolForAppTransLocalizableModel, language: MMTToolForAppTrans.Language) -> String? {
		switch language {
		case .enUS:
			return sanitize(item.value_en_US)
		case .zhHans:
			return sanitize(item.value_zh_hans)
		case .zhHant:
			return sanitize(item.value_zh_hant)
		case .fr:
			return sanitize(item.value_fr)
		case .de:
			return sanitize(item.value_de)
		case .es:
			return sanitize(item.value_es)
		case .it:
			return sanitize(item.value_it)
		case .pl:
			return sanitize(item.value_pl)
		case .ko:
			return sanitize(item.value_ko)
		case .ru:
			return sanitize(item.value_ru)
		case .uk:
			return sanitize(item.value_uk)
		}
	}

	/// Reads the language-specific `.strings` file from the active localization bundle.
	private func localizedValue(from bundle: Bundle?, key: String, language: MMTToolForAppTrans.Language) -> String? {
		guard let bundle,
			  let strings = localizedDictionary(from: bundle, language: language) else {
			return nil
		}

		// Bundle lookups mirror the runtime language choice before storage fallback is attempted.
		return sanitize(strings[key] as? String)
	}

	/// Scans the currently allowed language list and returns the first bundle value that exists.
	private func firstAvailableValue(from bundle: Bundle?, key: String) -> String? {
		for language in MMTToolForAppTrans.Language.validLanguageList() {
			if let value = localizedValue(from: bundle, key: key, language: language) {
				return value
			}
		}

		return nil
	}

	/// Loads the flat `.strings` table that matches the requested language.
	private func localizedDictionary(from bundle: Bundle, language: MMTToolForAppTrans.Language) -> [String: String]? { 
		guard let resourcePath = bundle.path(forResource: language.tableName, ofType: "strings") else {
			return nil
		}

		// The example bundle stores one flat `.strings` file per language instead of lproj folders.
		guard let dictionary = NSDictionary(contentsOfFile: resourcePath) as? [String: String] else {
			return nil
		}

		return dictionary.reduce(into: [String: String]()) { partialResult, entry in
			let normalizedKey = entry.key.mmt_normalizedLocalizationKey
			guard normalizedKey.isEmpty == false else {
				return
			}

			partialResult[normalizedKey] = entry.value
		}
	}

	/// Falls back across all stored language columns when the requested language is unavailable.
	private func firstAvailableStoredValue(from item: MMTToolForAppTransLocalizableModel) -> String? { 
		[
			item.value_en_US,
			item.value_zh_hans,
			item.value_zh_hant,
			item.value_fr,
			item.value_de,
			item.value_es,
			item.value_it,
			item.value_pl,
			item.value_ko,
			item.value_ru,
			item.value_uk
		]
		.compactMap { sanitize($0) }
		.first
	}

	/// Preserves all non-nil values, including whitespace and line breaks, as valid localization content.
	private func sanitize(_ value: String?) -> String? {
		value
	}
}

