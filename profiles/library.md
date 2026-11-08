# library

A project adopts this profile when other packages depend on it.

## tool

| ID | Rule | Check |
| --- | --- | --- |
| LIB-1 | Every public declaration has a documentation comment that starts with a one-line summary and documents its parameters, its return value and what it throws. | [baseline/swift-format-library.json](../baseline/swift-format-library.json) as `Sources/.swift-format`, through the `format` step |
| LIB-3 | `Package.swift` states the minimum version of each platform the library supports, and the library builds for every one of them. | the `platforms` step |

## release

| ID | Rule | Check |
| --- | --- | --- |
| LIB-4 | A release's version follows semantic versioning for the public API, and the changelog lists each API change. | `swift package diagnose-api-breaking-changes <last tag>` |

## review

| ID | Rule |
| --- | --- |
| LIB-5 | The library keeps no global mutable state. |
| LIB-6 | Adding a case to a public enum breaks every dependant that switches on it, so it needs a major version. Model a set of values that may grow as a struct with static members. Keep an enum where the domain fixes its cases, such as a compass direction. |
| LIB-2 | The library reads no environment variable or `UserDefaults` key and writes to no standard stream. It takes values, writers and clocks from its caller. |

## Reasons

- LIB-3: A package builds only for the platform of the machine running
  `swift build`, so an iOS-only API in a library that also lists macOS
  fails for dependants and not in the library's own lane.
- LIB-6: Packages are built without library evolution, so their public
  enums are exhaustive and a dependant's `switch` has no `default` to fall
  back on.
