// swift-tools-version:5.3

import PackageDescription

let cassowary = Package(
  name: "cassowary",
  products: [
    .library(name: "cassowary", type: .dynamic, targets: ["Cassowary"]),
  ],
  targets: [
    .target(name: "Cassowary", dependencies: []),
    .testTarget(name: "CassowaryTests", dependencies: ["Cassowary"]),
  ]
)
