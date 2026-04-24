# Version Record

This file tracks the documented release history of MMTToolForAppTrans.

Entries are append-only. Add a new version section at the top when the podspec version changes, and keep older sections unchanged.

### 0.6.5

- Normalized localization keys by stripping U+200B before bundle lookup, cache lookup, and storage fallback so hidden zero-width spaces no longer break matches.
- Added Example bundle fixtures with U+200B-containing keys to help debug and verify hidden-character handling.
- Updated the database record viewer to display empty localized values as empty text instead of `-1`.

### 0.6.4

- Added database synchronization from the active localization bundle into WCDB so the Example tool flow can inspect actual records.
- Added a library-provided Tools module and database viewer page that Example can present directly through the public facade.
- Added paged database browsing with key and multi-language value search in the database viewer.

### 0.6.3

- Changed localization lookup to return the English value when the selected language is outside the configured valid language list.
- Added an Example page workflow for toggling languages in the valid list while testing runtime fallback behavior.

### 0.6.2

- Updated localization fallback behavior to return the original key only after both bundle and storage lookup paths fail.
- Synced README, structure notes, podspec, and example lockfile with the 0.6.2 release.

### 0.6.1

- Synced the 0.6.1 podspec release record and example lock file.

### 0.6.0

- Introduced the facade-based public API while keeping WCDB behind the storage layer.
- Added bundle-first localization lookup with storage fallback.
- Added runtime language switching through `MMTToolForAppTrans.Language`.
- Added a 200-entry in-memory LRU cache for localized values.
- Exposed configurable valid language lists through the facade.
- Added an Example app page for bundle registration and runtime language switching.

## Notes

- The current `MMTToolForAppTrans.podspec` version is `0.6.5`.
- When `MMTToolForAppTrans.podspec` changes version, add a new section above `0.6.5` and summarize only that version's visible changes.
