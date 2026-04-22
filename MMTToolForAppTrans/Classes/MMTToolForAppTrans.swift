import Foundation

public final class MMTToolForAppTrans {

	public static let shared = MMTToolForAppTrans()

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

	public func initialize() {
		storageModule.initializeStorage()
	}

	public func acceptImportFile(at fileURL: URL) -> Result<ImportFile, ImportError> {
		let result = importModule.acceptImportFile(at: fileURL)
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

	public func setCurrentLanguage(_ language: Language) {
		state.currentLanguage = language
		state.isLanguageConfigured = true
	}

	public func getCurrentLanguage() -> Language {
		state.currentLanguage
	}

	public func getCurrentImportFile() -> ImportFile? {
		state.currentImportFile
	}

	public func localizedString(forKey key: String?) -> String? {
		localizedString(forKey: key, language: state.currentLanguage)
	}

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
