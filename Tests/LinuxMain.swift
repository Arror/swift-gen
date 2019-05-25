import XCTest

import swift_genTests

var tests = [XCTestCaseEntry]()
tests += swift_genTests.allTests()
XCTMain(tests)
