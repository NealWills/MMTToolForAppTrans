import Foundation

public extension MMTToolForAppTrans {

	public enum ImportFileType: String {
		case mmttrans
		case xml
	}

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

	public enum ImportError: Error {
		case fileNotFound
		case unreadableFile
		case emptyFile
		case unsupportedFileType
		case invalidMMTTransFile
		case invalidXMLFile
	}
}

final class MMTToolForAppTransImportModule {

	func acceptImportFile(at fileURL: URL) -> Result<MMTToolForAppTrans.ImportFile, MMTToolForAppTrans.ImportError> {
		guard FileManager.default.fileExists(atPath: fileURL.path) else {
			return .failure(.fileNotFound)
		}

		guard let data = try? Data(contentsOf: fileURL) else {
			return .failure(.unreadableFile)
		}

		return acceptImportFile(data: data, fileName: fileURL.lastPathComponent, sourceURL: fileURL)
	}

	func acceptImportFile(data: Data, fileName: String) -> Result<MMTToolForAppTrans.ImportFile, MMTToolForAppTrans.ImportError> {
		acceptImportFile(data: data, fileName: fileName, sourceURL: nil)
	}

	private func acceptImportFile(data: Data, fileName: String, sourceURL: URL?) -> Result<MMTToolForAppTrans.ImportFile, MMTToolForAppTrans.ImportError> {
		guard data.isEmpty == false else {
			return .failure(.emptyFile)
		}

		guard let fileType = resolveImportFileType(from: fileName) else {
			return .failure(.unsupportedFileType)
		}

		switch fileType {
		case .mmttrans:
			guard isZipContainer(data) else {
				return .failure(.invalidMMTTransFile)
			}
		case .xml:
			guard isXMLDocument(data) else {
				return .failure(.invalidXMLFile)
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

	private func resolveImportFileType(from fileName: String) -> MMTToolForAppTrans.ImportFileType? {
		let fileExtension = URL(fileURLWithPath: fileName).pathExtension.lowercased()

		switch fileExtension {
		case MMTToolForAppTrans.ImportFileType.mmttrans.rawValue, "xlsx":
			return .mmttrans
		case MMTToolForAppTrans.ImportFileType.xml.rawValue:
			return .xml
		default:
			return nil
		}
	}

	private func isZipContainer(_ data: Data) -> Bool {
		guard data.count >= 2 else {
			return false
		}

		return data.starts(with: [0x50, 0x4B])
	}

	private func isXMLDocument(_ data: Data) -> Bool {
		guard let string = String(data: data, encoding: .utf8) else {
			return false
		}

		let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
		return trimmedString.hasPrefix("<") && trimmedString.hasSuffix(">")
	}
}