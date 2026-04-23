import UIKit

public extension MMTToolForAppTrans {

	/// Read-only snapshot of one localization record exposed to external callers.
	struct LocalizationRecord {
		public let identifier: Int
		public let description: String?
		public let createDate: Date?
		public let updateDate: Date?
		public let isDeleted: Bool
		public let key: String?
		public let valueEnUS: String?
		public let valueZhHans: String?
		public let valueZhHant: String?
		public let valueFr: String?
		public let valueDe: String?
		public let valueEs: String?
		public let valueIt: String?

		public init(
			identifier: Int,
			description: String?,
			createDate: Date?,
			updateDate: Date?,
			isDeleted: Bool,
			key: String?,
			valueEnUS: String?,
			valueZhHans: String?,
			valueZhHant: String?,
			valueFr: String?,
			valueDe: String?,
			valueEs: String?,
			valueIt: String?
		) {
			self.identifier = identifier
			self.description = description
			self.createDate = createDate
			self.updateDate = updateDate
			self.isDeleted = isDeleted
			self.key = key
			self.valueEnUS = valueEnUS
			self.valueZhHans = valueZhHans
			self.valueZhHant = valueZhHant
			self.valueFr = valueFr
			self.valueDe = valueDe
			self.valueEs = valueEs
			self.valueIt = valueIt
		}
	}
}

/// Public facade of the library.
/// Keeps external callers away from the internal import, storage, state, and localization modules.
public final class MMTToolForAppTrans {

	public static let shared = MMTToolForAppTrans()

	/// Type-level entry matching the instance API so external callers do not need to hold `shared` manually.
	public class func initialize() {
		shared.initialize()
	}

	/// Type-level entry for accepting a direct import file URL.
	public class func acceptImportFile(at fileURL: URL) -> Result<ImportFile, ImportError> {
		shared.acceptImportFile(at: fileURL)
	}

	/// Type-level entry for resolving an import resource from a bundle.
	public class func acceptImportFile(from bundle: Bundle, resourceName: String, withExtension fileExtension: String = "mmttrans") -> Result<ImportFile, ImportError> {
		shared.acceptImportFile(from: bundle, resourceName: resourceName, withExtension: fileExtension)
	}

	/// Type-level entry for accepting in-memory file bytes.
	public class func acceptImportFile(data: Data, fileName: String) -> Result<ImportFile, ImportError> {
		shared.acceptImportFile(data: data, fileName: fileName)
	}

	/// Type-level entry for setting the current runtime language.
	public class func setCurrentLanguage(_ language: Language) {
		shared.setCurrentLanguage(language)
	}

	/// Type-level entry for restricting the valid runtime language list.
	public class func setValidLanguageList(_ languages: [Language]) {
		shared.setValidLanguageList(languages)
	}

	/// Type-level entry for reading the currently allowed language list.
	public class func getValidLanguageList() -> [Language] {
		shared.getValidLanguageList()
	}

	/// Type-level entry for registering the active localization bundle.
	public class func setLocalizationBundle(_ bundle: Bundle?) {
		shared.setLocalizationBundle(bundle)
	}

	/// Type-level entry for reading the active localization bundle.
	public class func getCurrentLocalizationBundle() -> Bundle? {
		shared.getCurrentLocalizationBundle()
	}

	/// Type-level entry for reading the current runtime language.
	public class func getCurrentLanguage() -> Language {
		shared.getCurrentLanguage()
	}

	/// Type-level entry for reading the last accepted import file.
	public class func getCurrentImportFile() -> ImportFile? {
		shared.getCurrentImportFile()
	}

	/// Type-level entry for resolving a key with the current runtime language.
	public class func localizedString(forKey key: String?) -> String? {
		shared.localizedString(forKey: key)
	}

	/// Type-level entry for reading the current database content as read-only snapshots.
	public class func getAllLocalizationRecords() -> [LocalizationRecord] {
		shared.getAllLocalizationRecords()
	}

	/// Type-level entry for syncing the current localization bundle into the storage layer.
	public class func synchronizeCurrentLocalizationBundleToDatabase() -> Int {
		shared.synchronizeCurrentLocalizationBundleToDatabase()
	}

	/// Type-level entry for building the tool center UI exposed by the library.
	public class func makeToolsViewController() -> UIViewController {
		shared.makeToolsViewController()
	}

	/// Type-level entry for resolving a key with an explicit language.
	public class func localizedString(forKey key: String?, language: Language) -> String? {
		shared.localizedString(forKey: key, language: language)
	}

	/// Type-level entry for switching the current runtime language.
	public class func switchCurrentLanguage(to language: Language) {
		shared.switchCurrentLanguage(to: language)
	}

	/// Type-level entry for setting the runtime language from a locale identifier.
	@discardableResult
	public class func setCurrentLanguage(languageIdentifier: String) -> Bool {
		shared.setCurrentLanguage(languageIdentifier: languageIdentifier)
	}

