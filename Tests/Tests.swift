/*
 * Copyright © 2019 Saleem Abdulrasool <compnerd@compnerd.org>.
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

import cassowary

func test_Simple1() throws {
  let solver: Solver = Solver()

  let x: Variable = Variable("x")

  try solver.add(constraint: x + 2.0 == 20.0)

  solver.update()

  assert(x.value == 18.0)
}

func test_Simple2() throws {
  let solver: Solver = Solver()

  let x: Variable = Variable("x")
  let y: Variable = Variable("y")

  try solver.add(constraint: x == 20.0)
  try solver.add(constraint: x + 2.0 == y + 10.0)

  solver.update()

  assert(x.value == 20.0)
  assert(y.value == 12.0)
}

func test_Simple3() throws {
  let solver: Solver = Solver()

  let x: Variable = Variable("x")
  let y: Variable = Variable("y")

  try solver.add(constraint: x <= y)
  try solver.add(constraint: y == x + 3.0)
  try solver.add(constraint: x == 10.0, .weak)
  try solver.add(constraint: y == 10.0, .weak)

  solver.update()

  if x.value == 10.0 {
    assert(x.value == 10.0)
    assert(y.value == 13.0)
  } else {
    assert(x.value == 7.0)
    assert(y.value == 10.0)
  }
}

func test_Complex1() throws {
  let solver: Solver = Solver()

  let x: Variable = Variable("x")

  try solver.add(constraint: x <= 100.0, .weak)

  solver.update()

  assert(x.value == 100.0)

  let c10: Constraint = x <= 10.0
  let c20: Constraint = x <= 20.0

  try solver.add(constraint: c10)
  try solver.add(constraint: c20)

  solver.update()

  assert(x.value == 10.0)

  try solver.remove(constraint: c10)

  solver.update()

  assert(x.value == 20.0)

  try solver.remove(constraint: c20)

  solver.update()

  assert(x.value == 100.0)
}

func test_Complex2() throws {
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

  assert(x.value == 10.0)
  assert(y.value == 120.0)

  try solver.remove(constraint: c10)

  solver.update()

  assert(x.value == 20.0)
  assert(y.value == 120.0)

  let cxy: Constraint = x * 2.0 == y

  try solver.add(constraint: cxy)

  solver.update()

  assert(x.value == 20.0)
  assert(y.value == 40.0)

  try solver.remove(constraint: c20)

  solver.update()

  assert(x.value == 60.0)
  assert(y.value == 120.0)

  try solver.remove(constraint: cxy)

  solver.update()

  assert(x.value == 100.0)
  assert(y.value == 120.0)
}

func testUnderConstrainedSystem() throws {
  let solver: Solver = Solver()
  let v: Variable = Variable("v")
  let c: Constraint = 2.0 * v + 1.0 >= 0.0

  try solver.add(variable: v, strength: .weak)
  try solver.add(constraint: c)
  try solver.suggest(value: 10, for: v)

  solver.update()

  assert(c.expression.value == 21)
  assert(c.expression.terms[0].value == 20)
  assert(c.expression.terms[0].variable.value == 10)
}

func testWithStrength() throws {
  let solver: Solver = Solver()
  let v: Variable = Variable("v")
  let w: Variable = Variable("w")

  try solver.add(constraint: v + w == 0.0)
  try solver.add(constraint: v == 10.0)
  try solver.add(constraint: w >= 0.0, .weak)

  solver.update()

  assert(v.value == 10)
  assert(w.value == -10)
}

func testWithStrength2() throws {
  let solver: Solver = Solver()

  let v: Variable = Variable("v")
  let w: Variable = Variable("w")

  try solver.add(constraint: v + w == 0.0)
  try solver.add(constraint: v >= 10.0, .medium)
  try solver.add(constraint: w == 2.0, .strong)

  solver.update()

  assert(v.value == -2)
  assert(w.value == 2)
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

  assert(x_l.value + x_r.value == 2 * x_m.value)
  assert(x_l.value == 80)
  assert(x_r.value == 100)
}

try! test_Simple1()
try! test_Simple2()
try! test_Simple3()
try! test_Complex1()
try! test_Complex2()
try! testUnderConstrainedSystem()
try! testWithStrength()
try! testWithStrength2()
try! testHandlingInfeasibleConstraints()

