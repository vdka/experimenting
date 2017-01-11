
import func Darwin.C.stdlib.free
import func Darwin.C.stdlib.realloc

typealias ImmutablePointer<T> = UnsafePointer<T>
typealias ImmutableBufferPointer<T> = UnsafeBufferPointer<T>
typealias ImmutableRawPointer = UnsafeRawPointer
typealias ImmutableRawBufferPointer = UnsafeRawBufferPointer

typealias Pointer<T> = UnsafeMutablePointer<T>
typealias BufferPointer<T> = UnsafeMutableBufferPointer<T>
typealias RawPointer = UnsafeMutableRawPointer
typealias RawBufferPointer = UnsafeMutableRawBufferPointer

extension RawPointer {

    mutating func realloc(capacity: Int) {
        self = Darwin.realloc(self, capacity)
    }

    /// - Postcondition: The pointer is no longer pointing to valid memory
    func free() {
        Darwin.free(self)
    }
}

extension RawBufferPointer {

    mutating func realloc(capacity: Int) {
        guard var baseAddress = baseAddress else {
            self = RawBufferPointer.allocate(count: capacity)
            return
        }

        baseAddress.realloc(capacity: capacity)

        self = RawBufferPointer(start: baseAddress, count: capacity)
    }

    /// - Postcondition: The pointer is no longer pointing to valid memory
    mutating func free() {
        guard let baseAddress = baseAddress else { return }
        baseAddress.free()
    }
}
