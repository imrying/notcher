// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NotchHelper",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        // This defines the library product your Rust code links to
        .library(
            name: "NotchHelper",
            type: .dynamic,  // Important: dynamic library (.dylib)
            targets: ["notcher"]
        )
    ],
    targets: [
        .target(
            name: "notcher",
            dependencies: [],
            path: "Sources/notcher",
            linkerSettings: [
                .unsafeFlags(["-L", "target/debug"]),
                .linkedLibrary("notcher_files")
            ]
        )
    ]
)
