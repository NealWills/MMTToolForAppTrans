# MMTToolForAppTrans Structure Guide

## 1. Repository Layout

```text
MMTToolForAppTrans/
├── Doc/                             Documentation directory for structure and reading guidance
├── Example/                         CocoaPods example project
│   ├── MMTToolForAppTrans/          Demo app source code
│   ├── MMTToolForAppTrans.xcodeproj/
│   └── MMTToolForAppTrans.xcworkspace/
├── MMTToolForAppTrans/              Actual Pod source directory
│   ├── Assets/                      Resource directory, currently almost empty
│   └── Classes/                     Core Swift source code
│       ├── MMTToolForAppTrans.swift Public entry type
│       └── DB/                      Database storage implementation
├── Pods/                            Example project dependencies, generated content
├── _Pods.xcodeproj                  Pods project file
├── MMTToolForAppTrans.podspec       Pod release configuration
├── README.md                        Public-facing documentation
└── buildServer.json                 Build service configuration
```

## 2. Which Directories Matter Most

### Core Source Code

`MMTToolForAppTrans/Classes` is the most important directory in the current library.

- `MMTToolForAppTrans.swift`
  - Current public entry type.
  - The implementation is very lightweight and mainly acts as the external shell of the library.
- `DB/`
  - This is where the real business capability currently lives.
  - It handles localization model definitions, table structure, database initialization, and CRUD operations.

### Example Project

`Example/MMTToolForAppTrans` is used to demonstrate Pod integration.

- `AppDelegate.swift`: application startup entry.
- `ViewController.swift`: demo page.
- `Base.lproj/`, `Images.xcassets/`: example project resources.

### Configuration And Release

- `MMTToolForAppTrans.podspec`: defines exposed source files, version information, and dependencies.
- `README.md`: installation and overview documentation for users.

### Directories You Can Usually Ignore

- `Pods/`
  - This is generated content after installing dependencies for the example project.
  - You usually do not need to start here when reading the business logic.
- `Example/...xcworkspace`、`_Pods.xcodeproj`
  - These are project organization files and are mainly relevant when dealing with build or Pod integration issues.

## 3. Core Module Responsibilities

### 3.1 Public Entry

File: `MMTToolForAppTrans/Classes/MMTToolForAppTrans.swift`

Responsibilities:

- Acts as the public entry type of the library.
- Currently does not contain actual business logic.

This means:

- The real implementation is not currently inside the entry type.
- When reading or extending the library, you should go into the `DB/` directory first instead of staying at the entry type.

### 3.2 Database Enum And Protocols

File: `MMTToolForAppTrans/Classes/DB/MMTToolForAppTransDBEnum.swift`

Responsibilities:

- Defines database operation protocols:
  - `MMTToolForAppTransLocalCopyable`
  - `MMTToolForAppTransGenerateParamsProtocol`
- Provides parameter dictionary conversion capability.
- Defines the database operation unit enum `MMTToolForAppTransDBOperateUnit`.

How to understand it:

- This file acts more like the foundation contract of the DB layer.
- Upper layers pass specific models through operation units, and DBManager dispatches them.

### 3.3 Database Manager

File: `MMTToolForAppTrans/Classes/DB/MMTToolForAppTransDBManager.swift`

Responsibilities:

- Owns the singleton `shared`.
- Initializes the WCDB database.
- Creates the database directory and sqlite file.
- Creates the `localizableTable` table manager instance.
- Provides unified insert, delete, and update entry points.

Key points:

- The database is stored in the app sandbox at `Documents/.MMTToolForAppTrans/db/db.sqlite3`.
- The main operation entry points are:
  - `initTable()`
  - `insertNewItem(with:)`
  - `deleteNewItem(with:)`
  - `updateNewItem(with:)`

### 3.4 Localizable Model And Table Manager

File: `MMTToolForAppTrans/Classes/DB/MMTToolForAppTransLocalizableTable.swift`

This file carries two responsibilities at the same time.

First part: `MMTToolForAppTransLocalizableModel`

- Defines the table model.
- Includes fields for:
  - Primary key `identifier`
  - Status field `description`
  - Creation and update time
  - Soft-delete flag `is_delete`
  - Localization key `key`
  - Multilingual values such as `value_en_US`, `value_zh_hans`, `value_fr`, and others
- Uses WCDB `CodingKeys` to define the table mapping.

Second part: `MMTToolForAppTransLocalizableTable`

- Creates the table.
- Maintains `lastId`.
- Provides data operations:
  - `insertNew(_:)`
  - `deleteItem(_:)`
  - `update(_:)`
  - `getAllItems()`
  - `getItem(key:)`

Key points:

- Delete uses soft deletion by changing `is_delete` instead of physically removing the record.
- Query supports fetching the latest record by `key`.
- All core business logic currently revolves around this single localization record table.

## 4. Typical Call Flow

If you want to understand the library from a functional perspective, the shortest path is:

```text
App startup or business initialization
    ↓
MMTToolForAppTransDBManager.shared.initTable()
    ↓
Create MMTToolForAppTransLocalizableModel
    ↓
Wrap it with MMTToolForAppTransDBOperateUnit.localizableTable(model)
    ↓
Call DBManager insert / update / delete methods
    ↓
WCDB operations are executed by MMTToolForAppTransLocalizableTable underneath
```

If you want to debug an issue, check it in this order:

1. Check whether the business layer created `MMTToolForAppTransLocalizableModel` correctly.
2. Check whether `initTable()` was called first.
3. Check whether DBManager dispatched the operation to `localizableTable` correctly.
4. Finally, verify whether the model fields and WCDB conditions are correct.

## 5. Recommended Reading Order

For a first pass through the project, use this order:

1. `README.md`
   - Understand the project positioning and integration method.
2. `Doc/Structure.md`
   - Build a mental model of directories and modules.
3. `MMTToolForAppTrans/Classes/MMTToolForAppTrans.swift`
   - Confirm how lightweight the public entry currently is.
4. `MMTToolForAppTrans/Classes/DB/MMTToolForAppTransDBManager.swift`
   - Review database initialization and unified operation entry points.
5. `MMTToolForAppTrans/Classes/DB/MMTToolForAppTransLocalizableTable.swift`
   - Review the model, table structure, and CRUD details.
6. `Example/`
   - If you need to verify integration, then read the example project.

## 6. One-Sentence Conclusion

This repository is currently a WCDB-based localization record storage library, and the real business logic is mainly concentrated in `MMTToolForAppTrans/Classes/DB/`, while the other directories mostly serve demo, configuration, and dependency management purposes.