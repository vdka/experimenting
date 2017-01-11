
import Foundation

let doublePattern = "\\d+.\\d+"
let doubleRegex = try Regex(pattern: "(\(doublePattern))")

let passRegex = try Regex(pattern: "Test Case .+ passed")
let failRegex = try Regex(pattern: "Test Case .+ failed")
let errorRegex = try Regex(pattern: ".+ error: .+ failed")

let perfRegex = try Regex(pattern: "Test Case .+ measured")
let fileRegex = try Regex(pattern: "\\.swift:\\d+")
let testRegex = try Regex(pattern: "('-\\[.+\\]')")
let avgRegex = try Regex(pattern: "(average \(doublePattern))")
let stddevRegex = try Regex(pattern: "(standard deviation \(doublePattern))")

// /Users/Ethan/Source/vdka/JSON/Tests/JSON/ParserTests.swift:192: error: -[JSONTestSuite.ParsingTests testNumber_Double_Exp_Negative] : XCTAssertEqual failed: ("-0.243245") is not equal to ("-0.243245") -

// /Users/Ethan/Source/vdka/JSON/Tests/JSON/SerializerPerformance.swift:32: Test Case '-[JSONTestSuite.SerializerBenchmarks testSerializerLargeJsonPrettyPrinted]' measured [Time, seconds] average: 0.026, relative standard deviation: 6.129%, values: [0.027167, 0.025776, 0.025891, 0.023501, 0.026628, 0.026125, 0.024360, 0.023288, 0.028428, 0.024431], performanceMetricID:com.apple.XCTPerformanceMetric_WallClockTime, baselineName: "", baselineAverage: , maxPercentRegression: 10.000%, maxPercentRelativeStandardDeviation: 10.000%, maxRegression: 0.100, maxStandardDeviation: 0.100
typealias BenchmarkResult = (name: String, avg: String, stdDev: String)

var benchmarks: [BenchmarkResult] = []
var failureMessages: [String] = []

var passes = 0
var failures = 0

while let line = readLine() {

  if passRegex.matches(line) {
    print(".", terminator: "")
    passes += 1
  } else if errorRegex.matches(line) {
    failureMessages.append(line)
    print("F", terminator: "")
    failures += 1
  }

  //if perfRegex.matches(line) {
  //  let testName = testRegex.groups(line).first!
  //  print("getting avg")
  //  let avg = avgRegex.groups(line).first!
  //  print("getting stdev")
  //  let stdDev = stddevRegex.groups(line).first!
  //  //let stats = try Regex(pattern: "(average.+standard deviation: .+%, values)").groups(line).first!
  //  benchmarks.append((name: testName, avg: avg, stdDev: stdDev))
  //}

  fflush(stdout)
}

print("")

for failureMessage in failureMessages {
  print(failureMessage)
}

print("\(passes) passes, \(failures) failures")



