# Combine Extensions

## What is Combine Extensions?


## Requirements

- Xcode 13.2+
- Swift 5.5+

## Installation

The easiest way to install Gauntlet is by adding a dependency via SPM.

```swift
        .package(
            name: "CombineExtensions",
            url: "https://github.com/krogerco/combineextensions-ios.git",
            .upToNextMajor(from: Version(1, 0, 0))
        )
```

… then reference in your test target.

```swift
        .testTarget(
            name: "MyTests",
            dependencies: ["MyFramework", "CombineExtensions"],
            path: "MyFrameworkTests"
        )
```

## How to Use Combine Extensions

## Documentation

Gauntlet has full DocC documentation. After adding to your project, `Build Documentation` to add to your documentation viewer.

## Communication

If you have issues or suggestions, please open an issue on GitHub.
