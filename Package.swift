// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Membar",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Membar", targets: ["Membar"])
    ],
    targets: [
        .executableTarget(
            name: "Membar"
        )
    ],
    swiftLanguageVersions: [.v5]
)
