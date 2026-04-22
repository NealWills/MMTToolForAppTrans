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

    private let currentLanguageLabel = UILabel()
    private let moduleLabel = UILabel()
    private let actionLabel = UILabel()
    private let loginButton = UIButton(type: .system)
    private let languageStackView = UIStackView()
    private let contentStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureLocalizationBundle()
        configureViewHierarchy()
        configureLanguageButtons()
        applyLocalizedContent()
    }

    private func configureLocalizationBundle() {
        if let bundleURL = Bundle.main.url(forResource: "localizeBundle", withExtension: "bundle"),
           let localizationBundle = Bundle(url: bundleURL) {
            MMTToolForAppTrans.shared.setLocalizationBundle(localizationBundle)
        }

        MMTToolForAppTrans.shared.setCurrentLanguage(.zhHans)
    }

    private func configureViewHierarchy() {
        currentLanguageLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        currentLanguageLabel.textColor = .darkGray

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

        languageStackView.axis = .vertical
        languageStackView.spacing = 12
        languageStackView.distribution = .fillEqually

        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        [
            currentLanguageLabel,
            moduleLabel,
            actionLabel,
            loginButton,
            languageStackView,
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

    private func configureLanguageButtons() {
        [
            makeLanguageButton(title: "English", language: .enUS),
            makeLanguageButton(title: "简体中文", language: .zhHans),
            makeLanguageButton(title: "繁體中文", language: .zhHant),
            makeLanguageButton(title: "Français", language: .fr),
            makeLanguageButton(title: "Deutsch", language: .de),
            makeLanguageButton(title: "Español", language: .es),
            makeLanguageButton(title: "Italiano", language: .it),
        ].forEach { button in
            languageStackView.addArrangedSubview(button)
        }
    }

    private func makeLanguageButton(title: String, language: MMTToolForAppTrans.Language) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        button.tag = languageTag(for: language)
        button.addTarget(self, action: #selector(handleLanguageTap(_:)), for: .touchUpInside)
        return button
    }

    private func applyLocalizedContent() {
        let currentLanguage = MMTToolForAppTrans.shared.getCurrentLanguage()
        currentLanguageLabel.text = "Current: " + displayName(for: currentLanguage)
        moduleLabel.text = MMTLocal(key: "key_module_login")
        actionLabel.text = MMTLocal(key: "key_login_go_to_login")
        loginButton.setTitle(MMTLocal(key: "key_login_log_in"), for: .normal)
        title = MMTLocal(key: "key_login_go_to_login")
    }

    @objc
    private func handleLanguageTap(_ sender: UIButton) {
        guard let language = language(for: sender.tag) else {
            return
        }

        MMTToolForAppTrans.shared.setCurrentLanguage(language)
        applyLocalizedContent()
    }

    private func languageTag(for language: MMTToolForAppTrans.Language) -> Int {
        switch language {
        case .enUS:
            return 1
        case .zhHans:
            return 2
        case .zhHant:
            return 3
        case .fr:
            return 4
        case .de:
            return 5
        case .es:
            return 6
        case .it:
            return 7
        }
    }

    private func language(for tag: Int) -> MMTToolForAppTrans.Language? {
        switch tag {
        case 1:
            return .enUS
        case 2:
            return .zhHans
        case 3:
            return .zhHant
        case 4:
            return .fr
        case 5:
            return .de
        case 6:
            return .es
        case 7:
            return .it
        default:
            return nil
        }
    }

    private func displayName(for language: MMTToolForAppTrans.Language) -> String {
        switch language {
        case .enUS:
            return "English"
        case .zhHans:
            return "简体中文"
        case .zhHant:
            return "繁體中文"
        case .fr:
            return "French"
        case .de:
            return "German"
        case .es:
            return "Spanish"
        case .it:
            return "Italian"
        }
    }

}

