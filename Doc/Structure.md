# MMTToolForAppTrans Structure Guide

## 1. Repository Layout

```text
MMTToolForAppTrans/
├── Doc/                                   Documentation directory
├── Example/                               CocoaPods example project
├── MMTToolForAppTrans/                    Pod source directory
│   └── Classes/
│       ├── MMTToolForAppTrans.swift       Public entry facade
│       ├── DB/                            Low-level WCDB implementation
│       ├── Import/                        External file import module
│       ├── Localization/                  Key -> value resolution module
│       ├── State/                         Runtime state and cache module
│       └── Storage/                       Storage access module
├── README.md                              Public-facing documentation
└── MMTToolForAppTrans.podspec             Pod release configuration
```

## 2. Current Architecture

The project is now organized around four runtime modules plus one public facade.

### Public Facade

File: `MMTToolForAppTrans/Classes/MMTToolForAppTrans.swift`

Responsibilities:

- Exposes the public API of the library.
- Forwards requests to Import, Storage, Localization, and State.
- Avoids exposing WCDB details to external callers.

### Import Module

File: `MMTToolForAppTrans/Classes/Import/MMTToolForAppTransImportModule.swift`

Responsibilities:

- Accepts external files.
- Validates supported file types.
- Treats `.mmttrans` as a renamed `.xlsx` container.
- Converts the external file into a unified internal import model.

Current scope:

- File existence checks
- File readability checks
- File type recognition for `.mmttrans`, `.xlsx`, and `.xml`
- Basic content validation for ZIP-based and XML-based inputs

### Storage Module

File: `MMTToolForAppTrans/Classes/Storage/MMTToolForAppTransStorageModule.swift`

Responsibilities:

- Initializes persistent storage.
- Wraps low-level database access.
- Queries localization records by key.

How it fits the architecture:

- The Storage module is the layer above the WCDB implementation.
- Localization and other modules should query data through Storage instead of talking to DB code directly.

### State Module

File: `MMTToolForAppTrans/Classes/State/MMTToolForAppTransState.swift`

Responsibilities:

- Stores runtime state shared across modules.
- Stores the current language.
- Stores the current imported file.
- Stores the in-memory localization cache.
- Stores the access-order seed used by the LRU cache.

Current state fields:

- `currentLanguage`
- `currentImportFile`
- `localizationValueMap`
- `accessOrderSeed`
- `isLanguageConfigured`

### Localization Module

File: `MMTToolForAppTrans/Classes/Localization/MMTToolForAppTransLocalizationModule.swift`

Responsibilities:

- Accepts a localization key.
- Resolves the final string value using the selected language.
- Uses an in-memory cache before falling back to storage.
- Applies language fallback rules when a direct value is not available.

## 3. Runtime Flow For Key -> Value

This is the current logic used when external code requests a localized value.

### Step 1: Receive key

External code calls one of these APIs:

- `localizedString(forKey:)`
- `localizedString(forKey:language:)`
- `MMTLocal(key:)`
- `MMTLocal(key:language:)`

### Step 2: Build the cache key

The Localization module builds a cache key using:

```text
newKey = key + "." + languageSuffix
```

Examples:

- `home.title.enUs`
- `home.title.zhHans`

### Step 3: Read from the in-memory cache

The module checks `localizationValueMap` in the State module.

If the cache entry exists:

- Return the cached value immediately.
- Refresh the cached entry `lastAccessOrder` to the newest access order.

### Step 4: Query storage on cache miss

If the cache entry does not exist:

- Query the Storage module by the original key.
- The Storage module reads the underlying WCDB record.

### Step 5: Resolve the final value

The Localization module resolves the final string in this order:

1. Value for the requested language
2. English value
3. First available value in the record

### Step 6: Write back into the cache

If a value is resolved successfully:

- Store `newKey -> (value, lastAccessOrder)` in the cache map.
- Assign a new access order from `accessOrderSeed`.
- Increase `accessOrderSeed` by 1.

### Step 7: Keep the cache size at 200

After inserting a new cache item:

- If the cache count is greater than 200,
- Remove the item with the smallest `lastAccessOrder`.

This keeps the cache size capped at 200 entries and makes the cache behave as a standard LRU strategy.

## 4. Recommended Reading Order

If you want to understand the current implementation quickly, use this order:

1. `MMTToolForAppTrans/Classes/MMTToolForAppTrans.swift`
  - See the public entry methods first.
2. `MMTToolForAppTrans/Classes/State/MMTToolForAppTransState.swift`
  - Understand runtime state and caching.
3. `MMTToolForAppTrans/Classes/Import/MMTToolForAppTransImportModule.swift`
  - Understand external file handling.
4. `MMTToolForAppTrans/Classes/Storage/MMTToolForAppTransStorageModule.swift`
  - Understand storage access.
5. `MMTToolForAppTrans/Classes/Localization/MMTToolForAppTransLocalizationModule.swift`
  - Understand final key -> value resolution.
6. `MMTToolForAppTrans/Classes/DB/`
  - Review the low-level WCDB implementation only after the higher-level modules are clear.

## 5. One-Sentence Conclusion

The project is now structured as a facade-driven localization library where Import handles external files, Storage wraps database access, State manages runtime attributes and cache, and Localization resolves keys into final values using the current or requested language.