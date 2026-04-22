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

		guard let item = storageModule.localizationItem(forKey: key) else {
			return nil
		}

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