import UIKit

/// Public facade of the library.
/// Keeps external callers away from the internal import, storage, state, and localization modules.
public final class MMTToolForAppTrans {

	// MARK: - Singleton

	public static let shared = MMTToolForAppTrans()

	// MARK: - Nested Types

	/// Read-only snapshot of one localization record exposed to external callers.
	public struct LocalizationRecord {
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
		public let valuePl: String?

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
			valueIt: String?,
			valuePl: String?
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
			self.valuePl = valuePl
		}
	}

	// MARK: - Public API (Type-level)

	public class func initialize() {
		shared.initialize()
	}

	public class func acceptImportFile(at fileURL: URL) -> Result<ImportFile, ImportError> {
		shared.acceptImportFile(at: fileURL)
	}

	public class func acceptImportFile(from bundle: Bundle, resourceName: String, withExtension fileExtension: String = "mmttrans") -> Result<ImportFile, ImportError> {
		shared.acceptImportFile(from: bundle, resourceName: resourceName, withExtension: fileExtension)
	}

	public class func acceptImportFile(data: Data, fileName: String) -> Result<ImportFile, ImportError> {
		shared.acceptImportFile(data: data, fileName: fileName)
	}

	public class func setCurrentLanguage(_ language: Language) {
		shared.setCurrentLanguage(language)
	}

	public class func setValidLanguageList(_ languages: [Language]) {
		shared.setValidLanguageList(languages)
	}

	public class func getValidLanguageList() -> [Language] {
		shared.getValidLanguageList()
	}

	public class func setLocalizationBundle(_ bundle: Bundle?) {
		shared.setLocalizationBundle(bundle)
	}

	public class func getCurrentLocalizationBundle() -> Bundle? {
		shared.getCurrentLocalizationBundle()
	}

	public class func getCurrentLanguage() -> Language {
		shared.getCurrentLanguage()
	}

	public class func getCurrentImportFile() -> ImportFile? {
		shared.getCurrentImportFile()
	}

	public class func localizedString(forKey key: String?) -> String? {
		shared.localizedString(forKey: key)
	}

	public class func localizedString(forKey key: String?, language: Language) -> String? {
		shared.localizedString(forKey: key, language: language)
	}

	public class func switchCurrentLanguage(to language: Language) {
		shared.switchCurrentLanguage(to: language)
	}

	@discardableResult
	public class func setCurrentLanguage(languageIdentifier: String) -> Bool {
		shared.setCurrentLanguage(languageIdentifier: languageIdentifier)
	}

	public class func getAllLocalizationRecords() -> [LocalizationRecord] {
		shared.getAllLocalizationRecords()
	}

	public class func synchronizeCurrentLocalizationBundleToDatabase() -> Int {
		shared.synchronizeCurrentLocalizationBundleToDatabase()
	}

	public class func makeToolsViewController() -> UIViewController {
		shared.makeToolsViewController()
	}

	public class func resetLocalizationDatabase() {
		shared.resetLocalizationDatabase()
	}

	public class func clearLocalizationCache() {
		shared.clearLocalizationCache()
	}

	// MARK: - Private Properties

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
}

// MARK: - Import Methods

extension MMTToolForAppTrans {

	public func acceptImportFile(at fileURL: URL) -> Result<ImportFile, ImportError> {
		let result = importModule.acceptImportFile(at: fileURL)
		if case .success(let importFile) = result {
			state.currentImportFile = importFile
		}
		return result
	}

	public func acceptImportFile(from bundle: Bundle, resourceName: String, withExtension fileExtension: String = "mmttrans") -> Result<ImportFile, ImportError> {
		let result = importModule.acceptImportFile(from: bundle, resourceName: resourceName, withExtension: fileExtension)
		if case .success(let importFile) = result {
			state.currentImportFile = importFile
		}
		return result
	}

	public func acceptImportFile(data: Data, fileName: String) -> Result<ImportFile, ImportError> {
		let result = importModule.acceptImportFile(data: data, fileName: fileName)
		if case .success(let importFile) = result {
			state.currentImportFile = importFile
		}
		return result
	}
}

// MARK: - Language & State Methods

extension MMTToolForAppTrans {

	public func initialize() {
		storageModule.initializeStorage()
	}

	public func setCurrentLanguage(_ language: Language) {
		state.currentLanguage = language
		state.isLanguageConfigured = true
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

	public func setValidLanguageList(_ languages: [Language]) {
		Language.setValidLanguageList(languages)
		if Language.validLanguageList().contains(state.currentLanguage) == false {
			state.currentLanguage = state.resolvePreferredLanguage()
			state.isLanguageConfigured = true
		}
	}

	public func getValidLanguageList() -> [Language] {
		Language.validLanguageList()
	}

	public func getCurrentLanguage() -> Language {
		state.currentLanguage
	}

	public func getCurrentImportFile() -> ImportFile? {
		state.currentImportFile
	}
}

// MARK: - Bundle Methods

extension MMTToolForAppTrans {

	public func setLocalizationBundle(_ bundle: Bundle?) {
		state.currentLocalizationBundle = bundle
		state.clearLocalizationCache()
	}

	public func getCurrentLocalizationBundle() -> Bundle? {
		state.currentLocalizationBundle
	}
}

// MARK: - Localization Methods

extension MMTToolForAppTrans {

	public func localizedString(forKey key: String?) -> String? {
		localizedString(forKey: key, language: state.currentLanguage)
	}

	public func localizedString(forKey key: String?, language: Language) -> String? {
		localizationModule.localizedString(forKey: key, language: language)
	}
}

// MARK: - Storage Methods

extension MMTToolForAppTrans {

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
				valueIt: item.value_it,
				valuePl: item.value_pl
			)
		}
	}

	public func synchronizeCurrentLocalizationBundleToDatabase() -> Int {
		storageModule.synchronizeCurrentLocalizationBundleToDatabase()
	}

	public func resetLocalizationDatabase() {
		storageModule.resetDatabase()
	}

	public func clearLocalizationCache() {
		state.clearLocalizationCache()
	}
}

// MARK: - Tools Methods

extension MMTToolForAppTrans {

	public func makeToolsViewController() -> UIViewController {
		UINavigationController(rootViewController: MMTToolForAppTransToolsViewController())
	}
}
