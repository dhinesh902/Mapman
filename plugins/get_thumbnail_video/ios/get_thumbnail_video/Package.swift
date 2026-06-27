// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "get_thumbnail_video",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "get-thumbnail-video", targets: ["get_thumbnail_video"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "get_thumbnail_video",
            dependencies: [],
            path: "..",
            exclude: ["get_thumbnail_video.podspec"],
            sources: ["Classes"]
        )
    ]
)
