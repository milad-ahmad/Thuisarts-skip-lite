# Skip Lite Evaluation: Methodology & Steps Taken

This document summarizes the technical steps, investigations, and experiments performed to evaluate the **Skip Lite** architecture (Entirely Swift UI & Logic transpiled to Kotlin).

## 1. Project Structure & Environment Analysis
*   **Structure Investigation:** Discovered the multi-layered project hierarchy where the project appears multiple times (Root, App, and Skip-compiled resources).
*   **Dependency Discovery:** Investigated the "missing" `libs.versions.toml` and traced the SDK versions to a dynamically generated version catalog inside the `.build` output folder's `settings.gradle.kts`.
*   **AGP Analysis:** Verified the locked AGP version (8.13.2) and identified it as a potential bottleneck for adopting newer Android tooling.

## 2. Transpilation Fidelity Audit (Logic & UI)
*   **Source-to-Target Comparison:** Performed side-by-side reads of Swift source code (e.g., `MainViewModel.swift`, `PageView.swift`) and their transpiled Kotlin counterparts in the `.build` folder.
*   **Type Mapping Verification:** Validated how Swift Optionals, Enums with associated values (Sealed Classes), and `async/await` are represented in Kotlin.
*   **UI Architecture Trace:** Analyzed the class-based `View` structure in Kotlin and how it implements a "SwiftUI DSL" on top of Jetpack Compose using the `skip.ui` runtime.

## 3. State Management & Lifecycle Investigation
*   **ViewModel Discovery:** Identified that ViewModels are stored using `rememberSaveable` within the Composable tree rather than the standard Android `viewModel()` lifecycle.
*   **Value Semantics Experiment:** Traced the use of `scopy()` and `sref()` mechanisms in the transpiled code to understand how Skip preserves Swift's value semantics for structs in a reference-based JVM environment.
*   **Concurrency Audit:** Analyzed the `Concurrency.kt` runtime to confirm that Skip uses a cooperative cancellation model, which requires manual lifecycle management for asynchronous tasks.

## 4. Performance & Stability Testing
*   **Strict Mode Analysis:** Enabled `StrictMode.enableDefaults()` to monitor main-thread violations.
    *   *Finding:* Identified Disk I/O violations occurring during view attachment (`skip.ui.Preference` initialization) caused by reflection-based access to companion objects.
*   **Profiler Stress Test:** Attempted multiple System Traces and CPU Hotspot recordings using the Android Studio Profiler.
    *   *Finding:* The generated project complexity and "chattiness" caused the IDE to hang/crash, indicating significant overhead in the transpiled call stacks.
*   **Resource Parsing Trace:** Analyzed the custom `asset:/` protocol and runtime parsers for `.xcassets` and `.lproj` to evaluate the overhead of runtime resource loading vs. Android's native pre-compiled `res/` system.

## 5. Architectural Barrier & Interop Assessment
*   **Activity Hierarchy Check:** Investigated why `MainActivity` inherits from `AppCompatActivity` and confirmed it creates unnecessary legacy weight for a pure Compose project.
*   **Native Integration Logic:** Performed a mental walkthrough of adding a native Android feature (e.g., Camera API).
    *   *Finding:* Confirmed that the "Build Artifact" nature of the Kotlin code makes it extremely difficult to integrate standard Android libraries or share resources with native components.
*   **Preview Availability Audit:** Checked for the existence of generated Compose Previews.
    *   *Finding:* Confirmed that Previews are absent and technically difficult to implement due to runtime JNI dependencies in the Skip primitives.

## 6. Developer Quality of Life (QoL) Assessment
*   **Debugging Experience Test:** Used the Android Studio debugger to inspect transpiled ViewModels.
    *   *Finding:* Observed that fields are "opaque" and require explicit evaluation to see values, mirroring a JNI-bridging experience even though the code is technically Kotlin.
*   **Maintenance Persona Analysis:** Evaluated the project from the perspective of an Android engineer vs. a Swift engineer.
    *   *Finding:* Concluded that the Android developer is effectively "sidelined" in the Lite model, creating a technical silo that is difficult to navigate for standard Android maintenance.
