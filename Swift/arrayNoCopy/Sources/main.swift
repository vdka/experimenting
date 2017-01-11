
func dumpMemory<T>(of input: T, nBytes: Int = MemoryLayout<T>.size) {

  var input = input

  withUnsafePointer(to: &input) { pointer in

    let bytePointer = unsafeBitCast(pointer, to: UnsafePointer<UInt8>.self)

    for i in 0 ..< MemoryLayout<T>.size(ofValue: pointer.pointee) {
      if i % 8 == 0 && i != 0 { print("\n", terminator: "") }

      let byte = bytePointer.advanced(by: i).pointee
      let hexByte = String(byte, radix: 16)

      // Pad the output to be 2 characters wide
      if hexByte.characters.count == 1 { print("0", terminator: "") }
      print(hexByte, terminator: " ")
    }
    print("")
  }
}

func newArrayNoCopy<T>(_ pointer: UnsafeBufferPointer<T>) -> Array<T> {

  return Array(pointer)
}

let array: Array<UInt8> = ["a".utf8.first!, "b".utf8.first!, "c".utf8.first!]

let pointer: UnsafeBufferPointer<UInt8> = array.withUnsafeBufferPointer { $0 }

dumpMemory(of: array)

let newArray = newArrayNoCopy(pointer)
dumpMemory(of: newArray)

print("before: \(array)")
print("newCount: \(newArray.count)")
print("after : \(newArray)")

print("done")
