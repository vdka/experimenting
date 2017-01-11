import XCTest
@testable import http2parser

class http2parserTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(http2parser().text, "Hello, World!")
    }


    static var allTests : [(String, (http2parserTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
