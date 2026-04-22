import Foundation

/// Resolves final localized values by combining cache, bundle resources, and storage fallback.
final class MMTToolForAppTransLocalizationModule {

	private let storageModule = MMTToolForAppTransStorageModule()
	private let state = MMTToolForAppTransState.shared

	/// Resolves a key with the requested language first, then falls back to English and other available values.
	func localizedString(forKey key: String?, language: MMTToolForAppTrans.Language) -> String? {
		guard let key, key.isEmpty == false else {
			return nil
		}

		// Cache keys are language-aware so the same logical key can coexist across multiple languages.
		let localizedCacheKey = buildLocalizedCacheKey(from: key, language: language)

		if let cachedValue = state.localizationCacheValue(for: localizedCacheKey) {
			return cachedValue
		}

		// Bundle values are preferred while the bundle-based integration path is the primary runtime source.
		if let bundleValue = localizedValue(from: state.currentLocalizationBundle, key: key, language: language)
			?? localizedValue(from: state.currentLocalizationBundle, key: key, language: .enUS)
			?? firstAvailableValue(from: state.currentLocalizationBundle, key: key) {
			state.storeLocalizationCacheValue(bundleValue, for: localizedCacheKey)
			return bundleValue
		}

		// If the bundle path does not answer the key, fall back to the persisted WCDB record.
		guard let item = storageModule.localizationItem(forKey: key) else {
			return nil
		}

		// Storage remains the fallback path so existing WCDB data can still answer unresolved bundle keys.
		guard let resolvedValue = localizedValue(from: item, language: language)
			?? localizedValue(from: item, language: .enUS)
			?? firstAvailableValue(from: item) else {
			return nil
		}

		state.storeLocalizationCacheValue(resolvedValue, for: localizedCacheKey)
		return resolvedValue
	}

	/// Builds the in-memory cache key from the original key and the normalized runtime language suffix.
	private func buildLocalizedCacheKey(from key: String, language: MMTToolForAppTrans.Language) -> String {
		key + "." + language.cacheSuffix
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
	private func localizedDictionary(from bundle: Bundle, language: MMTToolForAppTrans.Language) -> NSDictionary? {
		guard let resourcePath = bundle.path(forResource: language.tableName, ofType: "strings") else {
			return nil
		}

		// The example bundle stores one flat `.strings` file per language instead of lproj folders.
		return NSDictionary(contentsOfFile: resourcePath)
	}

	/// Falls back across all stored language columns when the requested language is unavailable.
	private func firstAvailableValue(from item: MMTToolForAppTransLocalizableModel) -> String? {
		[
			item.value_en_US,
			item.value_zh_hans,
			item.value_zh_hant,
			item.value_fr,
			item.value_de,
			item.value_es,
			item.value_it
		]
		.compactMap { sanitize($0) }
		.first
	}

	/// Preserves all non-nil values, including whitespace and line breaks, as valid localization content.
	private func sanitize(_ value: String?) -> String? {
		value
	}
}

/// Convenience entry that resolves using the current runtime language.
public func MMTLocal(key: String?) -> String? {
	MMTToolForAppTrans.shared.localizedString(forKey: key)
}

/// Convenience entry that resolves with an explicit language override.
public func MMTLocal(key: String?, language: MMTToolForAppTrans.Language) -> String? {
	MMTToolForAppTrans.shared.localizedString(forKey: key, language: language)
}