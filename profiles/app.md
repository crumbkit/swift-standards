# app

A project adopts this profile when it builds a SwiftUI app for iPhone, iPad
or Mac.

## tool

| ID | Rule | Check |
| --- | --- | --- |
| APP-1 | Literal colours, font sizes and animations appear only in the token and motion owners (APP-10, APP-18). The owner check lists `Color(red:`, `Color(hue:`, `Color(white:`, `UIColor(`, `NSColor(`, `.system(size:`, `withAnimation` and `.animation(` under those owners. | the `owners` step (BASE-6) |

## drift

| ID | Rule | Check |
| --- | --- | --- |
| APP-2 | An app target holds only scenes, views, view models and the adapters that own the app's effects. Wording, ordering, filtering, formatting and every other decision a screen shows live in a package target that `swift test` covers (BASE-8). | drift |
| APP-3 | Every colour set in an asset catalog has an Any, a Dark and a High Contrast appearance. | drift on each colour set's `Contents.json` |
| APP-4 | Every screen has a `#Preview` for each state its signed-off design shows (APP-7), each in light and in dark appearance. | drift for the count, review for the states |

## test

| ID | Rule | Check |
| --- | --- | --- |
| APP-5 | Each pair of a text token and the background tokens it sits on meets WCAG 2.2 contrast: 4.5:1 for body text, and 3:1 for large text and for the edges of controls. The pair passes in light, dark and increased-contrast appearance. | a test that resolves each pair in each appearance and computes the ratio |
| APP-6 | A UI test opens every screen on fixtures (APP-21) and runs `performAccessibilityAudit()` in light and dark appearance, and again at the largest accessibility text size. A finding the project accepts is filtered in the test with a comment that states why. | the `ui-tests` step |

## review

| ID | Rule |
| --- | --- |
| APP-7 | Build no screen until the owner has signed off its design. The pull request that builds a screen links the signed-off design and shows screenshots in light and dark. |
| APP-8 | Use the system's components and semantics first: its controls, navigation containers, lists, sheets and alerts, semantic colours such as `.primary` and `.secondary`, materials, SF Symbols and text styles. These adapt to light and dark, Increase Contrast and Dynamic Type without code. Build a custom component only when the signed-off design needs one. |
| APP-9 | Name each design token by its role, such as `textPrimary`, `surfaceRaised` or `danger`. A name that describes an appearance, such as `blue500`, is wrong in the other theme. |
| APP-10 | Keep the app's own visual values in one token owner. Colours are asset-catalog colour sets (APP-3). Spacing, corner radii, line widths and durations are named constants. A view uses a token or a system semantic, and never branches on `colorScheme` to pick a colour. |
| APP-11 | Write each view model as an `@Observable` `final class` on the main actor. The view that creates it owns it with `@State`, passes it down as a plain property, and uses `@Bindable` where a child needs a binding. New code does not use `ObservableObject`, `@Published` or `@StateObject`. |
| APP-12 | A view reads state and lays it out. A sentence, a sort order or a date format that the view shows comes from a package target with tests (APP-2). |
| APP-13 | A view model takes its data source as a parameter, as a protocol or a value. A preview or a UI test passes a fixed source. No production type has an initializer or a branch that exists only for previews. |
| APP-14 | Start a screen's async work with `.task` or `.task(id:)`, so it stops when the screen goes away. A button's action calls a view-model method. The view model ignores a second request for the same action while the first is in flight, and the view disables the control while it waits. |
| APP-15 | Lay out by size class and the space available, never by device model or a fixed screen size. Every screen works at every window size the platform allows and in every orientation the app supports. |
| APP-16 | Text uses text styles, so it follows Dynamic Type. A custom size goes through `@ScaledMetric` or `Font.custom(_:size:relativeTo:)`. A layout that does not fit at an accessibility text size changes shape, for example with `ViewThatFits` or by stacking vertically when `dynamicTypeSize.isAccessibilitySize` is true. |
| APP-17 | Every control has a name that VoiceOver reads. An icon-only button is a `Label` with a title and `.labelStyle(.iconOnly)`. A decorative image is `Image(decorative:)`. A row that reads as one thing combines its children with `.accessibilityElement(children: .combine)`. |
| APP-18 | Animate through one motion owner. When Reduce Motion is on, the owner replaces movement, scaling and zooming with a cross-fade or no animation. When Reduce Transparency is on, a custom translucent surface becomes an opaque token. |
| APP-19 | Never show a state by colour alone. A colour comes with a word or a symbol, so the state reads in greyscale and with Differentiate Without Color on. |
| APP-20 | On iPhone and iPad every tappable target is at least 44 by 44 points. |
| APP-21 | Keep the fixtures that previews, screenshots and UI tests use in one file per app, built through the same initializers production uses. The app reads the launch arguments that open it on fixtures only under `#if DEBUG`, so a release build ignores them. |
| APP-22 | Word every error the user sees in one mapping per feature, which says what happened and what to do next. A screen never shows an unknown error's `localizedDescription` on its own. |
| APP-23 | A Mac app that starts another program does so through one owner (BASE-6), off the main actor. The owner reads standard output and standard error at the same time, gives the run a deadline (BASE-27), and stops the program when the deadline passes. |

## Reasons

- APP-1: A literal colour or size in a view looks right in the theme it was
  written in and wrong in the other, and nothing else catches it.
- APP-3 and APP-5: Light, dark and increased contrast are three themes. A
  colour set without a Dark or High Contrast appearance silently reuses its
  Any colour there.
- APP-6: The audit finds missing labels, clipped text and small hit regions
  that a person checking screenshots misses, and it runs on every change.
- APP-7: A screen built before its design is agreed is usually rebuilt.
- APP-8: System components already handle Dynamic Type, VoiceOver, Increase
  Contrast, keyboard focus and new platform styles. A custom component has
  to do each of these itself.
- APP-11: Observation tracks the properties a view reads, so a view redraws
  only when one of them changes. `ObservableObject` redraws on every
  `@Published` change.
- APP-13: A preview-only path in a production type drifts from the real
  path, so the preview shows something the app never does.
- APP-14: A second tap on a slow action otherwise sends the request twice.
- APP-18: Large movement on screen can make people with vestibular
  disorders feel ill, which is why the system offers Reduce Motion.
- APP-23: A program that fills one pipe while the parent waits on the other
  blocks forever.
