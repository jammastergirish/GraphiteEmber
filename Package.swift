// swift-tools-version: 6.2
import PackageDescription

// The "Graphite & Ember" look shared by One Tap Transcribe and Intercept:
// colours, fonts, small components, the table card, the app-icon squircle,
// and date/length formatting.
let package = Package(
    name: "GraphiteEmber",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .library(name: "GraphiteEmber", targets: ["GraphiteEmber"])
    ],
    targets: [
        .target(
            name: "GraphiteEmber",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .testTarget(
            name: "GraphiteEmberTests",
            dependencies: ["GraphiteEmber"],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
