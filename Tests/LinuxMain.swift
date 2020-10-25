/*
 * Copyright © 2020 Saleem Abdulrasool <compnerd@compnerd.org>.
 * All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

import XCTest
@testable
import CassowaryTests

#if !(os(iOS) || os(macOS) || os(tvOS) || os(watchOS))
extension CassowaryTests {
  static var allTests: [(String, (CassowaryTests) -> () throws -> Void)] {
    return [
      ("testSimple1", CassowaryTests.testSimple1),
      ("testSimple2", CassowaryTests.testSimple2),
      ("testSimple3", CassowaryTests.testSimple3),
      ("testComplex1", CassowaryTests.testComplex1),
      ("testComplex2", CassowaryTests.testComplex2),
      ("testUnderConstrainedSystem", CassowaryTests.testUnderConstrainedSystem),
      ("testWithStrength", CassowaryTests.testWithStrength),
      ("testWithStrength2", CassowaryTests.testWithStrength2),
      ("testHandlingInfeasibleConstraints", CassowaryTests.testHandlingInfeasibleConstraints),
    ]
  }
}
#endif

XCTMain([
  testCase(CassowaryTests.allTests),
])
