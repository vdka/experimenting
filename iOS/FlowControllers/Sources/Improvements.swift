
public struct Improvements<Base> {
    /// Base object to extend.
    public let base: Base

    /// Creates extensions with base object.
    ///
    /// - parameter base: Base object.
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol HasImprovements {
    /// Extended type
    associatedtype ImprovedTypes

    /// Reactive extensions.
    static var imp: Improvements<ImprovedTypes>.Type { get set }

    /// Reactive extensions.
    var imp: Improvements<ImprovedTypes> { get set }
}

extension HasImprovements {
    /// Reactive extensions.
    public static var imp: Improvements<Self>.Type {
        get {
            return Improvements<Self>.self
        }
        set {
            // this enables using Reactive to "mutate" base type
        }
    }

    /// Reactive extensions.
    public var imp: Improvements<Self> {
        get {
            return Improvements(self)
        }
        set {
            // this enables using Reactive to "mutate" base object
        }
    }
}

import Foundation

/// Extend NSObject with `rx` proxy.
extension NSObject: HasImprovements { }

