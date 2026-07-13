// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HealthAtlas",
    platforms: [.macOS("26.0")],
    products: [
        .executable(name: "HealthAtlasApp", targets: ["HealthAtlasApp"])
    ],
    targets: [
        .executableTarget(
            name: "HealthAtlasApp",
            path: "Sources/HealthAtlasApp",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "HealthAtlasTests",
            dependencies: ["HealthAtlasApp"],
            path: "Tests/HealthAtlasTests"
        )
    ]
)
