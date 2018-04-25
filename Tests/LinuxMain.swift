import XCTest

import SafetyCodeTests

var tests = [XCTestCaseEntry]()
tests += SafetyCodeTests.allTests()
XCTMain(tests)