import Foundation

final class MMTToolForAppTransStorageModule {

	func initializeStorage() {
		MMTToolForAppTransDBManager.shared.initTable()
	}

	func localizationItem(forKey key: String?) -> MMTToolForAppTransLocalizableModel? {
		guard let key, key.isEmpty == false else {
			return nil
		}

		ensureStorageInitialized()

		guard case .success(let item) = MMTToolForAppTransLocalizableTable.getItem(key: key),
			  let item,
			  item.is_delete == 0 else {
			return nil
		}

		return item
	}

	private func ensureStorageInitialized() {
		if MMTToolForAppTransDBManager.shared.localizableTable == nil {
			MMTToolForAppTransDBManager.shared.initTable()
		}
	}
}