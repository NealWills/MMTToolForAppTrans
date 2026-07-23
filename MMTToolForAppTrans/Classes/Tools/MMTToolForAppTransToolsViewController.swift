import UIKit

private final class MMTToolForAppTransDatabaseRecordCell: UITableViewCell {

	static let reuseIdentifier = "MMTToolForAppTransDatabaseRecordCell"

	private let cardView = UIView()
	private let titleLabel = UILabel()
	private let detailLabel = UILabel()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureUI()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(with record: MMTToolForAppTrans.LocalizationRecord, detailText: String) {
		titleLabel.text = "#\(record.identifier)  \(record.key ?? "(no key)")"
		detailLabel.text = detailText
	}

	private func configureUI() {
		backgroundColor = .clear
		selectionStyle = .none
		contentView.backgroundColor = .clear

		cardView.translatesAutoresizingMaskIntoConstraints = false
		cardView.backgroundColor = .secondarySystemBackground
		cardView.layer.cornerRadius = 14
		cardView.layer.cornerCurve = .continuous
		cardView.layer.borderWidth = 1
		cardView.layer.borderColor = UIColor.separator.cgColor
		contentView.addSubview(cardView)

		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.numberOfLines = 0
		titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
		titleLabel.textColor = .label

		detailLabel.translatesAutoresizingMaskIntoConstraints = false
		detailLabel.numberOfLines = 0
		detailLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
		detailLabel.textColor = .secondaryLabel

		cardView.addSubview(titleLabel)
		cardView.addSubview(detailLabel)

		NSLayoutConstraint.activate([
			cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
			cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
			titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
			titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
			titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
			detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
			detailLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
			detailLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
			detailLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14)
		])
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		cardView.layer.borderColor = UIColor.separator.cgColor
	}
}

public final class MMTToolForAppTransToolsViewController: UIViewController {

	private let stackView = UIStackView()
	private let descriptionLabel = UILabel()
	private let databaseButton = UIButton(type: .system)

	public override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		title = "Tools"
		configureUI()
	}

	private func configureUI() {
		descriptionLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
		descriptionLabel.textColor = .secondaryLabel
		descriptionLabel.numberOfLines = 0
		descriptionLabel.text = "Browse the localization tool modules exposed by MMTToolForAppTrans."

		databaseButton.setTitle("Database Viewer", for: .normal)
		databaseButton.setTitleColor(.systemBlue, for: .normal)
		databaseButton.backgroundColor = .tertiarySystemBackground
		databaseButton.layer.cornerRadius = 12
		databaseButton.layer.borderWidth = 1
		databaseButton.layer.borderColor = UIColor.separator.cgColor
		databaseButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 18, bottom: 16, right: 18)
		databaseButton.contentHorizontalAlignment = .left
		databaseButton.addTarget(self, action: #selector(handleDatabaseTap), for: .touchUpInside)

		stackView.axis = .vertical
		stackView.spacing = 16
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.addArrangedSubview(descriptionLabel)
		stackView.addArrangedSubview(databaseButton)

		view.addSubview(stackView)

		let guide = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 24),
			stackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20),
			stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20)
		])
	}

	public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		databaseButton.layer.borderColor = UIColor.separator.cgColor
	}

	@objc
	private func handleDatabaseTap() {
		navigationController?.pushViewController(MMTToolForAppTransDatabaseRecordsViewController(), animated: true)
	}
}

public final class MMTToolForAppTransDatabaseRecordsViewController: UIViewController {

