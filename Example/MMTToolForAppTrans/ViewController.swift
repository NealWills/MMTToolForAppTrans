//
//  ViewController.swift
//  MMTToolForAppTrans
//
//  Created by NealWills on 04/22/2026.
//  Copyright (c) 2026 NealWills. All rights reserved.
//

import UIKit
import MMTToolForAppTrans

class ViewController: UIViewController {

    // MARK: - Data

    private let allLanguages = MMTToolForAppTrans.Language.allLanguageList()
    private var validLanguages: [MMTToolForAppTrans.Language] = [.enUS, .zhHans, .zhHant]
    private var currentLanguage: MMTToolForAppTrans.Language = .zhHans {
        didSet { refreshAll() }
    }

    private let demoKeys = [
        "key_module_login",
        "key_login_go_to_login",
        "key_login_log_in",
    ]

    // MARK: - Subviews

    private let keyValueCard = KeyValueCardView()
    private let scrollView = UIScrollView()
    private let containerView = UIView()

    private let languageSection = SectionHeaderView(title: "Select Language")
    private let languageCollectionView = LanguageCollectionView()
    private let validSection = SectionHeaderView(title: "Valid Language List")
    private let validStack = UIStackView()
    private let toolButton = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "MMTToolForAppTrans"
        setupLocalization()
        setupViews()
        refreshAll()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentOffset = .zero
    }

    // MARK: - Setup

    private func setupLocalization() {
        MMTToolForAppTrans.initialize()

        if let bundleURL = Bundle.main.url(forResource: "localizeBundle", withExtension: "bundle"),
           let localizationBundle = Bundle(url: bundleURL) {
            MMTToolForAppTrans.setLocalizationBundle(localizationBundle)
            _ = MMTToolForAppTrans.synchronizeCurrentLocalizationBundleToDatabase()
        }

        MMTToolForAppTrans.setValidLanguageList(validLanguages)
        MMTToolForAppTrans.setCurrentLanguage(currentLanguage)
    }

    private func setupViews() {
        // Key-value card pinned at top
        keyValueCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyValueCard)

        // Scroll view for everything else
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containerView)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            keyValueCard.topAnchor.constraint(equalTo: guide.topAnchor, constant: 16),
            keyValueCard.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20),
            keyValueCard.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20),

            scrollView.topAnchor.constraint(equalTo: keyValueCard.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),

            containerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])

        // Language selection
        languageSection.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(languageSection)

        languageCollectionView.onLanguageSelected = { [weak self] language in
            guard let self else { return }
            if self.validLanguages.contains(language) == false {
                self.validLanguages.append(language)
                MMTToolForAppTrans.setValidLanguageList(self.validLanguages)
            }
            self.currentLanguage = language
        }
        languageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(languageCollectionView)

        // Valid language toggles
        validSection.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(validSection)

        validStack.axis = .vertical
        validStack.spacing = 0
        validStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(validStack)

        for language in allLanguages {
            let isLocked = language == .enUS
            let toggleView = LanguageToggleView(
                language: language,
                isOn: validLanguages.contains(language),
                isLocked: isLocked
            )
            toggleView.onToggle = { [weak self] language, isOn in
                self?.handleValidToggle(language: language, isOn: isOn)
            }
            validStack.addArrangedSubview(toggleView)

            if language != allLanguages.last {
                let divider = UIView()
                divider.backgroundColor = .separator
                divider.translatesAutoresizingMaskIntoConstraints = false
                validStack.addArrangedSubview(divider)
                divider.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
            }
        }

        // Tools button
        toolButton.setTitle("Open Tools", for: .normal)
        toolButton.setTitleColor(.white, for: .normal)
        toolButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        toolButton.backgroundColor = .systemBlue
        toolButton.layer.cornerRadius = 14
        toolButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
        toolButton.addTarget(self, action: #selector(handleToolTap), for: .touchUpInside)
        toolButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(toolButton)

        let margin: CGFloat = 20
        NSLayoutConstraint.activate([
            languageSection.topAnchor.constraint(equalTo: containerView.topAnchor),
            languageSection.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: margin),
            languageSection.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -margin),

            languageCollectionView.topAnchor.constraint(equalTo: languageSection.bottomAnchor, constant: 8),
            languageCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: margin),
            languageCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -margin),

            validSection.topAnchor.constraint(equalTo: languageCollectionView.bottomAnchor, constant: 24),
            validSection.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: margin),
            validSection.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -margin),

            validStack.topAnchor.constraint(equalTo: validSection.bottomAnchor, constant: 8),
            validStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: margin),
            validStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -margin),

            toolButton.topAnchor.constraint(equalTo: validStack.bottomAnchor, constant: 24),
            toolButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            toolButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),
        ])
    }

    // MARK: - Actions

    private func handleValidToggle(language: MMTToolForAppTrans.Language, isOn: Bool) {
        if isOn {
            if validLanguages.contains(language) == false {
                validLanguages.append(language)
            }
        } else {
            validLanguages.removeAll { $0 == language }
        }
        if validLanguages.contains(.enUS) == false {
            validLanguages.insert(.enUS, at: 0)
        }
        MMTToolForAppTrans.setValidLanguageList(validLanguages)
        refreshAll()
    }

    private func refreshAll() {
        MMTToolForAppTrans.setCurrentLanguage(currentLanguage)
        keyValueCard.refresh()
        languageCollectionView.configure(
            languages: allLanguages,
            selectedLanguage: currentLanguage,
            validLanguages: validLanguages
        )
        for case let toggleView as LanguageToggleView in validStack.arrangedSubviews {
            toggleView.setIsOn(validLanguages.contains(toggleView.language))
        }
    }

    @objc
    private func handleToolTap() {
        let vc = MMTToolForAppTrans.makeToolsViewController()
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }
}

