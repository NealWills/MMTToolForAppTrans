import Foundation

final class MMTToolForAppTransLocalizationModule {

	private let storageModule = MMTToolForAppTransStorageModule()
	private let state = MMTToolForAppTransState.shared

	func localizedString(forKey key: String?, language: MMTToolForAppTrans.Language) -> String? {
		guard let key, key.isEmpty == false else {
			return nil
		}

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

	private func buildLocalizedCacheKey(from key: String, language: MMTToolForAppTrans.Language) -> String {
		key + "." + languageCacheSuffix(for: language)
	}

	private func languageCacheSuffix(for language: MMTToolForAppTrans.Language) -> String {
		switch language {
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

	private func localizedValue(from bundle: Bundle?, key: String, language: MMTToolForAppTrans.Language) -> String? {
		guard let bundle,
			  let strings = localizedDictionary(from: bundle, language: language) else {
			return nil
		}

		return sanitize(strings[key] as? String)
	}

	private func firstAvailableValue(from bundle: Bundle?, key: String) -> String? {
		for language in MMTToolForAppTrans.Language.allCases {
			if let value = localizedValue(from: bundle, key: key, language: language) {
				return value
			}
		}

		return nil
	}

	private func localizedDictionary(from bundle: Bundle, language: MMTToolForAppTrans.Language) -> NSDictionary? {
		guard let resourceName = languageResourceName(for: language),
			  let resourcePath = bundle.path(forResource: resourceName, ofType: "strings") else {
			return nil
		}

		// The example bundle stores one flat `.strings` file per language instead of lproj folders.
		return NSDictionary(contentsOfFile: resourcePath)
	}

	private func languageResourceName(for language: MMTToolForAppTrans.Language) -> String? {
		switch language {
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

	private func sanitize(_ value: String?) -> String? {
		value
	}
}

public func MMTLocal(key: String?) -> String? {
	MMTToolForAppTrans.shared.localizedString(forKey: key)
}

public func MMTLocal(key: String?, language: MMTToolForAppTrans.Language) -> String? {
	MMTToolForAppTrans.shared.localizedString(forKey: key, language: language)
}