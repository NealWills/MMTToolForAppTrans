![image](Resources/MMTToolForAppTrans.png)

# MMTToolForAppTrans

[![CI Status](https://img.shields.io/travis/NealWills/MMTToolForAppTrans.svg?style=flat)](https://travis-ci.org/NealWills/MMTToolForAppTrans)
[![Version](https://img.shields.io/cocoapods/v/MMTToolForAppTrans.svg?style=flat)](https://cocoapods.org/pods/MMTToolForAppTrans)
[![License](https://img.shields.io/cocoapods/l/MMTToolForAppTrans.svg?style=flat)](https://cocoapods.org/pods/MMTToolForAppTrans)
[![Platform](https://img.shields.io/cocoapods/p/MMTToolForAppTrans.svg?style=flat)](https://cocoapods.org/pods/MMTToolForAppTrans)

## Overview

MMTToolForAppTrans is a translation-oriented iOS library focused on storing and managing app localization records.

The current implementation is organized as a facade-driven module set. It stores localization records through a WCDB-backed storage layer and resolves keys into localized values with an in-memory LRU cache.

The current priority path is bundle-based localization loading. A localization bundle can be registered at runtime, and key lookup will read the bundle first before falling back to the storage layer.

The runtime path now also includes inline code comments around bundle registration, import validation, cache behavior, and storage fallback.

At the repository level, the project is split into three main parts:

- `MMTToolForAppTrans/`: the Pod source code.
- `Example/`: the CocoaPods integration demo project.
- `Doc/`: the internal structure guide for quick onboarding.

## Core Structure

The library is now split into a public facade plus several focused runtime modules.

- `MMTToolForAppTrans/Classes/MMTToolForAppTrans.swift`
	- Public entry facade.
	- Exposes import, language, state, and localization APIs.
- `MMTToolForAppTrans/Classes/Import/`
	- Keeps import-file handling isolated from the public localization API.
	- Supports the current `.mmttrans` import path without exposing Excel/XML as the main integration surface.
- `MMTToolForAppTrans/Classes/Storage/`
	- Wraps storage initialization and database queries.
	- Serves as the layer above the low-level WCDB implementation.
- `MMTToolForAppTrans/Classes/State/`
	- Stores runtime state such as the current language, current import file, and localization cache.
	- Maintains the access order for the in-memory LRU cache.
- `MMTToolForAppTrans/Classes/Localization/`
	- Resolves key -> value using the requested or current language.
	- Reads the current localization bundle first, then falls back to storage.
	- Uses a 200-entry in-memory LRU cache.
- `MMTToolForAppTrans/Classes/DB/`
	- Contains the low-level WCDB model, database manager, and table implementation.

If you only want to understand the codebase quickly, start from the public facade, then read State, Import, Storage, and Localization in that order before going into the DB layer.

## Documentation

For a quick overview of the repository structure, start here:

- [Doc/README.md](Doc/README.md)
- [Doc/Structure.md](Doc/Structure.md)

Recommended reading order:

1. `README.md`
2. `Doc/Structure.md`
3. `MMTToolForAppTrans/Classes/MMTToolForAppTrans.swift`
4. `MMTToolForAppTrans/Classes/State/MMTToolForAppTransState.swift`
5. `MMTToolForAppTrans/Classes/Import/MMTToolForAppTransImportModule.swift`
6. `MMTToolForAppTrans/Classes/Storage/MMTToolForAppTransStorageModule.swift`
7. `MMTToolForAppTrans/Classes/Localization/MMTToolForAppTransLocalizationModule.swift`
8. `MMTToolForAppTrans/Classes/DB/`

## Example

To run the example project:

```bash
cd Example
pod install
open MMTToolForAppTrans.xcworkspace
```

The example project shows how the Pod is integrated into an iOS app target.

The current demo page registers `localizeBundle.bundle`, displays several localized labels, and allows switching between all supported languages at runtime.

Example runtime usage:

```swift
if let bundleURL = Bundle.main.url(forResource: "localizeBundle", withExtension: "bundle"),
   let localizationBundle = Bundle(url: bundleURL) {
	MMTToolForAppTrans.setLocalizationBundle(localizationBundle)
}

MMTToolForAppTrans.setCurrentLanguage(.zhHans)

let title = MMTToolForAppTrans.localizedString(forKey: "key_login_go_to_login")
let loginText = MMTToolForAppTrans.localizedString(forKey: "key_login_log_in", language: .enUS)
```

## Requirements

- iOS project environment with CocoaPods
- Swift
- WCDB dependency resolved through the Pod configuration

## Installation

MMTToolForAppTrans is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MMTToolForAppTrans'
```

Then run:

```bash
pod install
```

## What This Library Currently Provides

- Public APIs for registering a localization bundle at runtime.
- Key lookup from `.strings` files inside the current localization bundle.
- Internal fallback from bundle-based localization to the storage layer.
- Inline code comments around bundle registration, import validation, and localization lookup flow.
- Runtime language switching and current-language access.
- Key -> value resolution with explicit-language and current-language variants.
- A 200-entry in-memory LRU cache for localization lookup.
- A WCDB-based storage layer for localization records.
- A demo project for integration reference.

## Author

NealWills, Donghn@maxeye.com

## License

MMTToolForAppTrans is available under the MIT license. See the LICENSE file for more info.
