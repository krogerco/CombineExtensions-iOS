# ``Subscriptions``

Extentions for subscribing to combine pipelines.

## Sinking to Function Reference on Object

Publisher/sink(to:on:ownership:)

```swift
class CartViewModel { 
    
    var subscriptions = Set<AnyCancellable>()

    init(eventPublisher: AnyPublisher<Event, Never>) { 
    
        eventPublisher
            .recieve(on: DispatchQueue.main)
            .sink(to: CartViewModel.handleEvent, on: self, ownership: .weak)
            .store(in: &subscriptions)

    }
    
    func handleEvent(event: Event) {
        switch event { 
            case .didLoad: //
            case .didTapButton: //
        }
    }
}

```
