import Foundation

final class MMTToolForAppTransStorageModule {

	private let state = MMTToolForAppTransState.shared

	func initializeStorage() {
		MMTToolForAppTransDBManager.shared.initTable()
	}

	func resetDatabase() {
		state.clearLocalizationCache()
		MMTToolForAppTransDBManager.shared.resetDatabase()
		MMTToolForAppTransDBManager.shared.initTable()
	}

	func synchronizeCurrentLocalizationBundleToDatabase() -> Int {
		ensureStorageInitialized()

		guard let bundle = state.currentLocalizationBundle else {
			return 0
		}

		let languageDictionaries = MMTToolForAppTrans.Language.allLanguageList().reduce(into: [MMTToolForAppTrans.Language: [String: String]]()) { partialResult, language in
			partialResult[language] = localizedDictionary(from: bundle, language: language)
		}

		let allKeys = Set(languageDictionaries.values.flatMap { $0.keys }).sorted()
		guard allKeys.isEmpty == false else {
			return 0
		}

		var synchronizedCount = 0

		for key in allKeys {
			let existingItem = try? MMTToolForAppTransLocalizableTable.table()?.getItem(key: key).get()
			let item = existingItem ?? MMTToolForAppTransLocalizableModel(key: key)

			item.key = key
			item.is_delete = 0
			apply(languageDictionaries[.enUS]?[key], to: item, language: .enUS)
			apply(languageDictionaries[.zhHans]?[key], to: item, language: .zhHans)
			apply(languageDictionaries[.zhHant]?[key], to: item, language: .zhHant)
			apply(languageDictionaries[.fr]?[key], to: item, language: .fr)
			apply(languageDictionaries[.de]?[key], to: item, language: .de)
			apply(languageDictionaries[.es]?[key], to: item, language: .es)
			apply(languageDictionaries[.it]?[key], to: item, language: .it)
			apply(languageDictionaries[.pl]?[key], to: item, language: .pl)

			if existingItem == nil {
				_ = MMTToolForAppTransDBManager.insertNewItem(with: .localizableTable(item))
			} else {
				_ = MMTToolForAppTransDBManager.updateNewItem(with: .localizableTable(item))
			}

			synchronizedCount += 1
		}

		return synchronizedCount
	}

	func localizationItems() -> [MMTToolForAppTransLocalizableModel] {
		ensureStorageInitialized()

		guard case .success(let items) = MMTToolForAppTransLocalizableTable.table()?.getAllItems() else {
			return []
		}

		return items.sorted { lhs, rhs in
			lhs.identifier < rhs.identifier
		}
	}

	func localizationItem(forKey key: String?) -> MMTToolForAppTransLocalizableModel? {
		guard let key, key.isEmpty == false else {
			return nil
		}

		let normalizedKey = key.mmt_normalizedLocalizationKey
		guard normalizedKey.isEmpty == false else {
			return nil
		}

		ensureStorageInitialized()

		if case let .success(item) = MMTToolForAppTransLocalizableTable.getItem(key: normalizedKey),
		   let item,
		   item.is_delete == 0 {
		   	item
		   }

		   guard case let .success(items) = MMTToolForAppTransLocalizableTable.table()?.getAllItems() else { 
			return nil
		}

		return items.first { item in
			item.is_delete == 0 && item.key?.mmt_normalizedLocalizationKey == normalizedKey
		}
	}

	private func ensureStorageInitialized() {
		if MMTToolForAppTransDBManager.shared.localizableTable == nil {
			MMTToolForAppTransDBManager.shared.initTable()
		}
	}

	private func localizedDictionary(from bundle: Bundle, language: MMTToolForAppTrans.Language) -> [String: String] {
		guard let resourcePath = bundle.path(forResource: language.tableName, ofType: "strings"),
			  let dictionary = NSDictionary(contentsOfFile: resourcePath) as? [String: String] else {
			return [:]
		}

		return dictionary.reduce(into: [String: String]()) { partialResult, entry in
			let normalizedKey = entry.key.mmt_normalizedLocalizationKey
			guard normalizedKey.isEmpty == false else {
				return
			}

			partialResult[normalizedKey] = entry.value
		}
	}

	private func apply(_ value: String?, to item: MMTToolForAppTransLocalizableModel, language: MMTToolForAppTrans.Language) {
		switch language {
		case .enUS:
			item.value_en_US = value
		case .zhHans:
			item.value_zh_hans = value
		case .zhHant:
			item.value_zh_hant = value
		case .fr:
			item.value_fr = value
		case .de:
			item.value_de = value
		case .es:
			item.value_es = value
		case .it:
			item.value_it = value
		case .pl:
			item.value_pl = value
		}
	}
}
