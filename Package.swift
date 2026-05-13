// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TallyBar",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "TallyBar", targets: ["TallyBar"])
    ],
    targets: [
        .executableTarget(
            name: "TallyBar",
            path: "Sources/TallyBar"
        )
    ]
)