	private let importModule = MMTToolForAppTransImportModule()
	private let storageModule = MMTToolForAppTransStorageModule()
	private let localizationModule = MMTToolForAppTransLocalizationModule()
	private let state = MMTToolForAppTransState.shared

	private init() {
		if state.isLanguageConfigured == false {
			state.currentLanguage = state.resolvePreferredLanguage()
			state.isLanguageConfigured = true
		}
	}

	/// Prepares the underlying storage layer before localization data is queried from WCDB.
	public func initialize() {
		storageModule.initializeStorage()
	}

	/// Accepts a direct import file URL and stores the last accepted file in runtime state.
	public func acceptImportFile(at fileURL: URL) -> Result<ImportFile, ImportError> {
		let result = importModule.acceptImportFile(at: fileURL)
		if case .success(let importFile) = result {
			state.currentImportFile = importFile
		}
		return result
	}

	/// Resolves an import resource from a bundle so callers do not need to build file URLs themselves.
	public func acceptImportFile(from bundle: Bundle, resourceName: String, withExtension fileExtension: String = "mmttrans") -> Result<ImportFile, ImportError> {
		let result = importModule.acceptImportFile(from: bundle, resourceName: resourceName, withExtension: fileExtension)
		if case .success(let importFile) = result {
			state.currentImportFile = importFile
		}
		return result
	}

	/// Accepts in-memory file data for callers that already manage the file loading process.
	public func acceptImportFile(data: Data, fileName: String) -> Result<ImportFile, ImportError> {
		let result = importModule.acceptImportFile(data: data, fileName: fileName)
		if case .success(let importFile) = result {
			state.currentImportFile = importFile
		}
		return result
	}

	public func setCurrentLanguage(_ language: Language) {
		state.currentLanguage = language
		state.isLanguageConfigured = true
	}

	/// Restricts the runtime language scope used by matching, fallback, and demo rendering.
	public func setValidLanguageList(_ languages: [Language]) {
		// Keep the externally configured language scope at the facade layer.
		Language.setValidLanguageList(languages)

		// If the current language is no longer allowed, fall back to the best available system match.
		if Language.validLanguageList().contains(state.currentLanguage) == false {
			state.currentLanguage = state.resolvePreferredLanguage()
			state.isLanguageConfigured = true
		}
	}

	public func getValidLanguageList() -> [Language] {
		Language.validLanguageList()
	}

	/// Registers the active localization bundle used by bundle-first key lookup.
	public func setLocalizationBundle(_ bundle: Bundle?) {
		// Switching bundle invalidates resolved values because the backing strings files changed.
		state.currentLocalizationBundle = bundle
		state.clearLocalizationCache()
	}

	public func getCurrentLocalizationBundle() -> Bundle? {
		state.currentLocalizationBundle
	}

	public func getCurrentLanguage() -> Language {
		state.currentLanguage
	}

	public func getCurrentImportFile() -> ImportFile? {
		state.currentImportFile
	}

	/// Uses the current runtime language to resolve the localized value for a key.
	public func localizedString(forKey key: String?) -> String? {
		localizedString(forKey: key, language: state.currentLanguage)
	}

	/// Exposes a read-only snapshot list of all records currently stored in the database.
	public func getAllLocalizationRecords() -> [LocalizationRecord] {
		storageModule.localizationItems().map { item in
			LocalizationRecord(
				identifier: item.identifier,
				description: item.description,
				createDate: item.create_date,
				updateDate: item.update_date,
				isDeleted: item.is_delete != 0,
				key: item.key,
				valueEnUS: item.value_en_US,
				valueZhHans: item.value_zh_hans,
				valueZhHant: item.value_zh_hant,
				valueFr: item.value_fr,
				valueDe: item.value_de,
				valueEs: item.value_es,
				valueIt: item.value_it
			)
		}
	}

	/// Imports the current localization bundle into the database so callers can inspect stored records.
	public func synchronizeCurrentLocalizationBundleToDatabase() -> Int {
		storageModule.synchronizeCurrentLocalizationBundleToDatabase()
	}

	/// Builds the tool center UI so host apps can present library-provided debug tools directly.
	public func makeToolsViewController() -> UIViewController {
		UINavigationController(rootViewController: MMTToolForAppTransToolsViewController())
	}

	/// Allows callers to bypass currentLanguage and resolve with an explicit language.
	public func localizedString(forKey key: String?, language: Language) -> String? {
		localizationModule.localizedString(forKey: key, language: language)
	}

	public func switchCurrentLanguage(to language: Language) {
		setCurrentLanguage(language)
	}

	@discardableResult
	public func setCurrentLanguage(languageIdentifier: String) -> Bool {
		guard let language = state.resolveLanguage(from: languageIdentifier) else {
			return false
		}

		setCurrentLanguage(language)
		return true
	}

}
