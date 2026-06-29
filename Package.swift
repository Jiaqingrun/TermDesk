// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TermDesk",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "TermDesk", targets: ["TermDesk"]),
        .library(name: "TermDeskShared", targets: ["TermDeskShared"]),
    ],
    dependencies: [
        .package(path: "../syspeek"),
        .package(url: "https://github.com/migueldeicaza/SwiftTerm.git", from: "1.2.0"),
    ],
    targets: [
        .target(name: "TermDeskShared"),
        .executableTarget(
            name: "TermDesk",
            dependencies: [
                "TermDeskShared",
                .product(name: "SysPeekShared", package: "syspeek"),
                .product(name: "QRMetricsKit", package: "syspeek"),
                .product(name: "SwiftTerm", package: "SwiftTerm"),
            ],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("SwiftUI"),
                .linkedFramework("Carbon"),
            ]
        ),
    ]
)