// MARK: - KeyValueCardView

private final class KeyValueCardView: UIView {

    private let languageLabel = UILabel()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 14
        layer.cornerCurve = .continuous

        languageLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        languageLabel.textColor = .secondaryLabel
        languageLabel.numberOfLines = 0

        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let outerStack = UIStackView(arrangedSubviews: [languageLabel, stackView])
        outerStack.axis = .vertical
        outerStack.spacing = 12
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(outerStack)

        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            outerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            outerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            outerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])
    }

    func refresh() {
        let currentLanguage = MMTToolForAppTrans.getCurrentLanguage()
        languageLabel.text = "Language: \(currentLanguage.titleValue)"

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let keys = [
            "key_module_login",
            "key_login_go_to_login",
            "key_login_log_in",
            "key_ai_answer_recipe_cook_awaken_title",
        ]

        for key in keys {
            let value = MMTToolForAppTrans.localizedString(forKey: key) ?? key
            let row = makeKeyValueRow(key: key, value: value)
            stackView.addArrangedSubview(row)
        }
    }

    private func makeKeyValueRow(key: String, value: String) -> UIView {
        let keyLabel = UILabel()
        keyLabel.text = key
        keyLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        keyLabel.textColor = .tertiaryLabel
        keyLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 0
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [keyLabel, valueLabel])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .top
        return row
    }
}

// MARK: - SectionHeaderView

private final class SectionHeaderView: UIView {

    private let label = UILabel()

    init(title: String) {
        super.init(frame: .zero)
        label.text = title
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) { nil }
}

// MARK: - LanguageCollectionView

private final class LanguageCollectionView: UIView {

    var onLanguageSelected: ((MMTToolForAppTrans.Language) -> Void)?

    private var languageButtons: [LanguageButton] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) { nil }

    func configure(languages: [MMTToolForAppTrans.Language], selectedLanguage: MMTToolForAppTrans.Language, validLanguages: [MMTToolForAppTrans.Language]) {
        subviews.forEach { $0.removeFromSuperview() }
        languageButtons.removeAll()

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        for language in languages {
            let isValid = validLanguages.contains(language)
            let isSelected = language == selectedLanguage
            let button = LanguageButton(language: language)
            button.configure(isSelected: isSelected, isValid: isValid)
            button.addTarget(self, action: #selector(handleTap(_:)), for: .touchUpInside)
            stack.addArrangedSubview(button)
            languageButtons.append(button)
        }
    }

    @objc
    private func handleTap(_ sender: LanguageButton) {
        onLanguageSelected?(sender.language)
    }
}

// MARK: - LanguageButton

private final class LanguageButton: UIButton {

    let language: MMTToolForAppTrans.Language

    init(language: MMTToolForAppTrans.Language) {
        self.language = language
        super.init(frame: .zero)
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        contentHorizontalAlignment = .left
        contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        layer.cornerRadius = 12
        layer.cornerCurve = .continuous
    }

    required init?(coder: NSCoder) { nil }

    func configure(isSelected: Bool, isValid: Bool) {
        let title = language.titleValue + (isValid ? "" : " (fallback to English)")
        setTitle(title, for: .normal)

        if isSelected {
            backgroundColor = isValid ? UIColor.systemBlue.withAlphaComponent(0.15) : UIColor.systemOrange.withAlphaComponent(0.15)
            layer.borderWidth = 2
            layer.borderColor = (isValid ? UIColor.systemBlue : UIColor.systemOrange).cgColor
            setTitleColor(isValid ? .systemBlue : .systemOrange, for: .normal)
        } else {
            backgroundColor = .secondarySystemGroupedBackground
            layer.borderWidth = 1
            layer.borderColor = UIColor.separator.cgColor
            setTitleColor(isValid ? .label : .secondaryLabel, for: .normal)
        }
    }
}

// MARK: - LanguageToggleView

private final class LanguageToggleView: UIView {

    let language: MMTToolForAppTrans.Language
    var onToggle: ((MMTToolForAppTrans.Language, Bool) -> Void)?

    private let titleLabel = UILabel()
    private let toggleSwitch = UISwitch()

    init(language: MMTToolForAppTrans.Language, isOn: Bool, isLocked: Bool) {
        self.language = language
        super.init(frame: .zero)

        titleLabel.text = language.titleValue
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        toggleSwitch.isOn = isOn
        toggleSwitch.isEnabled = isLocked == false
        toggleSwitch.onTintColor = .systemGreen
        toggleSwitch.addTarget(self, action: #selector(handleToggle(_:)), for: .valueChanged)

        let stack = UIStackView(arrangedSubviews: [titleLabel, toggleSwitch])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])

        backgroundColor = .secondarySystemGroupedBackground
    }

    required init?(coder: NSCoder) { nil }

    func setIsOn(_ isOn: Bool) {
        toggleSwitch.isOn = isOn
    }

    @objc
    private func handleToggle(_ sender: UISwitch) {
        onToggle?(language, sender.isOn)
    }
}
