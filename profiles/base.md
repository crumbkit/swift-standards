# base

Every project follows these rules.

## lint

| ID | Rule | Check |
| --- | --- | --- |
| BASE-1 | Every target builds in the Swift 6 language mode with the settings in [baseline/swift-settings.swift](../baseline/swift-settings.swift), or for an Xcode target [baseline/app.xcconfig](../baseline/app.xcconfig). CI fails on any compiler warning. | `.swiftLanguageMode(.v6)` and `SWIFT_VERSION = 6.0`; `-warnings-as-errors` and `SWIFT_TREAT_WARNINGS_AS_ERRORS=YES` in CI |
| BASE-2 | Silence a compiler warning only with `@diagnose(<group>, as: ignored, reason: "...")` on the smallest declaration that needs it. No target-wide flag lowers or hides a warning. | the compiler for the attribute; review for its placement |
| BASE-3 | Every target enables strict memory safety. Write no `unsafe` code unless the map's `unsafe` decision names the module and its invariant. | `.strictMemorySafety()` |
| BASE-4 | A target that holds views, view models or other user-interface code defaults to main-actor isolation. A target of logic, parsing or storage stays nonisolated and exposes `Sendable` value types. The map's `isolation` decision lists which is which. | `.defaultIsolation(MainActor.self)` and `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` on the interface targets |

## tool

| ID | Rule | Check |
| --- | --- | --- |
| BASE-5 | Format and lint all Swift with the toolchain's swift-format and [baseline/swift-format.json](../baseline/swift-format.json). The baseline forbids force unwraps, `try!` and implicitly unwrapped optionals. A declaration or file that needs one carries `// swift-format-ignore: <Rule>` or `// swift-format-ignore-file: <Rule>`, and the next comment line states the reason. | `swift format lint --strict --recursive .` |
| BASE-7 | Commit `Package.resolved`. CI resolves packages only from it. | `--force-resolved-versions` for SwiftPM, `-onlyUsePackageVersionsFromResolvedFile` for xcodebuild |
| BASE-8 | Every unit test runs under `swift test` on macOS, without a simulator, signing or network. | the `tests` step |

## drift

