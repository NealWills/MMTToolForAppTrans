import Foundation

public extension MMTToolForAppTrans {

	/// Public import file types currently exposed by the library.
	public enum ImportFileType: String {
		case mmttrans
		case xlsx
	}

	/// Lightweight import payload kept in runtime state after a file is accepted.
	public struct ImportFile {
		public let fileType: ImportFileType
		public let fileName: String
		public let sourceURL: URL?
		public let data: Data

		public init(fileType: ImportFileType, fileName: String, sourceURL: URL?, data: Data) {
			self.fileType = fileType
			self.fileName = fileName
			self.sourceURL = sourceURL
			self.data = data
		}
	}

	/// Import failures surfaced to external callers.
	public enum ImportError: Error {
		case fileNotFound
		case resourceNotFound
		case unreadableFile
		case emptyFile
		case unsupportedFileType
		case invalidMMTTransFile
		case invalidXLSXFile
	}
}

/// Validates incoming import resources and converts them into a unified runtime payload.
final class MMTToolForAppTransImportModule {

	/// Accepts a direct file URL and validates the file before exposing it to upper layers.
	func acceptImportFile(at fileURL: URL) -> Result<MMTToolForAppTrans.ImportFile, MMTToolForAppTrans.ImportError> {
		guard FileManager.default.fileExists(atPath: fileURL.path) else {
			return .failure(.fileNotFound)
		}

		guard let data = try? Data(contentsOf: fileURL) else {
			return .failure(.unreadableFile)
		}

		return acceptImportFile(data: data, fileName: fileURL.lastPathComponent, sourceURL: fileURL)
	}

	/// Resolves a bundled import resource so callers can load packaged demo data without building paths manually.
	func acceptImportFile(
		from bundle: Bundle, resourceName: String, withExtension fileExtension: String = "xlsx"
	) -> Result<MMTToolForAppTrans.ImportFile, MMTToolForAppTrans.ImportError> {
		guard let fileURL = bundle.url(forResource: resourceName, withExtension: fileExtension) else {
			return .failure(.resourceNotFound)
		}

		return acceptImportFile(at: fileURL)
	}

	/// Accepts in-memory file bytes for callers that already own the file loading process.
	func acceptImportFile(data: Data, fileName: String) -> Result<MMTToolForAppTrans.ImportFile, MMTToolForAppTrans.ImportError> {
		acceptImportFile(data: data, fileName: fileName, sourceURL: nil)
	}

	/// Central validation entry used by all import paths so file rules stay in one place.
	private func acceptImportFile(data: Data, fileName: String, sourceURL: URL?) -> Result<MMTToolForAppTrans.ImportFile, MMTToolForAppTrans.ImportError> {
		guard data.isEmpty == false else {
			return .failure(.emptyFile)
		}

		guard let fileType = resolveImportFileType(from: fileName) else {
			return .failure(.unsupportedFileType)
		}

		switch fileType {
		case .mmttrans:
			// `.mmttrans` is currently treated as a zip-based container.
			guard isZipContainer(data) else {
				return .failure(.invalidMMTTransFile)
			}
		case .xlsx:
			// `.xlsx` is also a ZIP-based container (OOXML format).
			guard isZipContainer(data) else {
				return .failure(.invalidXLSXFile)
			}
		}

		let importFile = MMTToolForAppTrans.ImportFile(
			fileType: fileType,
			fileName: fileName,
			sourceURL: sourceURL,
			data: data
		)
		return .success(importFile)
	}

	/// Derives the public import type from the file extension.
	private func resolveImportFileType(from fileName: String) -> MMTToolForAppTrans.ImportFileType? {
		let fileExtension = URL(fileURLWithPath: fileName).pathExtension.lowercased()

		switch fileExtension {
		case MMTToolForAppTrans.ImportFileType.mmttrans.rawValue:
			return .mmttrans
		case MMTToolForAppTrans.ImportFileType.xlsx.rawValue:
			return .xlsx
		default:
			return nil
		}
	}

	/// Checks the ZIP magic bytes because `.mmttrans` is currently treated as a renamed ZIP container.
	private func isZipContainer(_ data: Data) -> Bool {
		guard data.count >= 2 else {
			return false
		}

		return data.starts(with: [0x50, 0x4B])
	}
}
