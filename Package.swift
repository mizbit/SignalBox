// swift-tools-version:4.0
import PackageDescription

var package = Package(
    name: "SignalBox",
    targets: [
        .target(name: "RaspberryPi"),
        .target(name: "OldDCC", dependencies: ["RaspberryPi"]),
        .target(name: "Prototype", dependencies: ["RaspberryPi", "OldDCC"]),
        .testTarget(name: "OldDCCTests", dependencies: ["RaspberryPi", "OldDCC"])
    ]
)

#if os(Linux)
package.dependencies.append(.package(url: "https://github.com/mdaxter/CBSD", from: "1.0.0"))
#endif
