import Foundation

// Retain strategy for objects in subscription operators
public enum ObjectOwnership {

    /// Strongly retains the object in the subscription
    case strong

    /// Weakly retains the object in the subscription.
    case weak
}
