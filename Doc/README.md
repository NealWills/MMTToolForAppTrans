# Doc

This directory provides a quick explanation of the internal structure of MMTToolForAppTrans.

If you are reading this repository for the first time, use the following order:

1. Start with `Structure.md` to build a quick understanding of the overall layout.
2. Then return to `MMTToolForAppTrans/Classes` and read the source code by module.
3. If you need the integration view, go back to the root `README.md` and the `Example/` project.

## What You Can Find Here

- Repository layers: which directories belong to source code, demo code, dependencies, and project configuration.
- Core modules: how Import, Storage, State, Localization, and the public facade are split.
- Data flow: how a localization bundle is registered and how keys become localized values.
- Runtime behavior: where comments explain bundle registration, import validation, cache hits, and storage fallback.
- Reading entry points: where a new reader should start and what to read next.

## Document List

- `Structure.md`: project structure overview, core module responsibilities, and recommended reading order.
- `Version.md`: documented version record for the current podspec version and future version updates.