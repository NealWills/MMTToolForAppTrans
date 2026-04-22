import Foundation

/// Public facade of the library.
/// Keeps external callers away from the internal import, storage, state, and localization modules.
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
