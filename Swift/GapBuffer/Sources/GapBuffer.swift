
extension Array {

  internal func pointersSurrounding(index: Index) -> (left: UnsafePointer<Element>, right: UnsafePointer<Element>) {

    guard indices.contains(index) else { fatalError("index out of bounds") }

    var baseAddress = withUnsafeBufferPointer { $0.baseAddress! }

    baseAddress += index

    return (baseAddress.advanced(by: -1), baseAddress.advanced(by: 1))
  }
}

class GapBuffer {

  var buffer: [UInt8]
  var gapSize: Int = 1

  var placeHolder = "_".utf8.first!

  var startAddress: UnsafeMutablePointer<UInt8> {
    return buffer.withUnsafeMutableBufferPointer { $0.baseAddress! }
  }

  /// Pointer to the byte directly before the Gap
  var left: UnsafeMutablePointer<UInt8>

  /// Pointer to the start of the gap
  var gapStart: UnsafeMutablePointer<UInt8> {
    return left.advanced(by: 1)
  }
  
  /*               __GAP__               */
  /* 0 S - - - L gS _ _ _ gE R - - - E 0 */
  
  /// Pointer to the end of the gap
  var gapEnd: UnsafeMutablePointer<UInt8> {
    return gapStart.advanced(by: gapSize)
  }

  /// Pointer to the byte directly after the Gap
  var right: UnsafeMutablePointer<UInt8>
  
  var endAddress: UnsafeMutablePointer<UInt8> {
    return startAddress.advanced(by: buffer.endIndex)
  }

  init(_ contents: [UInt8], cursorPosition: Int = 0, gapSize: Int = 1) {

    precondition(contents.count >= cursorPosition)
    
    self.gapSize = gapSize
    buffer = contents

    buffer.insert(contentsOf: Array(repeating: placeHolder, count: numericCast(gapSize)), at: cursorPosition)
    
    let startAddress = buffer.withUnsafeMutableBufferPointer { $0.baseAddress! }
    
    left = startAddress.advanced(by: cursorPosition)
    right = startAddress.advanced(by: cursorPosition + gapSize + 1)

//    let (l, r) = buffer.pointersSurrounding(index: cursorPosition)
//
//    left = UnsafeMutablePointer(l)
//    right = UnsafeMutablePointer(r + gapSize)
  }
}

extension GapBuffer {

  convenience init(_ string: String, cursorPosition: Int = 0, gapSize: Int = 1) {
    let array = Array(string.utf8)
    self.init(array, cursorPosition: cursorPosition, gapSize: gapSize)
  }
}

extension GapBuffer {
  
  enum Direction { case forward, backward }

  func move(_ direction: Direction) {
    
#if TESTING
    defer {
      (gapStart.pointee, gapEnd.pointee) = (95, 95)
      print(debugDescription)
    }
#endif
    
    switch direction {
      
    case .forward where right == endAddress - gapSize:
      
#if TESTING
      print("at end of buffer!")
#endif

      return
      
    case .backward where left == startAddress:
      
#if TESTING
      print("at end of buffer!")
#endif

      return
      
    case .forward where UTF8.isContinuation(right.pointee):
      
      moveCodeUnit(.forward)
      move(.forward)
      
    case .backward where UTF8.isContinuation(left.pointee):
      
      moveCodeUnit(.backward)
      move(.backward)
      
    case .forward:
      
      moveCodeUnit(.forward)
      
    case .backward:
      
      moveCodeUnit(.backward)
      
    }
  }
  
  
  private func moveCodeUnit(_ direction: Direction) {
    
    switch direction {
    case .forward:
      
      left += 1
      left.pointee = right.move()
      right += 1
      
    case .backward:
      
      right -= 1
      right.pointee = left.move()
      left -= 1
    }
  }
}

extension GapBuffer {


}


// MARK: - description

extension GapBuffer: CustomStringConvertible, CustomDebugStringConvertible {
  
  var description: String {
    
    var codeUnits: [UTF8.CodeUnit] = []
    
    for p in startAddress...left {

      codeUnits.append(p.pointee)
    }
    
    for p in right..<endAddress {

      codeUnits.append(p.pointee)
    }
    
    codeUnits.append(0)
    
    let bytePointer = UnsafePointer<CChar>.self
    return String(cString: unsafeBitCast(right, to: bytePointer))
    
    buffer.append(0)
    gapStart.pointee = 0
    defer {
      buffer.removeLast()
      gapStart.pointee = "_".utf8.first!
    }
        
    let leftString = String(cString: unsafeBitCast(startAddress, to: bytePointer))
    let rightString = String(cString: unsafeBitCast(right, to: bytePointer))
    
    return leftString + rightString
  }
  
  var debugDescription: String {
    
    return ""
  }
}