	private let tableView = UITableView(frame: .zero, style: .plain)
	private let emptyStateLabel = UILabel()
	private let paginationContainer = UIStackView()
	private let previousPageButton = UIButton(type: .system)
	private let nextPageButton = UIButton(type: .system)
	private let pageIndicatorLabel = UILabel()
	private let searchController = UISearchController(searchResultsController: nil)
	private let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .short
		return formatter
	}()

	private var records: [MMTToolForAppTrans.LocalizationRecord] = []
	private var filteredRecords: [MMTToolForAppTrans.LocalizationRecord] = []
	private let pageSize = 10
	private var currentPage = 0
	private var committedSearchText = ""

	private var normalizedCommittedSearchText: String {
		normalizedSearchToken(from: committedSearchText)
	}

	private var pagedRecords: [MMTToolForAppTrans.LocalizationRecord] {
		let startIndex = currentPage * pageSize
		let endIndex = min(startIndex + pageSize, filteredRecords.count)
		guard startIndex < endIndex else {
			return []
		}
		return Array(filteredRecords[startIndex..<endIndex])
	}

	private var totalPages: Int {
		guard filteredRecords.isEmpty == false else {
			return 0
		}
		return Int(ceil(Double(filteredRecords.count) / Double(pageSize)))
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		title = "Database"
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDoneTap))
		configureSearchController()
		configureTableView()
		configurePaginationView()
		reloadRecords()
	}

	public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		updatePaginationAppearance()
	}

	private func configureSearchController() {
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search key or text"
		searchController.searchBar.delegate = self
		searchController.searchBar.returnKeyType = .search
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		definesPresentationContext = true
	}

	private func configureTableView() {
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 132
		tableView.separatorStyle = .none
		tableView.backgroundColor = .clear
		tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
		tableView.register(MMTToolForAppTransDatabaseRecordCell.self, forCellReuseIdentifier: MMTToolForAppTransDatabaseRecordCell.reuseIdentifier)
		view.addSubview(tableView)

		paginationContainer.translatesAutoresizingMaskIntoConstraints = false
		paginationContainer.backgroundColor = .clear
		view.addSubview(paginationContainer)

		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: paginationContainer.topAnchor, constant: -12),
			paginationContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			paginationContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			paginationContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
		])

		emptyStateLabel.text = "Database is empty."
		emptyStateLabel.textColor = .secondaryLabel
		emptyStateLabel.textAlignment = .center
		emptyStateLabel.numberOfLines = 0
		emptyStateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
	}

	private func configurePaginationView() {
		paginationContainer.axis = .horizontal
		paginationContainer.alignment = .center
		paginationContainer.distribution = .fillEqually
		paginationContainer.spacing = 12

		previousPageButton.setTitle("Previous", for: .normal)
		previousPageButton.layer.cornerRadius = 10
		previousPageButton.layer.borderWidth = 1
		previousPageButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
		previousPageButton.addTarget(self, action: #selector(handlePreviousPageTap), for: .touchUpInside)

		nextPageButton.setTitle("Next", for: .normal)
		nextPageButton.layer.cornerRadius = 10
		nextPageButton.layer.borderWidth = 1
		nextPageButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
		nextPageButton.addTarget(self, action: #selector(handleNextPageTap), for: .touchUpInside)

		pageIndicatorLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
		pageIndicatorLabel.textAlignment = .center
		pageIndicatorLabel.numberOfLines = 2
		pageIndicatorLabel.textColor = .secondaryLabel

		paginationContainer.addArrangedSubview(previousPageButton)
		paginationContainer.addArrangedSubview(pageIndicatorLabel)
		paginationContainer.addArrangedSubview(nextPageButton)
		updatePaginationAppearance()
	}

	private func updatePaginationAppearance() {
		[previousPageButton, nextPageButton].forEach { button in
			button.backgroundColor = .tertiarySystemBackground
			button.layer.borderColor = UIColor.separator.cgColor
		}
	}

	private func reloadRecords() {
		records = MMTToolForAppTrans.getAllLocalizationRecords()
		applySearch()
	}

	private func applySearch() {
		if normalizedCommittedSearchText.isEmpty {
			filteredRecords = records
		} else {
			filteredRecords = records.filter { record in
				searchableText(for: record).contains(normalizedCommittedSearchText)
			}
		}

		currentPage = 0
		emptyStateLabel.text = normalizedCommittedSearchText.isEmpty ? "Database is empty." : "No matching records."
		tableView.backgroundView = filteredRecords.isEmpty ? emptyStateLabel : nil
		updatePaginationState()
		tableView.reloadData()
	}

	private func searchableText(for record: MMTToolForAppTrans.LocalizationRecord) -> String {
		searchableFragments(for: record)
			.map(normalizedSearchToken(from:))
			.joined(separator: "\n")
	}

	private func searchableFragments(for record: MMTToolForAppTrans.LocalizationRecord) -> [String] {
		[
			record.key,
			record.description,
			record.valueEnUS,
			record.valueZhHans,
			record.valueZhHant,
			record.valueFr,
			record.valueDe,
			record.valueEs,
			record.valueIt,
			record.valuePl,
			record.valueKo,
			record.valueRu,
			record.valueUk
		]
		.compactMap { value in
			guard let value else {
				return nil
			}
			let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
			return trimmedValue.isEmpty ? nil : trimmedValue
		}
	}

	private func normalizedSearchToken(from text: String) -> String {
		text
			.folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: .current)
			.lowercased()
	}

	private func updatePaginationState() {
		let hasPages = totalPages > 0
		paginationContainer.isHidden = hasPages == false
		previousPageButton.isEnabled = currentPage > 0
		nextPageButton.isEnabled = currentPage + 1 < totalPages
		previousPageButton.alpha = previousPageButton.isEnabled ? 1.0 : 0.45
		nextPageButton.alpha = nextPageButton.isEnabled ? 1.0 : 0.45

		if hasPages {
			let startIndex = currentPage * pageSize + 1
			let endIndex = min((currentPage + 1) * pageSize, filteredRecords.count)
			pageIndicatorLabel.text = "Page \(currentPage + 1) / \(totalPages)\n\(startIndex)-\(endIndex) of \(filteredRecords.count)"
		} else {
			pageIndicatorLabel.text = nil
		}
	}

	private func detailText(for record: MMTToolForAppTrans.LocalizationRecord) -> String {
		var lines: [String] = []
		lines.append("Status: \(record.description ?? "-") | Deleted: \(record.isDeleted ? "Yes" : "No")")
		if let createDate = record.createDate {
			lines.append("Created: \(dateFormatter.string(from: createDate))")
		}
		if let updateDate = record.updateDate {
			lines.append("Updated: \(dateFormatter.string(from: updateDate))")
		}

		[
			("en_US", record.valueEnUS),
			("zh_Hans", record.valueZhHans),
			("zh_Hant", record.valueZhHant),
			("fr", record.valueFr),
			("de", record.valueDe),
			("es", record.valueEs),
			("it", record.valueIt),
			("pl", record.valuePl),
			("ko", record.valueKo),
			("ru", record.valueRu),
			("uk", record.valueUk)
		]
		.filter { _, value in
			guard let value else {
				return false
			}
			return value.isEmpty == false
		}
		.forEach { language, value in
			lines.append("\(language): \(value ?? "")")
		}

		return lines.joined(separator: "\n")
	}

	@objc
	private func handleDoneTap() {
		dismiss(animated: true)
	}

	@objc
	private func handlePreviousPageTap() {
		guard currentPage > 0 else {
			return
		}
		currentPage -= 1
		updatePaginationState()
		tableView.reloadData()
		tableView.setContentOffset(.zero, animated: false)
	}

	@objc
	private func handleNextPageTap() {
		guard currentPage + 1 < totalPages else {
			return
		}
		currentPage += 1
		updatePaginationState()
		tableView.reloadData()
		tableView.setContentOffset(.zero, animated: false)
	}
}

extension MMTToolForAppTransDatabaseRecordsViewController: UITableViewDataSource {

	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		pagedRecords.count
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: MMTToolForAppTransDatabaseRecordCell.reuseIdentifier, for: indexPath)
		let record = pagedRecords[indexPath.row]
		guard let cell = cell as? MMTToolForAppTransDatabaseRecordCell else {
			return cell
		}
		cell.configure(with: record, detailText: detailText(for: record))
		return cell
	}
}

extension MMTToolForAppTransDatabaseRecordsViewController: UITableViewDelegate {
}

extension MMTToolForAppTransDatabaseRecordsViewController: UISearchBarDelegate {

	public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		committedSearchText = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
		applySearch()
		searchBar.resignFirstResponder()
	}

	public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		guard searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
			return
		}
		committedSearchText = ""
		applySearch()
	}

	public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		committedSearchText = ""
		applySearch()
	}
}
