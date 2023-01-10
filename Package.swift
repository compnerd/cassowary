// swift-tools-version:5.3

import PackageDescription

let cassowary = Package(
  name: "cassowary",
  products: [
    .library(name: "cassowary", type: .dynamic, targets: ["Cassowary"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-collections.git",
             .upToNextMinor(from: "1.0.0")),
  ],
  targets: [
    .target(name: "Cassowary", dependencies: [
        .product(name: "OrderedCollections", package: "swift-collections")
    ]),
    .testTarget(name: "CassowaryTests", dependencies: ["Cassowary"]),
  ]
)
