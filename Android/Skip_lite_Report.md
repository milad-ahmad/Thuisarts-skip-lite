# Skip PoC Evaluation Report: Swift for Android (Skip Lite)

## Executive Summary
Skip is an **extraordinary feat of engineering** that allows developers to write an app in Swift/SwiftUI and have it transpiled into a functional Android app using Jetpack Compose. This version of the project (Skip Lite) treats the transpiled Kotlin code and its associated assets as a **build artifact**, intended to be used as-is rather than maintained manually. While this approach achieves remarkable parity, it creates a technical silo that Android engineers must navigate.

---

## 1. Code Cleanliness & Maintainability
- **The Artifact Mindset:** In the Skip Lite approach, the transpiled Kotlin code is a **build artifact**. Criticizing it for being "non-idiomatic" or "verbose" is less relevant if the intention is never to touch it. It is readable enough for debugging (which is a major plus), but it is not intended for manual maintenance.
- **UI Code:** Highly "synthetic." It uses a class-based `View` structure that mirrors SwiftUI. While unusual for Android, it is highly effective at maintaining UI fidelity across platforms.

## 2. Type & Naming Fidelity
- **Mapping:** Mapping of Swift Optionals, Enums with associated values (to Sealed Classes), and async/await is robust and reliable.
- **Naming Conventions:** Mostly preserved, but Swift property patterns (like `_` for internal state) are surfaced in Kotlin.

## 3. The "Uncanny Valley" of UI & Architecture
- **Compose Integration:**  It does not feel like natural Jetpack Compose. It is effectively a "SwiftUI DSL implemented in Kotlin."
- **State Patterns:** It uses `rememberSaveable` to store ViewModels in Composable, which is a departure from the compose lint rule for "make dependencies explicit". 
- **Layout**: Modifiers mirror SwiftUI chainable methods rather than Compose's Modifier object.
- **Activity Hierarchy:** `MainActivity` inherits from `AppCompatActivity`, which is technically valid (as it inherits from `ComponentActivity`) but adds unnecessary legacy weight for a pure Compose project.

## 4. Resource Management: Silo
Skip uses a custom mechanism to load Swift-style resources (`.lproj` and `.xcassets`) from the Android `assets` folder.
- With a "Logic & UI parity" goal, not a blocker. However, Skip provides a custom `asset:/` URL protocol and runtime parsers for JSON, SVG, and PropertyLists that make these resources work seamlessly within the Skip ecosystem.
- **Why was it flagged?**
    - **Optimization:** Standard Android resources are pre-compiled and optimized by `aapt2`. Skip's resources are parsed **at runtime**, which can be slower.
    - **Tooling Silo:** Standard Android translation tools, static analyzers, and IDE previews cannot "see" into Skip's `.lproj` or `.xcassets` files.
    - **Interoperability:** Sharing a string or image between a native Kotlin screen and a Skip screen requires manual "bridging" logic rather than a simple `R.string.name` reference.

## 5. Developer Experience & QoL
- **Initial Impression:** 9/10 (The "Magic" of seeing Swift run on Android).
- **Practical Android Engineering:** 6/10 (Reflecting the artifact mindset vs. maintenance overhead).
- **The "Moot" Preview Problem:** While standard Compose Previews fail due to JNI dependencies in the Skip runtime, this is largely irrelevant in the Lite model. Since the UI is written and maintained entirely in Swift, Android-side previews are unnecessary for the intended workflow.
- **Opaque Debugging:** Even though the logic is transpiled to Kotlin, the debugging experience remains "opaque." Fields are not directly visible in the IDE and must be explicitly evaluated to inspect their values, mirroring the experience of debugging JNI-bridged code.

## 6. Performance & Lifecycle Observations
- **Cooperative Cancellation (The "Zombie Task" Risk):** Skip Lite uses a cooperative cancellation model. Just like in native Swift, tasks only stop if the business logic explicitly checks `Task.isCancelled` or calls `Task.checkCancellation()`. Developers must be disciplined about this manual management.
- **Disk I/O Violations:** `StrictMode` reveals Disk I/O violations on the main thread during view attachment (`skip.ui.Preference` initialization) due to reflection-based companion object access.
- **Struct Mimicry:** The mechanism to preserve Swift's value semantics in Kotlin (`scopy`, `sref`) introduces some GC pressure.

---

## 7. Native Interop & The "Maintenance Tax"
While Skip Lite works wonders for self-contained UI and logic, it creates a steep barrier for native Android integration:
- **The Interop Blind Spot:** Implementing platform-specific features (e.g., using the Camera API, Bluetooth, or proprietary Android SDKs) requires bridging logic that is not documented clearly for the Lite model. 
- **The Developer Dilemma:** Most Android engineers would be "hard-pressed" to dive into this transpiled silo. There is little professional appeal in maintaining a project where idiomatic knowledge is replaced by a "black-box" build artifact.
- **Resource Lock-in:** Adding a standard Android dependency often requires standard `res/` values (like XML styles or drawables) which are siloed in Skip's `assets/` model, making common integration tasks feel like "fighting the framework."

## 8. Key Pros & Blockers

### Biggest Pros:
- **Impression Factor:** It is an **impressive tool** that successfully bridges Swift and Kotlin at a deep level.
- **SPM Integration:** The ability to leverage Swift packages directly on Android is a game-changer for Swift-centric teams.
- **Logic Fidelity:** Near-perfect translation of business rules and models.

### Main Blockers:
- **Non-Standard Resources:** Uses `.lproj` and `.xcassets` instead of standard Android resources.
- **Native Interop Complexity:** High friction for adding platform-specific features like Camera or local notifications.
- **Build Infrastructure:** Locked into specific AGP versions, making it hard to adopt new Android features until Skip updates.
- **Strict Mode Red Flags:** Main-thread Disk I/O is a concern for smooth UI performance.

---

## Final Thoughts
Skip Lite is a powerful bridge for teams that are "Swift-only" and want to treat Android as a secondary deployment target with zero Android-specific maintenance. By treating the output as a **transparent build artifact**, the tool achieves its goal of 1:1 logic and UI parity with minimal overhead for the iOS team. 

However, the "blockers" identified (like non-standard resources and interop complexity) represent a significant **architectural risk**. If a project eventually requires deep integration with the Android ecosystem, the "silo" becomes a liability. An Android developer tasked with solving a native bug or adding a platform feature would find themselves in a "hostile" environment where standard tools and patterns don't apply. In the Lite model, the Android developer is effectively replaced by the transpiler—a trade-off that is acceptable only as long as the project remains strictly within the bounds of what the transpiler can automate.