| ID | Rule | Check |
| --- | --- | --- |
| BASE-9 | Lay the repository out as one Swift package at the root. Each module is `Sources/<Module>/` and its tests are `Tests/<Module>Tests/`. App code is `Apps/<platform>/`, with code that both platform apps share in `Apps/Shared/`. Scripts are `bin/<step>`. The Xcode project is generated from `project.yml` with XcodeGen, and git ignores the generated project. | drift |
| BASE-10 | A production `.swift` file has at most 1,000 lines, counting every line. A file over the limit is split by responsibility, or listed as an exception in the map with a correction. Files under `Tests/` have no limit. | drift |
| BASE-11 | Every dependency in `Package.swift` has a comment line above it that says why the project needs it and names its licence. | drift |
| BASE-12 | Pin every build input. `.xcode-version` names the exact Xcode version, and CI selects that Xcode. `Package.swift` names its `swift-tools-version`. CI installs each tool at a stated version and pins each GitHub Action to a commit. Dependabot opens a pull request each week that moves the Swift package and GitHub Actions pins. A person raises `.xcode-version` by hand, because Dependabot cannot. | drift for the files, review for the rest |
| BASE-13 | The pull-request lane runs the steps in [README.md](../README.md#pull-request-lane) within a time budget that the map's `lanes` decision states. A check that does not fit the budget, such as a full simulator matrix or long UI tests, runs in another lane that the decision also records. | drift for the decision, review for its content |

## test

| ID | Rule | Check |
| --- | --- | --- |
| BASE-14 | Keep a catalog of every setting the program reads: each `UserDefaults` key, launch argument, environment variable and custom `Info.plist` key, with its purpose, its accepted form, and what the program does when it is absent or invalid. | a test that the catalog matches the reads in the settings owner (BASE-6) |

## release

| ID | Rule | Check |
| --- | --- | --- |
| BASE-15 | Ship no dependency with a known security advisory. Dependabot security alerts are on for the repository, and every release script refuses to build while an alert is open. | the release script's alert query |

## review

| ID | Rule |
| --- | --- |
| BASE-6 | Give each effect one owning file or module. Effects include the clock, the file system, the network, `UserDefaults`, the keychain, biometrics, cloud storage, launching another program, and standard output. Other code takes a value, a protocol or a closure from the owner. The project lists, for each framework, type or call, the files that may use it, and a reviewer checks every other file against the list. A logic target never imports SwiftUI, UIKit or AppKit. |
| BASE-16 | Write the test first. A change starts with a test that fails for want of the behaviour, and a bug fix starts with a test that reproduces the bug. When no automated test can show the change, such as a layout change, the pull request says how it was checked, for example with screenshots in light and dark. |
| BASE-17 | Choose the simplest design that works. It keeps every existing feature and its fidelity, and has the fewest types, files and moving parts. Add code only when removing code cannot make the change. Add an abstraction only when it removes two copies or another rule needs it. |
| BASE-18 | Compose small types. Give each domain meaning one type with one validation rule, and build larger values from those types. Do not build one large record whose many optional fields only some callers fill; split it into the types each caller needs. Prefer a standard or framework type to a new one. |
| BASE-19 | Parse input into its type once, where it enters the program. The type's stored properties are `let` or `private(set)`, and every way to build it, including `Decodable`, goes through one checking initializer, `init(_:) throws` or `init?(_:)`. Every function inside the program takes the type, and the raw value appears only where the value leaves the program. |
| BASE-20 | A type admits only the states the code handles. Where `Bool` and optional properties can combine into a state the code cannot handle, or a `String` holds one of a few known values, use an enum with one case per state that carries that state's data. |
| BASE-21 | Make each outcome the domain expects, such as a refusal or an empty result, a case of the operation's outcome enum, carrying what explains it. Keep `throw` for technical failures outside the domain's outcomes, such as an unreachable service or a malformed file. Use typed throws, `throws(SomeError)`, when the caller handles every case of a closed error set inside the same package, and plain `throws` at framework boundaries. |
| BASE-22 | An error that wraps another stores it, and does not copy it into its message. Code either logs an error or throws it, never both. Discard an error with `try?` only where a comment says why `nil` is the right result. Call `fatalError` or `preconditionFailure` only for a broken invariant, with a message that states it, and never for bad input. |
| BASE-23 | Run work off the main actor in an `@concurrent` function. New code uses neither `Task.detached` nor `DispatchQueue`. A callback API is bridged once, in its owner (BASE-6), with `withCheckedThrowingContinuation`, which resumes exactly once on every path. |
| BASE-24 | Keep shared mutable state in an actor or a `Mutex`, or an `OSAllocatedUnfairLock` where `Mutex` is not available. `@unchecked Sendable`, `nonisolated(unsafe)` and `@preconcurrency import` each carry a comment that names what makes the use safe and what removes it. |
| BASE-25 | Start tasks through structure: `async let`, a task group, or SwiftUI's `.task`. An unstructured `Task {}` only starts work from a synchronous callback, such as a button's action, and its owner keeps it and cancels it when the work is no longer wanted. Every loop in a task checks for cancellation. |
| BASE-26 | Wait for an event the code can observe, and never sleep to let something happen. Poll only a source that has no event, such as a remote store that sends no notification, and say at the poll that the source has none. The poll sleeps through an injected `any Clock<Duration>` at an interval that is a named constant, so a test advances the clock instead of waiting. |
| BASE-27 | Give every read a size limit, every retry a count, and each operation one deadline that covers all its steps. Until `withDeadline` (SE-0526) ships, the project keeps one deadline helper, and its comment says what the helper misses and that `withDeadline` replaces it. |
| BASE-28 | Keep secrets in the keychain, through its owner (BASE-6), and create private keys in the Secure Enclave where the device has one. A secret never goes in `UserDefaults`, a plain file, source code, a log, `Info.plist` or a command-line argument. A type that holds a secret prints a placeholder from `description`, `debugDescription` and its mirror. The map's BASE-28 binding lists the files that read a secret's value. |
| BASE-29 | Log through `os.Logger` with a subsystem and a category. Interpolated values stay private, the logger's default, unless the value is known to hold nothing personal. Shipped code never calls `print`. |
| BASE-30 | Write unit and integration tests with Swift Testing. Use XCTest only for UI automation and performance tests. An XCTest unit test file moves to Swift Testing in the change that next edits it. |
| BASE-31 | Name each test with a sentence that states the behaviour it checks, written as a snake_case function name, such as `a_refusal_names_the_rule_it_broke`. |
| BASE-32 | A test that involves time injects the clock, the calendar, the time zone and the locale. It never compares elapsed time with an upper bound. A `.timeLimit` trait only stops a test that hangs, and no assertion depends on it. |
| BASE-33 | A test owns everything it touches: a temporary directory, an in-memory store, a key it made. It never reads or writes the user's real keychain items, defaults domain, cloud container or the network. A test that drives a local tool, such as a command-line program, runs only where the `lanes` decision says the tool is installed. |
| BASE-34 | When another implementation must produce or accept the same bytes, such as a signature, a hash or a wire format, both test against one shared set of vectors, and a change to a vector lands in both. |
| BASE-35 | Prefer the standard library and Apple's frameworks to a dependency. A pull request that adds a dependency names what it does that the frameworks cannot, its licence, its maintainers and the cost of removing it. Allowed licences are MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause, ISC and Zlib. A macro package or build plugin runs code at build time, so it needs the same case as any other dependency. |
| BASE-36 | Keep visibility no wider than its use. An app target declares nothing `public`. Delete dead code. |
| BASE-37 | Follow the Swift API Design Guidelines. Spell names out, and use an abbreviation only when it is common outside the project, such as `id`, `url` or `http`. |
| BASE-38 | A comment states an invariant, a limit or a reason, and never history. A deliberate shortcut carries a comment that says what it misses and what replaces it. |
| BASE-39 | Every plan includes a module diagram. The diagram shows each module that the change adds or touches, marks which are new, and draws the dependencies between them, including dependencies the change adds or removes. It is written in a text format that renders where the plan is read, such as a Mermaid block in the pull request. |
| BASE-40 | Documents describe current behaviour, and each fact has one home. Plans and logs go in the pull request. `AGENTS.md` names the commands to run before every push. |
| BASE-41 | A new CI check names the failure it catches, why existing checks miss it, its lane and its cost. Prefer a type or compiler check to a text scan. |
| BASE-42 | Use a standard format or a maintained tool before writing a new one. |
| BASE-43 | Convert a typed value to another type through an initializer, a `switch` or the target's checking initializer, never by formatting it as text and parsing the text back. A numeric conversion that can lose information uses `init(exactly:)` and handles `nil`, or states how it rounds. |

## Reasons

- BASE-1: The Swift 6 language mode turns data-race findings into errors.
  The baseline's upcoming features change what code means, so they are on
  from the first commit, when turning them on costs least. CI
  alone turns warnings into errors, so a deprecation that a new Xcode adds
  does not stop local work, and it still cannot merge.
- BASE-2: A target-wide flag hides every future instance of the warning,
  and `@diagnose` keeps the exemption beside the code with its reason.
- BASE-4: Most data-race errors in app code come from view models and other
  UI state touched from several isolation domains. Defaulting those targets
  to the main actor removes the errors, and keeping logic targets
  nonisolated keeps them usable from any actor and quick to test.
- BASE-5: swift-format ships with the toolchain, so the formatter's version
  moves with `.xcode-version` and needs no separate install or pin.
- BASE-6: An effect reached from anywhere cannot be replaced in a test, and
  a review cannot find every place that touches it. A list of owners tells
  a reviewer which files may call it.
- BASE-9: A generated Xcode project leaves no `project.pbxproj` merge
  conflicts, and every target setting can be reviewed as text.
- BASE-12: An unpinned Xcode or tool changes the build when a new version
  ships, and a pull request then fails for a change it did not make.
- BASE-15: An advisory can be published after a dependency is resolved, so
  a check on pull requests alone misses advisories against code already on
  main.
- BASE-17 and BASE-39: Agents and people both tend to add layers. A module
  diagram shows a new layer, a new dependency or a cycle before any code is
  read.
- BASE-18 to BASE-21 follow Yaron Minsky's principle "make illegal states
  unrepresentable" ("Effective ML Revisited", 2011). The compiler checks
  that a `switch` on an enum handles every case, and nothing checks a
  combination of optional properties.
- BASE-23: `Task.detached` drops the caller's priority and task-local
  values, and work on a `DispatchQueue` is invisible to the concurrency checker.
  `@concurrent` states the intent and keeps both.
- BASE-26: A sleep that waits for something to happen is either too long,
  which makes the program slow, or too short, which makes it flaky.
- BASE-28: A secret in a log or a crash report's mirror output leaves the
  device with the report.
- BASE-30: Swift Testing runs tests in parallel by default, gives
  parameterised tests and `#require`, and prints the values in a failed
  expectation. Swift Testing has no API for UI automation or performance
  metrics.
- BASE-32: A test that compares elapsed time with an upper bound fails under
  load.
- BASE-43: The compiler cannot see a value written as text and parsed back,
  so a change to either type fails at run time where a direct conversion
  would fail to compile.
