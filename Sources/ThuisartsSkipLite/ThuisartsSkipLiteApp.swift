import Foundation
import OSLog
import SwiftUI
/// A logger for the ThuisartsSkipLite module.
let logger: Logger = Logger(subsystem: "com.example.ThuisartsSkipLite", category: "ThuisartsSkipLite")

/// The shared top-level view for the app, loaded from the platform-specific App delegates below.
///
/// The default implementation merely loads the `ContentView` for the app and logs a message.
public struct ThuisartsSkipLiteRootView : View {
    public init() {
    }

    public var body: some View {
#if !SKIP
        // Dit ziet alleen iOS. Omdat MainView ook in !SKIP staat,
        // kan hij hem hier nu veilig vinden.
        MainView()
            .task {
                logger.info("Running on iOS")
            }
        #else
        // Dit ziet Android. Omdat we MainView hier niet aanroepen,
        // krijgt Skip geen error meer.
        Text("Android Native UI wordt geladen via Android Studio...")
            .task {
                logger.info("Skip logic loaded for Android")
            }
        #endif
    }
}

/// Global application delegate functions.
///
/// These functions can update a shared observable object to communicate app state changes to interested views.
public final class ThuisartsSkipLiteAppDelegate : Sendable {
    public static let shared = ThuisartsSkipLiteAppDelegate()

    private init() {
    }

    public func onInit() {
        logger.debug("onInit")
    }

    public func onLaunch() {
        logger.debug("onLaunch")
    }

    public func onResume() {
        logger.debug("onResume")
    }

    public func onPause() {
        logger.debug("onPause")
    }

    public func onStop() {
        logger.debug("onStop")
    }

    public func onDestroy() {
        logger.debug("onDestroy")
    }

    public func onLowMemory() {
        logger.debug("onLowMemory")
    }
}
