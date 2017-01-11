
import func Darwin.C.stdlib.realloc

typealias Pointer<T> = UnsafePointer<T>
typealias BufferPointer<T> = UnsafeBufferPointer<T>
typealias MutablePointer<T> = UnsafeMutablePointer<T>
typealias MutableBufferPointer<T> = UnsafeMutableBufferPointer<T>
typealias RawPointer = UnsafeRawPointer
typealias RawBufferPointer = UnsafeRawBufferPointer
typealias MutableRawPointer = UnsafeMutableRawPointer
typealias MutableRawBufferPointer = UnsafeMutableRawBufferPointer

extension MutableRawPointer {

    mutating func realloc(capacity: Int) {
        self = Darwin.realloc(self, capacity)
    }
}

extension MutableRawBufferPointer {

    mutating func realloc(capacity: Int) {
        guard var baseAddress = baseAddress else {
            self = MutableRawBufferPointer.allocate(count: capacity)
            return
        }

        baseAddress.realloc(capacity: capacity)

        self = MutableRawBufferPointer(start: baseAddress, count: capacity)
    }
}
