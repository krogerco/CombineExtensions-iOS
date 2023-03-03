# Subscritions

Extentions for subscribing to combine pipelines.

## Sinking to a Function Reference on an Object

The `sink(to:on:ownership)` Publisher extensions take a function _reference_, which is similar to a `KeyPath` but instead of infering it off the object type, the type and function must be explicitly defined. For example, in the code below, we pass a reference to the `CartViewModel.handleEvent` function defintion and an instance to call it on, in this case self which is a `CartViewModel`. 

The `ownership` parameter sets the retain strategy for the object. The most common use case for this is to use `.weak` when you're calling functions on the same object that is storing the subscription, which prevents retain cycles and memory leaks.

The function reference passed can have up to one parameter, to which the upstream output in passed.

```swift
class CartViewModel { 
    
    var subscriptions = Set<AnyCancellable>()

    init(eventPublisher: AnyPublisher<Event, Never>) { 
    
        eventPublisher
            .receive(on: DispatchQueue.main)
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
