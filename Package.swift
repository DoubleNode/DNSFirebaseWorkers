// swift-tools-version:5.7
//
//  Package.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSFirebaseWorkers
//
//  Created by Darren Ehlers.
//  Copyright © 2022 - 2016 DoubleNode.com. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "DNSFirebaseWorkers",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "DNSFirebaseWorkers",
            type: .static,
            targets: ["DNSFirebaseWorkers"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/DoubleNodeOpen/AtomicSwift.git", from: "1.2.2"),
        .package(url: "https://github.com/DoubleNode/DNSBlankWorkers.git", from: "1.9.76"),
        .package(url: "https://github.com/DoubleNode/DNSCore.git", from: "1.9.47"),
        .package(url: "https://github.com/DoubleNode/DNSCoreThreading.git", from: "1.9.0"),
        .package(url: "https://github.com/DoubleNode/DNSCrashWorkers.git", from: "1.9.59"),
        .package(url: "https://github.com/DoubleNode/DNSDataObjects.git", from: "1.9.49"),
        .package(url: "https://github.com/DoubleNode/DNSError.git", from: "1.9.2"),
        .package(url: "https://github.com/DoubleNode/DNSProtocols.git", from: "1.9.104"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "9.6.0"),
        .package(url: "https://github.com/dgrzeszczak/KeyedCodable.git", from: "3.1.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "DNSFirebaseWorkers",
            dependencies: [
                "AtomicSwift", "DNSBlankWorkers", "DNSCore", "DNSCoreThreading", "DNSCrashWorkers",
                "DNSDataObjects", "DNSError", "DNSProtocols", "KeyedCodable",
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
            ]),
        .testTarget(
            name: "DNSFirebaseWorkersTests",
            dependencies: ["DNSFirebaseWorkers"]),
    ],
    swiftLanguageVersions: [.v5]
)
