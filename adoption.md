# Adoption map

A project that adopts these standards keeps `swift-standards.toml` at its
root. The map says which profiles the project adopts, where it meets the
rules that need a local owner, which choices it made where a rule leaves one
open, and where it breaks a rule.
[examples/tallykeeper.toml](examples/tallykeeper.toml) is a worked example.

## Tables

| Table | Holds | Required |
| --- | --- | --- |
| `schema` | `"swift-standards/adoption/v1"` | yes |
| `standards` | `version`, and the `commit` of this repository that the map was last reviewed against | yes |
| `profiles` | the adopted profiles, always including `"base"` | yes |
| `[[binding]]` | `rule`, `owners` (files), `checks`, `note`: where the project meets a rule | for BASE-6 and BASE-28; optional for any other rule |
| `[[decision]]` | a choice that a rule leaves to the project | see below |
| `[[exception]]` | `rule`, `paths`, `items`, `owner`, `reason`, `correction` | for each place that breaks a rule |

## Decisions

A decision has four fields, and none may be empty:

- `id`: one of the names in the table below, or a name the project chooses
  for a rule it sets itself.
- `requirement`: what the project does.
- `reason`: why it does that, and, for a check that nothing waits for, the
  failure the check catches and why finding it after merge is safe.
- `realizations`: the files that carry the decision out. Each path exists.

| Decision | Required when | `requirement` states |
| --- | --- | --- |
| `lanes` | always (BASE-13) | each lane: what runs, its trigger, its runner image, what waits for it, and the pull-request lane's time budget |
| `unsafe` | the project writes `unsafe` code (BASE-3) | the modules that use it and the invariant each one upholds |
| `isolation` | always (BASE-4) | which targets default to the main actor and which stay nonisolated |
| `signing` | the project adopts `distribution` (DIST-1) | where each channel's build is signed, by whom, and with which kind of identity |

- A merge waits for a check only when branch protection requires it. The
  `lanes` decision names the required checks, and a reviewer compares them
  with branch protection, because the repository's files do not show it.
- A project may record any stricter rule it sets for itself, such as a lower
  file length limit, as a decision.

## Exceptions

- An exception covers one rule at the listed `paths` (files, or directories
  ending in `/`) or `items` (baseline entries such as
  `swift-format:NeverForceUnwrap` or `setting:strictMemorySafety`).
- An exception lists at least one path or item.
- `owner` names the person who removes the exception. `reason` says why the
  rule is broken. `correction` says what removes the exception.
- An exception whose paths no longer exist, or that covers nothing, is
  deleted in the change that makes it stale.
- A warning silenced at the code with `@diagnose(..., reason: "...")`, or a
  swift-format rule skipped with an ignore comment and its reason (BASE-5),
  needs no exception. The reason at the code is the record (BASE-2).
