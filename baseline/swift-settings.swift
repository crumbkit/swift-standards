// The Swift settings every package target uses (BASE-1, BASE-3, BASE-4).
// Copy these two constants into Package.swift, which needs
// swift-tools-version 6.2 or later, and pass one of them as each target's
// `swiftSettings`.

// Logic, parsing and storage targets, and every test target.
let baseSettings: [SwiftSetting] = [
  .swiftLanguageMode(.v6),
  // An async function runs on its caller's actor unless it is marked
  // @concurrent (SE-0461).
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  // A main-actor type's conformances are main-actor too (SE-0470).
  .enableUpcomingFeature("InferIsolatedConformances"),
  // Every existential type is spelled `any P` (SE-0335).
  .enableUpcomingFeature("ExistentialAny"),
  // A member is visible only in files that import its module (SE-0444).
  .enableUpcomingFeature("MemberImportVisibility"),
  // Every unsafe construct is marked `unsafe` (SE-0458).
  .strictMemorySafety(),
]

// Targets that hold views, view models or other user-interface code (BASE-4).
let interfaceSettings: [SwiftSetting] =
  baseSettings + [
    .defaultIsolation(MainActor.self)
  ]
