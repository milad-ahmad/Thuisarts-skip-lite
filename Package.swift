// swift-tools-version: 6.1
// This is a Skip (https://skip.dev) package.
import PackageDescription

let package = Package(
    name: "thuisarts-skip-lite",
    defaultLocalization: "en",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "ThuisartsSkipLite", type: .dynamic, targets: ["ThuisartsSkipLite"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "1.7.4"),
        .package(url: "https://source.skip.tools/skip-ui.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "ThuisartsSkipLite", dependencies: [
            .product(name: "SkipUI", package: "skip-ui")
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
        .testTarget(name: "ThuisartsSkipLiteTests", dependencies: [
            "ThuisartsSkipLite",
            .product(name: "SkipTest", package: "skip")
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)
