// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BlocsWavePro",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "BlocsWaveProCore",
            targets: ["BlocsWaveProCore"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BlocsWaveProCore",
            path: "BlocsWavePro",
            exclude: [
                "App",
                "Resources"
            ]
        )
    ]
)
