/*
 * Copyright © 2020 Saleem Abdulrasool <compnerd@compnerd.org>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
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
