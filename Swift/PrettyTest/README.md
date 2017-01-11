# Make Swift Tests results glancable

XCTest uses `stderr` to print results for some reason to you can pipe output using the following.
```
> swift test 2>&1 | PrettyTest
....................................x...............................
/Users/Ethan/Source/vdka/JSON/Tests/JSON/ParserTests.swift:192: error: -[JSONTestSuite.ParsingTests testNumber_Double_Exp_Negative] : XCTAssertEqual failed: ("-0.243245") is not equal to ("-0.243245") -
67 passes, 1 failures
```

