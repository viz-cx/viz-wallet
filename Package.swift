// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "viz-wallet",
    dependencies: [
        .package(url: "https://github.com/viz-blockchain/viz-swift-lib.git", .branch("master"))
    ]
)
