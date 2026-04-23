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

    private struct LanguageToggleItem {
        let language: MMTToolForAppTrans.Language
        let title: String
        let isLocked: Bool
    }

    private let currentLanguageLabel = UILabel()
    private let validLanguageLabel = UILabel()
    private let fallbackStateLabel = UILabel()
    private let moduleLabel = UILabel()
    private let actionLabel = UILabel()
    private let loginButton = UIButton(type: .system)
    private let toolButton = UIButton(type: .system)
    private let toggleHintLabel = UILabel()
    private let languageStackView = UIStackView()
    private let contentStackView = UIStackView()
    private var languageToggleSwitches: [MMTToolForAppTrans.Language: UISwitch] = [:]

    private let toggleItems: [LanguageToggleItem] = [
        LanguageToggleItem(language: .enUS, title: "English fallback baseline", isLocked: true),
        LanguageToggleItem(language: .zhHans, title: "Enable 简体中文", isLocked: false),
        LanguageToggleItem(language: .zhHant, title: "Enable 繁體中文", isLocked: false),
        LanguageToggleItem(language: .fr, title: "Enable Français", isLocked: false),
        LanguageToggleItem(language: .de, title: "Enable Deutsch", isLocked: false),
        LanguageToggleItem(language: .es, title: "Enable Español", isLocked: false),
        LanguageToggleItem(language: .it, title: "Enable Italiano", isLocked: false)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureLocalizationBundle()
        configureViewHierarchy()
        configureLanguageToggles()
        applyLocalizedContent()
    }

    private func configureLocalizationBundle() {
        MMTToolForAppTrans.initialize()

        if let bundleURL = Bundle.main.url(forResource: "localizeBundle", withExtension: "bundle"),
           let localizationBundle = Bundle(url: bundleURL) {
            MMTToolForAppTrans.setLocalizationBundle(localizationBundle)
            _ = MMTToolForAppTrans.synchronizeCurrentLocalizationBundleToDatabase()
        }

        MMTToolForAppTrans.setValidLanguageList(defaultValidLanguageList())
        MMTToolForAppTrans.setCurrentLanguage(.zhHans)
    }

    private func configureViewHierarchy() {
        currentLanguageLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        currentLanguageLabel.textColor = .darkGray

        validLanguageLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        validLanguageLabel.textColor = .gray
        validLanguageLabel.numberOfLines = 0

        fallbackStateLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        fallbackStateLabel.numberOfLines = 0

        toggleHintLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        toggleHintLabel.textColor = .darkGray
        toggleHintLabel.numberOfLines = 0
        toggleHintLabel.text = "Toggle languages in validList. English stays on as the fallback baseline."

        moduleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        moduleLabel.textAlignment = .center
        moduleLabel.numberOfLines = 0

        actionLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        actionLabel.textAlignment = .center
        actionLabel.numberOfLines = 0
        actionLabel.textColor = .black

        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = .systemBlue
        loginButton.layer.cornerRadius = 12
        loginButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 24, bottom: 14, right: 24)

        toolButton.setTitle("Open Tools", for: .normal)
        toolButton.setTitleColor(.systemBlue, for: .normal)
        toolButton.layer.cornerRadius = 12
        toolButton.layer.borderWidth = 1
        toolButton.layer.borderColor = UIColor.systemBlue.cgColor
        toolButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 24, bottom: 14, right: 24)
        toolButton.addTarget(self, action: #selector(handleToolTap), for: .touchUpInside)

        languageStackView.axis = .vertical
        languageStackView.spacing = 12
        languageStackView.distribution = .fillEqually

        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        [
            currentLanguageLabel,
            validLanguageLabel,
            fallbackStateLabel,
            toggleHintLabel,
            languageStackView,
            moduleLabel,
            actionLabel,
            loginButton,
            toolButton,
        ].forEach { view in
            contentStackView.addArrangedSubview(view)
        }

        view.addSubview(contentStackView)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 24),
            contentStackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -24),
            contentStackView.centerYAnchor.constraint(equalTo: guide.centerYAnchor)
        ])
    }

    private func configureLanguageToggles() {
        toggleItems.forEach { item in
            let row = makeLanguageToggleRow(for: item)
            languageStackView.addArrangedSubview(row)
        }
    }

    private func makeLanguageToggleRow(for item: LanguageToggleItem) -> UIView {
        let button = makeLanguageButton(language: item.language)

        let toggleSwitch = UISwitch()
        toggleSwitch.isOn = defaultValidLanguageList().contains(item.language)
        toggleSwitch.isEnabled = item.isLocked == false
        toggleSwitch.onTintColor = .systemGreen
        toggleSwitch.tintColor = .systemGray3
        toggleSwitch.backgroundColor = .systemGray5
        toggleSwitch.layer.cornerRadius = 16
        toggleSwitch.thumbTintColor = .white
        toggleSwitch.tag = item.language.rawValue
        toggleSwitch.addTarget(self, action: #selector(handleLanguageToggle(_:)), for: .valueChanged)
        languageToggleSwitches[item.language] = toggleSwitch

        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = item.isLocked ? .systemBlue : .secondaryLabel
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .right
        titleLabel.text = item.title

        let toggleContainer = UIStackView(arrangedSubviews: [titleLabel, toggleSwitch])
        toggleContainer.axis = .vertical
        toggleContainer.spacing = 4
        toggleContainer.alignment = .trailing

        let row = UIStackView(arrangedSubviews: [button, toggleContainer])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        row.distribution = .fill
        return row
    }

    private func makeLanguageButton(language: MMTToolForAppTrans.Language) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(buttonTitle(for: language), for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = buttonBorderColor(for: language).cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        button.tag = language.rawValue
        button.addTarget(self, action: #selector(handleLanguageTap(_:)), for: .touchUpInside)
        button.contentHorizontalAlignment = .left
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return button
    }

    private func defaultValidLanguageList() -> [MMTToolForAppTrans.Language] {
        [.enUS, .zhHans, .zhHant]
    }

    private func currentValidLanguageListFromSwitches() -> [MMTToolForAppTrans.Language] {
        let enabledLanguages = toggleItems.compactMap { item -> MMTToolForAppTrans.Language? in
            guard let toggleSwitch = languageToggleSwitches[item.language] else {
                return item.isLocked ? item.language : nil
            }

            return toggleSwitch.isOn ? item.language : nil
        }

        if enabledLanguages.contains(.enUS) {
            return enabledLanguages
        }

        return [.enUS] + enabledLanguages
    }

    private func applyLocalizedContent() {
        let currentLanguage = MMTToolForAppTrans.getCurrentLanguage()
        let validLanguageList = MMTToolForAppTrans.getValidLanguageList()
        let isCurrentLanguageValid = validLanguageList.contains(currentLanguage)

        currentLanguageLabel.text = "Selected: " + currentLanguage.titleValue
        validLanguageLabel.text = "Valid list: " + validLanguageList.map(\.titleValue).joined(separator: ", ")
        fallbackStateLabel.text = isCurrentLanguageValid
            ? "Lookup mode: use selected language directly"
            : "Lookup mode: selected language is outside valid list, so content falls back to English"
        fallbackStateLabel.textColor = isCurrentLanguageValid ? .systemGreen : .systemOrange
        moduleLabel.text = MMTToolForAppTrans.localizedString(forKey: "key_module_login")
        actionLabel.text = MMTToolForAppTrans.localizedString(forKey: "key_login_go_to_login")
        loginButton.setTitle(MMTToolForAppTrans.localizedString(forKey: "key_login_log_in"), for: .normal)
        title = MMTToolForAppTrans.localizedString(forKey: "key_login_go_to_login")
        refreshLanguageButtonStyles(selectedLanguage: currentLanguage)
    }

    private func buttonTitle(for language: MMTToolForAppTrans.Language) -> String {
        if MMTToolForAppTrans.getValidLanguageList().contains(language) {
            return language.titleValue
        }

        return language.titleValue + " (English fallback)"
    }

    private func buttonBorderColor(for language: MMTToolForAppTrans.Language) -> UIColor {
        MMTToolForAppTrans.getValidLanguageList().contains(language) ? .systemBlue : .systemOrange
    }

    private func refreshLanguageButtonStyles(selectedLanguage: MMTToolForAppTrans.Language) {
        languageStackView.arrangedSubviews.forEach { view in
            guard let row = view as? UIStackView,
                  let button = row.arrangedSubviews.first as? UIButton,
                  let language = MMTToolForAppTrans.Language(rawValue: button.tag) else {
                return
            }

            let isSelected = language == selectedLanguage
            let borderColor = buttonBorderColor(for: language)

            button.setTitle(buttonTitle(for: language), for: .normal)
            button.layer.borderColor = borderColor.cgColor
            button.backgroundColor = isSelected ? borderColor.withAlphaComponent(0.15) : .clear
        }
    }

    @objc
    private func handleLanguageTap(_ sender: UIButton) {
        guard let language = MMTToolForAppTrans.Language(rawValue: sender.tag) else {
            return
        }

        MMTToolForAppTrans.setCurrentLanguage(language)
        applyLocalizedContent()
    }

    @objc
    private func handleLanguageToggle(_ sender: UISwitch) {
        guard MMTToolForAppTrans.Language(rawValue: sender.tag) != nil else {
            return
        }

        MMTToolForAppTrans.setValidLanguageList(currentValidLanguageListFromSwitches())
        applyLocalizedContent()
    }

    @objc
    private func handleToolTap() {
        let viewController = MMTToolForAppTrans.makeToolsViewController()
        viewController.modalPresentationStyle = .pageSheet
        present(viewController, animated: true)
    }

}

