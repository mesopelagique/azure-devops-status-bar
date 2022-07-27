// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "azure-devops-status-bar",
    platforms: [.macOS(.v12)],
    products: [
        .executable(
            name: "azure-devops-status-bar",
            targets: ["Executable"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.3.0"),
        .package(url: "https://github.com/phimage/Appify.git", from: "0.0.1"),
        .package(url: "https://github.com/phimage/Prephirences.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "Executable",
            dependencies: ["App", "QuatreD", "Appify"],
            resources: [
                .process("azure-devops.png")
            ]
        ),
        .target(
            name: "App",
            dependencies: [
                "StatusBar",
                "QuatreD",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                )
            ]
        ),
        .target(
            name: "StatusBar",
            dependencies: [
                "QuatreD",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                )
            ]
        ),
        .target(
            name: "QuatreD",
            dependencies: [
                "Prephirences",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                )
            ]
        )
    ]
)
