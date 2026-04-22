# Version Record

This file tracks the documented version status of MMTToolForAppTrans.

## Current Version

### 0.6.0

Current status in the working tree:

- Uses a facade-based public API while keeping WCDB behind the storage layer.
- Supports bundle-first localization lookup with storage fallback.
- Supports runtime language switching through `MMTToolForAppTrans.Language`.
- Includes a 200-entry in-memory LRU cache for localized values.
- Exposes configurable valid language lists through the facade.
- Includes an Example app page for bundle registration and runtime language switching.

## Notes

- The current `MMTToolForAppTrans.podspec` version is `0.6.0`.
- Older version entries have not been backfilled in `Doc` yet.
- When `MMTToolForAppTrans.podspec` changes version, add a new section here and summarize the visible feature-level changes.