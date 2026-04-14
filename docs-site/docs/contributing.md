---
sidebar_position: 6
title: Contributing
---

# Contributing

## Development setup

```bash
# Clone the repo
git clone https://github.com/Creative-Blaq-Studios/zegoweb.git
cd zegoweb

# Install Melos
dart pub global activate melos

# Bootstrap all packages
melos bootstrap
```

## Running checks

```bash
# Static analysis
melos run analyze

# Unit tests (Dart VM)
melos run test

# Unit tests (Chrome, for JS interop tests)
melos run test-chrome

# Format code
melos run format

# Check formatting without writing
melos run format-check
```

## Project structure

```
zegoweb/
├── packages/
│   ├── zegoweb/             # Core RTC wrapper
│   ├── zegoweb_prebuilt/    # UIKit wrapper
│   └── zegoweb_ui/          # Flutter-native UI
├── docs-site/               # This documentation site
├── melos.yaml               # Workspace configuration
└── pubspec.yaml              # Workspace root
```

## Package dependency rules

- `zegoweb_ui` may depend on `zegoweb`
- `zegoweb_prebuilt` is standalone
- `zegoweb` must not depend on either UI package
- All packages are web-only

## Code style

- Run `melos run format` before committing
- Run `melos run analyze` and fix all warnings
- Use absolute imports (`package:zegoweb/...`), never relative imports
