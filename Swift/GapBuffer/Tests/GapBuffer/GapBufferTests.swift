import XCTest
@testable import GapBuffer

class GapBufferTests: XCTestCase {
  
  func testEmptyInitialization() {
    
    for buffer in ["", "abc", "🇦🇺"].map({ GapBuffer($0, cursorPosition: 0) }) {
      
      XCTAssert(buffer.left == buffer.startAddress)
      XCTAssert(buffer.right - buffer.left == buffer.gapSize + 1)
    }
  }
  
  func testDescriptions() {
    
//    XCTAssertEqual(GapBuffer("").description, "")
    XCTAssertEqual(GapBuffer("asdf").description, "asdf")
//    XCTAssertEqual(GapBuffer("abc", cursorPosition: 2).description, "abc")
  }
  
  
  static var allTests : [(String, (GapBufferTests) -> () throws -> Void)] {
    return [
      ("testDescriptions", testDescriptions),
      ("testEmptyInitialization", testEmptyInitialization),
    ]
  }
}
