import Foundation

public extension MMTToolForAppTrans {

	public enum Language: String, CaseIterable {
		case enUS = "en_US"
		case zhHans = "zh_Hans"
		case zhHant = "zh_Hant"
		case fr = "fr"
		case de = "de"
		case es = "es"
		case it = "it"
	}
}

final class MMTToolForAppTransState {

	struct LocalizationCacheValue {
		var value: String
		var lastAccessOrder: Int
	}

	static let shared = MMTToolForAppTransState()

	private static let maxLocalizationCacheCount = 200

	var currentLanguage: MMTToolForAppTrans.Language = .enUS
	var currentImportFile: MMTToolForAppTrans.ImportFile?
	var localizationValueMap: [String: LocalizationCacheValue] = [:]
	var accessOrderSeed: Int = 0

	var isLanguageConfigured: Bool = false

	func localizationCacheValue(for key: String) -> String? {
		guard var cachedValue = localizationValueMap[key] else {
			return nil
		}

		cachedValue.lastAccessOrder = nextAccessOrder()
		localizationValueMap[key] = cachedValue
		return cachedValue.value
	}

	func storeLocalizationCacheValue(_ value: String, for key: String) {
		localizationValueMap[key] = LocalizationCacheValue(value: value, lastAccessOrder: nextAccessOrder())
		trimLocalizationCacheIfNeeded()
	}

	private func nextAccessOrder() -> Int {
		accessOrderSeed += 1
		return accessOrderSeed
	}

	private func trimLocalizationCacheIfNeeded() {
		guard localizationValueMap.count > Self.maxLocalizationCacheCount,
			  let removableKey = localizationValueMap.min(by: { lhs, rhs in
				lhs.value.lastAccessOrder < rhs.value.lastAccessOrder
			})?.key else {
			return
		}

		localizationValueMap.removeValue(forKey: removableKey)
	}

	func resolvePreferredLanguage() -> MMTToolForAppTrans.Language {
		guard let preferredIdentifier = Locale.preferredLanguages.first else {
			return .enUS
		}

		return resolveLanguage(from: preferredIdentifier) ?? .enUS
	}

	func resolveLanguage(from languageIdentifier: String) -> MMTToolForAppTrans.Language? {
		let normalizedIdentifier = languageIdentifier
			.replacingOccurrences(of: "-", with: "_")
			.lowercased()

		if normalizedIdentifier.hasPrefix("zh_hans") || normalizedIdentifier.hasPrefix("zh_cn") {
			return .zhHans
		}

		if normalizedIdentifier.hasPrefix("zh_hant") || normalizedIdentifier.hasPrefix("zh_tw") || normalizedIdentifier.hasPrefix("zh_hk") {
			return .zhHant
		}

		if normalizedIdentifier.hasPrefix("en") {
			return .enUS
		}

		if normalizedIdentifier.hasPrefix("fr") {
			return .fr
		}

		if normalizedIdentifier.hasPrefix("de") {
			return .de
		}

		if normalizedIdentifier.hasPrefix("es") {
			return .es
		}

		if normalizedIdentifier.hasPrefix("it") {
			return .it
		}

		return nil
	}

	private init() {}
}