![image](Resources/MMTToolForAppTrans.png)

# MMTToolForAppTrans

[![CI Status](https://img.shields.io/travis/NealWills/MMTToolForAppTrans.svg?style=flat)](https://travis-ci.org/NealWills/MMTToolForAppTrans)
[![Version](https://img.shields.io/cocoapods/v/MMTToolForAppTrans.svg?style=flat)](https://cocoapods.org/pods/MMTToolForAppTrans)
[![License](https://img.shields.io/cocoapods/l/MMTToolForAppTrans.svg?style=flat)](https://cocoapods.org/pods/MMTToolForAppTrans)
[![Platform](https://img.shields.io/cocoapods/p/MMTToolForAppTrans.svg?style=flat)](https://cocoapods.org/pods/MMTToolForAppTrans)

## Overview

MMTToolForAppTrans is a translation-oriented iOS library focused on storing and managing app localization records.

The current implementation is centered on a WCDB-backed local database layer. It is designed to keep localizable string entries in a structured format so they can be inserted, updated, queried, and soft-deleted inside the app workflow.

At the repository level, the project is split into three main parts:

- `MMTToolForAppTrans/`: the Pod source code.
- `Example/`: the CocoaPods integration demo project.
- `Doc/`: the internal structure guide for quick onboarding.

## Core Structure

The library code is currently lightweight at the public entry level and concentrated in the database module.

- `MMTToolForAppTrans/Classes/MMTToolForAppTrans.swift`
	- Public entry type.
	- Currently acts as a lightweight shell.
- `MMTToolForAppTrans/Classes/DB/MMTToolForAppTransDBManager.swift`
	- Initializes the database.
	- Creates the working table.
	- Provides unified insert, update, and delete entry points.
- `MMTToolForAppTrans/Classes/DB/MMTToolForAppTransLocalizableTable.swift`
	- Defines the localizable model.
	- Manages table creation and CRUD operations.
	- Stores multilingual values such as English, Simplified Chinese, Traditional Chinese, French, German, Spanish, and Italian.

If you only want to understand the codebase quickly, start from the DB module.

## Documentation

For a quick overview of the repository structure, start here:

- [Doc/README.md](Doc/README.md)
- [Doc/Structure.md](Doc/Structure.md)

Recommended reading order:

1. `README.md`
2. `Doc/Structure.md`
3. `MMTToolForAppTrans/Classes/MMTToolForAppTrans.swift`
4. `MMTToolForAppTrans/Classes/DB/MMTToolForAppTransDBManager.swift`
5. `MMTToolForAppTrans/Classes/DB/MMTToolForAppTransLocalizableTable.swift`

## Example

To run the example project:

```bash
cd Example
pod install
open MMTToolForAppTrans.xcworkspace
```

The example project shows how the Pod is integrated into an iOS app target.

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

- A localizable string model for multilingual content storage.
- A WCDB-based local persistence layer.
- Insert, update, query, and soft-delete capabilities for localization records.
- A demo project for integration reference.

## Author

NealWills, Donghn@maxeye.com

## License

MMTToolForAppTrans is available under the MIT license. See the LICENSE file for more info.
