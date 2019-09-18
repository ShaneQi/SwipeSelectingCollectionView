// swift-tools-version:5.0

import PackageDescription

let package = Package(
	name: "SwipeSelectingCollectionView",
	products: [
		.library(
			name: "SwipeSelectingCollectionView",
			targets: ["SwipeSelectingCollectionView"])
	],
	dependencies: [],
	targets: [
		.target(
			name: "SwipeSelectingCollectionView",
			dependencies: [],
			path: "./Sources")
		],
	swiftLanguageVersions: [.v5]
)
