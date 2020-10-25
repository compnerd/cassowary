/*
 * Copyright © 2019 Saleem Abdulrasool <compnerd@compnerd.org>.
 * All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

import Cassowary
import XCTest

final class CassowaryTests: XCTestCase {
  func testSimple1() throws {
    let solver: Solver = Solver()

    let x: Variable = Variable("x")

    try solver.add(constraint: x + 2.0 == 20.0)

    solver.update()

    XCTAssertEqual(x.value, 18.0)
  }

  func testSimple2() throws {
    let solver: Solver = Solver()

    let x: Variable = Variable("x")
    let y: Variable = Variable("y")

    try solver.add(constraint: x == 20.0)
    try solver.add(constraint: x + 2.0 == y + 10.0)

    solver.update()

    XCTAssertEqual(x.value, 20.0)
    XCTAssertEqual(y.value, 12.0)
  }

  func testSimple3() throws {
    let solver: Solver = Solver()

    let x: Variable = Variable("x")
    let y: Variable = Variable("y")

    try solver.add(constraint: x <= y)
    try solver.add(constraint: y == x + 3.0)
    try solver.add(constraint: x == 10.0, .weak)
    try solver.add(constraint: y == 10.0, .weak)

    solver.update()

    if x.value == 10.0 {
      XCTAssertEqual(x.value, 10.0)
      XCTAssertEqual(y.value, 13.0)
    } else {
      XCTAssertEqual(x.value, 7.0)
      XCTAssertEqual(y.value, 10.0)
    }
  }

  func testComplex1() throws {
    let solver: Solver = Solver()

    let x: Variable = Variable("x")

    try solver.add(constraint: x <= 100.0, .weak)

    solver.update()

    XCTAssertEqual(x.value, 100.0)

    let c10: Constraint = x <= 10.0
    let c20: Constraint = x <= 20.0

    try solver.add(constraint: c10)
    try solver.add(constraint: c20)

    solver.update()

    XCTAssertEqual(x.value, 10.0)

    try solver.remove(constraint: c10)

    solver.update()

    XCTAssertEqual(x.value, 20.0)

    try solver.remove(constraint: c20)

    solver.update()

    XCTAssertEqual(x.value, 100.0)
  }

  func testComplex2() throws {
    let solver: Solver = Solver()

    let x: Variable = Variable("x")
    let y: Variable = Variable("y")

    try solver.add(constraint: x == 100, .weak)
    try solver.add(constraint: y == 120, .strong)

    let c10: Constraint = x <= 10.0
    let c20: Constraint = x <= 20.0

    try solver.add(constraint: c10)
    try solver.add(constraint: c20)

    solver.update()

    XCTAssertEqual(x.value, 10.0)
    XCTAssertEqual(y.value, 120.0)

    try solver.remove(constraint: c10)

    solver.update()

    XCTAssertEqual(x.value, 20.0)
    XCTAssertEqual(y.value, 120.0)

    let cxy: Constraint = x * 2.0 == y

    try solver.add(constraint: cxy)

    solver.update()

    XCTAssertEqual(x.value, 20.0)
    XCTAssertEqual(y.value, 40.0)

    try solver.remove(constraint: c20)

    solver.update()

    XCTAssertEqual(x.value, 60.0)
    XCTAssertEqual(y.value, 120.0)

    try solver.remove(constraint: cxy)

    solver.update()

    XCTAssertEqual(x.value, 100.0)
    XCTAssertEqual(y.value, 120.0)
  }

  func testUnderConstrainedSystem() throws {
    let solver: Solver = Solver()
    let v: Variable = Variable("v")
    let c: Constraint = 2.0 * v + 1.0 >= 0.0

    try solver.add(variable: v, strength: .weak)
    try solver.add(constraint: c)
    try solver.suggest(value: 10, for: v)

    solver.update()

    XCTAssertEqual(c.expression.value, 21)
    XCTAssertEqual(c.expression.terms[0].value, 20)
    XCTAssertEqual(c.expression.terms[0].variable.value, 10)
  }

  func testWithStrength() throws {
    let solver: Solver = Solver()
    let v: Variable = Variable("v")
    let w: Variable = Variable("w")

    try solver.add(constraint: v + w == 0.0)
    try solver.add(constraint: v == 10.0)
    try solver.add(constraint: w >= 0.0, .weak)

    solver.update()

    XCTAssertEqual(v.value, 10)
    XCTAssertEqual(w.value, -10)
  }

  func testWithStrength2() throws {
    let solver: Solver = Solver()

    let v: Variable = Variable("v")
    let w: Variable = Variable("w")

    try solver.add(constraint: v + w == 0.0)
    try solver.add(constraint: v >= 10.0, .medium)
    try solver.add(constraint: w == 2.0, .strong)

    solver.update()

    XCTAssertEqual(v.value, -2)
    XCTAssertEqual(w.value, 2)
  }

  func testHandlingInfeasibleConstraints() throws {
    let solver: Solver = Solver()

    let x_m: Variable = Variable("xm")
    let x_l: Variable = Variable("xl")
    let x_r: Variable = Variable("xr")

    try solver.add(variable: x_m, strength: .strong)
    try solver.add(variable: x_l, strength: .weak)
    try solver.add(variable: x_r, strength: .weak)

    try solver.add(constraint: 2.0 * x_m == x_l + x_r)
    try solver.add(constraint: x_l + 20.0 <= x_r)
    try solver.add(constraint: x_l >= -10.0)
    try solver.add(constraint: x_r <= 100.0)

    try solver.suggest(value: 40, for: x_m)
    try solver.suggest(value: 50, for: x_r)
    try solver.suggest(value: 30, for: x_l)

    // First update causing a normal update.
    try solver.suggest(value: 60, for: x_m)

    // Create an infeasible condition, triggering a dual optimization.
    try solver.suggest(value: 90, for: x_m)

    solver.update()

    XCTAssertEqual(x_l.value + x_r.value, 2 * x_m.value)
    XCTAssertEqual(x_l.value, 80)
    XCTAssertEqual(x_r.value, 100)
  }
}
