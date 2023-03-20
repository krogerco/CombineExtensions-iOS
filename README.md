# Combine Extensions

## What is Combine Extensions?


## Requirements

- Xcode 13.2+
- Swift 5.7+

## Installation

The easiest way to install Gauntlet is by adding a dependency via SPM.

```swift
        .package(
            name: "CombineExtensions",
            url: "https://github.com/krogerco/combineextensions-ios.git",
            .upToNextMajor(from: Version(1, 0, 0))
        )
```

…then reference in your test target.

```swift
        .testTarget(
            name: "MyTests",
            dependencies: [
                .byName(name: "MyFramework")
                .product(name: "CombineExtensions", package: "CombineExtensions-iOS")
            ],
            path: "MyFrameworkTests"
        )
```

## How to Use Combine Extensions

### Sink to Function Reference 

Prevent retain cycles by sinking to a function reference on a weakly retained object.

```swift
// Good
publisher
    .sink(to: CartViewModel.handleEvent, on: self, ownership: .weak) // Safely captured!
    .store(in: &subscriptions)
    
// Bad
publisher
    .sink(receiveValue: self.handleEvent) // `self` captured in subscription, causing retain cycle.
    .store(in: &subscriptions)
```

### Weakly Assign

The default Combine `assign(to:on:)` function strongly retains the object. We have provided an overload to allow retaining that object weakly. 

```swift
publisher
    .assign(to: \.textfield.text, on: self, ownership: .weak)
    .store(in: &subscriptions)
```

### Subscribe to Multiple `Notification.Name`s

Use `NotificationCenter.publisher(for names:)` to subscribe to multiple notifications and funnel them into a single stream.

```swift
NotificationCenter.default.publisher(for: [Notification.Name.CartUpdate, Notification.Name.RefreshAll])
    .sink { notification in 
        // Notifications from either source are funneled into a single event.
        switch notification.name {
            case Notification.Name.CartUpdate: //
            case Notification.Name.RefreshAll: //
        }
    }
    .store(in: &subscriptions)
```

### `withLatestFrom` Operator

Merges two publishers into a single publisher by combining each value from `self` with the _latest_ value from the other publisher, if any.

```swift
let buttonTap = PassthroughSubject<Void, Never>()
let formData = CurrentValueSubject<FormData, Never>()

let publisher = buttonTap
    .withLatestFrom(formData)
    .sink { _, formData in 
        //
    }
}

buttonTap.send()
formData.send(formData.updated()) // Won't trigger publisher, waiting on buttonTap to send again.
formData.send(formData.updated())
formData.send(formData.updated())
buttonTap.send()
```


## Documentation

CombineExtensions has full DocC documentation. After adding to your project, `Build Documentation` to add to your documentation viewer.

## Communication

If you have issues or suggestions, please open an issue on GitHub.
