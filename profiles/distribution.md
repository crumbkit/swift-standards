# distribution

A project adopts this profile when it ships signed builds of an app to
people, through TestFlight, the App Store or a Developer ID download.

## drift

| ID | Rule | Check |
| --- | --- | --- |
| DIST-1 | CI builds every app unsigned, with `CODE_SIGNING_ALLOWED=NO`, and holds no signing identity, provisioning profile or App Store Connect key. The map's `signing` decision says where each channel's build is signed and by whom. | drift on the workflows |
| DIST-2 | The project spec generates each app's entitlements, and each entitlement has a comment that says which feature needs it. An app requests no entitlement it does not use. | drift |
| DIST-3 | Each app has a `PrivacyInfo.xcprivacy` that declares every required-reason API it calls, such as `UserDefaults` or file timestamps, and the data it collects. Every permission's usage description says in plain words what the app does with the access. | drift for the file, review for its content |
| DIST-4 | The bundle identifier, the team and the marketing version are set once, in the project spec. No developer edits them locally to build. | drift |

## release

| ID | Rule | Check |
| --- | --- | --- |
| DIST-5 | Each channel has one release script, such as `bin/testflight` or `bin/release-mac`. The script sets a build number higher than any uploaded before, archives the Release configuration, and exports it. A person never edits the build number by hand. | the release script |
| DIST-6 | A Mac app shipped outside the App Store is signed with a Developer ID, runs with the hardened runtime, is notarized with `xcrun notarytool submit --wait`, and has its ticket stapled. The release script refuses to finish unless `spctl --assess --type execute` accepts the app. | the release script |
| DIST-7 | A build for TestFlight or the App Store is exported with the `app-store-connect` method and uploaded by the export. | the release script's export options |

## review

| ID | Rule |
| --- | --- |
| DIST-8 | The owner runs every release script. An agent may build an app and run it in the Simulator, and never uploads a build, notarizes one, or installs one on the owner's devices. |
| DIST-9 | An app whose builds share a CloudKit container states the container's environment in the project spec, so a development build and a TestFlight build read the same records. A release that adds a record type or a field deploys the schema to Production first. |
| DIST-10 | The marketing version follows semantic versioning for what a person sees: a new feature raises the minor version, and a fix raises the patch version. The release's notes list every change a person can see. |

## Reasons

- DIST-1: A signing identity in CI can sign anything that reaches the
  workflow, including a pull request's code. Keeping it on the owner's
  machine limits that to the owner.
- DIST-5: App Store Connect refuses an upload whose build number is not
  higher than the last one for that version.
- DIST-6: Gatekeeper blocks a downloaded app that is not notarized, and a
  stapled ticket lets the app open without a network check.
- DIST-9: TestFlight and App Store builds always use the Production
  environment, so a development build left on the Development environment
  reads different records from the same container.
