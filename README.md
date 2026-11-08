# swift-standards

These are the rules that Luke Randall's Swift apps and packages follow. They
cover apps for iPhone, iPad and Mac built with SwiftUI, and the Swift
packages those apps are made of. They are opinionated on purpose. Each rule
says what to do, gives a reason when the reason is not obvious, and names the
cheapest check that enforces it.

The rules are a draft. Nothing here is versioned or tagged yet.

[rust-standards](https://github.com/crumbkit/rust-standards) is the
companion set for Rust projects. The rules that apply to any language, such
as test-first, the simplest design that works and a module diagram in every
plan, say the same thing in both.

## Index

```text
README.md                        profiles, lanes, check tiers, toolchain, versions
AGENTS.md                        rules for editing this repository
adoption.md                      the swift-standards.toml format
profiles/
├── base.md                      BASE-*  every project
├── app.md                       APP-*   SwiftUI apps for iPhone, iPad or Mac
├── distribution.md              DIST-*  apps that ship signed builds to people
└── library.md                   LIB-*   packages that other packages depend on
baseline/
├── swift-settings.swift         the Swift settings every package target uses
├── app.xcconfig                 the build settings every Xcode target uses
├── swift-format.json            .swift-format for every project
└── swift-format-library.json    .swift-format for the sources of a library
templates/
├── ci.yml                       a GitHub Actions workflow that runs the lanes below
├── dependabot.yml               weekly updates of every pin Dependabot can move (BASE-12)
├── project.yml                  an XcodeGen spec for an iPhone and Mac app (BASE-9)
└── xcode-version                the exact Xcode pin, copied to .xcode-version (BASE-12)
examples/
└── tallykeeper.toml             a worked adoption map for a small iPhone and Mac app
```

## Profiles

- A project adopts `base` and every other profile that describes it.
- A project ignores the rules of a profile it does not adopt.
- A project may use a baseline file from a profile it does not adopt, such
  as `swift-format-library.json`. Using the file adopts none of that
  profile's rules.

## Pull-request lane

Every project runs these steps on each pull request (BASE-13). CI and the
project's `bin/` scripts use the same step names, so a failure reads the same
in both places. `bin/lint` runs `format` and `build`, and
`bin/test` runs `tests`, so a person or an agent runs the lane before a push
with two commands.

Within one job the steps run cheapest first, so a pull request fails as early
as it can. `format` and `workflows` read only the source and run
before anything resolves or builds. A project may split the steps across
parallel jobs instead.

| Step | Command | Runs when |
| --- | --- | --- |
| `format` | `swift format lint --strict --recursive .` | always |
| `workflows` | `zizmor .` | the project has `.github/workflows/` |
| `build` | `swift build --force-resolved-versions --build-tests -Xswiftc -warnings-as-errors` | always |
| `tests` | `swift test --force-resolved-versions --skip-build` | always |
| `apps` | `xcodebuild build` for each app scheme, with `-onlyUsePackageVersionsFromResolvedFile`, `CODE_SIGNING_ALLOWED=NO` and `SWIFT_TREAT_WARNINGS_AS_ERRORS=YES` | the project adopts `app` |
| `ui-tests` | `xcodebuild test` of the UI test scheme on a simulator | the project adopts `app` (APP-6); the `lanes` decision may move it to another lane |
| `platforms` | `xcodebuild build` of each library scheme for each platform in `Package.swift` | the project adopts `library` (LIB-3) |

[templates/ci.yml](templates/ci.yml) runs these steps in this order.

## Scheduled and release checks

These checks run outside the pull-request lane, because their result can
change while the project does not.

| Check | Command | Runs |
| --- | --- | --- |
| `advisories` | Dependabot security alerts on the repository; the release script refuses to build while one is open | when GitHub publishes an advisory, and in the release script (BASE-15) |
| `notarize` | `xcrun notarytool submit --wait`, `xcrun stapler staple`, `spctl --assess` | in the release script of a Mac app shipped outside the App Store (DIST-6) |
| `api` | `swift package diagnose-api-breaking-changes <last tag>` | in the release lane of a library (LIB-4) |

## Check tiers

Every rule names its check. The tiers run from cheapest to most expensive.

| Tier | Where it runs | Cost |
| --- | --- | --- |
| `lint` | the Swift compiler, in every build | nothing beyond the build |
| `tool` | one command in the pull-request lane | seconds |
| `drift` | a comparison of the project's files with the baseline | seconds |
| `test` | a test that the project writes | the test's runtime |
| `release` | the release script or lane | minutes |
| `review` | a reviewer reading the change | the reviewer's time |

- A rule uses the cheapest tier that can check it.
- A `review` rule moves to a cheaper tier as soon as a tool can check it.
- No drift check ships with these standards yet. Until one does, a reviewer
  checks each `drift` rule against the project's files. The rules are written
  so that a script can check them, and the first project that needs one
  writes it here.
- BASE-6, APP-1 and LIB-2 are `review` rules because no owner check exists.
  They move to `tool` when one ships here.

## Toolchain facts

These facts were checked against primary sources on 2026-10-30. A rule that
depends on one cites it.

- Swift 6.4 is the current release (swift.org, 15 September 2026). The Swift
  6 language mode makes data-race checking complete and its findings errors.
- Swift 6.2 added per-target default isolation, `.defaultIsolation(MainActor.self)`
  in a package and `SWIFT_DEFAULT_ACTOR_ISOLATION` in Xcode (SE-0466), and
  `@concurrent` with the `NonisolatedNonsendingByDefault` upcoming feature
  (SE-0461). Xcode's `SWIFT_APPROACHABLE_CONCURRENCY` setting turns on that
  feature set.
- Swift 6.2 added `treatAllWarnings(as:)` and `treatWarning(_:as:)` to
  package manifests (SE-0480). Swift 6.4 added `@diagnose(group, as:
  ignored, reason:)`, which changes one warning group's level inside one
  declaration (SE-0522).
- `withDeadline`, an absolute time limit for an async operation (SE-0526), is
  accepted but not in Swift 6.4. BASE-27 marks the gap.
- Swift 6 toolchains include swift-format, run as `swift format`. A
  `.swift-format` file applies to the files in its directory and below.
  `// swift-format-ignore: Rule` skips one rule for the next declaration or
  statement, and `// swift-format-ignore-file: Rule` skips it for the file.
- Swift Testing and XCTest run side by side in one `swift test` run. Since
  Swift 6.4, `#expect` works inside XCTest and `XCTAssert` inside Swift
  Testing (ST-0021). Swift Testing has no UI automation or performance
  metrics API, so those tests stay on XCTest.
- Swift 6.4 builds packages with Swift Build by default.
- `XCUIApplication.performAccessibilityAudit()` audits the screen on display
  for contrast, Dynamic Type, hit regions, clipped text and missing
  descriptions (Xcode 15 and later).

## Versions

- A rule ID never changes meaning. A withdrawn rule keeps its ID and is
  marked withdrawn.
- A project names the version it follows in `swift-standards.toml`
  ([adoption.md](adoption.md)). Nothing upgrades a project automatically.
- Each version will be a tag `v<version>` on main once the first version is
  released.

## Licence

These standards are available under either the [MIT licence](LICENSE-MIT)
or the [Apache License, Version 2.0](LICENSE-APACHE), at your option.
