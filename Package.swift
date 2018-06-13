// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "SignalBox",
    products: [
        .library(name: "Util", targets: ["RaspberryPi"]),
        .library(name: "RaspberryPi", targets: ["RaspberryPi"]),
        .library(name: "DCC", targets: ["DCC"]),
        ],
    targets: [
        .target(name: "Util"),
        .testTarget(name: "UtilTests", dependencies: ["Util"]),

        .target(name: "RaspberryPi", dependencies: ["Util"]),
        .testTarget(name: "RaspberryPiTests", dependencies: ["RaspberryPi"]),

        .target(name: "DCC", dependencies: ["Util"]),
        .testTarget(name: "DCCTests", dependencies: ["DCC"]),

        .target(name: "OldDCC", dependencies: ["Util", "RaspberryPi"]),
        .target(name: "OldPrototype", dependencies: ["OldDCC"]),
        ]
)
