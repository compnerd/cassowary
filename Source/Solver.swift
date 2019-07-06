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

private typealias Tag = (marker: Symbol, other: Symbol)

private class EditInfo {
  public var tag: Tag
  public var constraint: Constraint
  public var constant: Double

  public init(tag: Tag, constraint: Constraint, constant: Double) {
    self.tag = tag
    self.constraint = constraint
    self.constant = constant
  }
}

public class Solver {
  private var rows: [Symbol:Row] = [:]
  private var constraints: [Constraint:Tag] = [:]
  private var variables: [Variable:Symbol] = [:]
  private var edits: [Variable:EditInfo] = [:]
  private var infeasible: [Symbol] = []
  private var objective: Row = Row()
  private var artificial: Row?
  private var id: Symbol.ID = 1

  public init() {}

  private func SymID() -> Symbol.ID {
    let value: Symbol.ID = id
    id += 1
    return value
  }

  // MARK - private functions

  // Choose the subject for solving the row.
  //
  // This method will choose the best target subject to solve the row.  An
  // invalid symbol will be returned if there is no valid target.
  //
  // The symbols are chosen according to the following precedence:
  //   1) the first symbol representing an external variable.
  //   2) a ngative slack or error tag variable.
  //
  // If a subject cannot be found, an invalid symbol will be returned.
  private func subject(for row: Row, with tag: Tag) -> Symbol {
    for (symbol, _) in row.cells {
      if symbol.type == .external {
        return symbol
      }
    }

    if tag.marker.type == .slack || tag.marker.type == .error {
      if row.coefficient(for: tag.marker) < 0.0 {
        return tag.marker
      }
    }

    if tag.other.type == .slack || tag.other.type == .error {
      if row.coefficient(for: tag.other) < 0.0 {
        return tag.other
      }
    }

    return .invalid
  }

  // Add the row to the tableau using an artificial variable.
  //
  // This will return `false` if the constraint cannot be satisfied.
  private func add(row: Row) -> Bool {
    // Create and add the artificial variable to the tableau
    let variable: Symbol = Symbol(.slack, SymID())
    rows[variable] = Row(copy: row)
    artificial = Row(copy: row)

    // Optimize the artificial objective.  This is successful only if the
    // artificial objective is optimized to zero.
    try! optimize(objective: artificial!)
    let success: Bool = artificial!.constant ~= 0.0
    artificial = nil

    // If the artificial variable is not basic, pivot the row so that it becomes
    // basic  If the row is constant, exit early.
    if let r: Row = rows[variable] {
      rows.removeValue(forKey: variable)
      if r.cells.count == 0 { return success }

      let entering: Symbol = pivot(for: r)
      // The constraint is unsatisfyable (will this ever happen?)
      if entering.type == .invalid { return false }

      r.solve(for: variable, and: entering)
      substitute(symbol: entering, for: r)
      rows[entering] = r
    }

    // Remove the artificial variable from the tableau.
    for (_, row) in rows {
      row.remove(variable)
    }
    objective.remove(variable)

    return success
  }

  // Get the symbol for the given variable.
  private func symbol(for variable: Variable) -> Symbol {
    guard let symbol: Symbol = variables[variable] else {
      let symbol: Symbol = Symbol(.external, SymID())
      variables[variable] = symbol
      return symbol
    }
    return symbol
  }

  // Create a new Row for the given constraint.
  //
  // The terms in the constaint will be converted to cells in the row.  Any
  // term in the constraint with a coefficient of zero is ignored.  If the
  // symbol for a given cell variable is basic, the ell variable will be
  // substituted with the basic row.
  //
  // The necessary slack and error variables will be added to the row.  If the
  // constant for the row is negative, the sign for the row will be inverted so
  // the constant becomes positive.
  //
  // The tag will be updated with the marker and error symbols to use for
  // tracking the movement of the constraint in the tableau.
  private func row(for constraint: Constraint) -> (Row, Tag) {
    let expression: Expression = constraint.expression
    let row: Row = Row(expression.constant)
    var tag: Tag = Tag(marker: .invalid, other: .invalid)

    // Substitute the current basic variables into the row.
    for term in expression.terms {
      if term.coefficient ~= 0.0 { continue }

      let symbol: Symbol = self.symbol(for: term.variable)
      if let r = rows[symbol] {
        row.insert(row: r, term.coefficient)
      } else {
        row.insert(symbol: symbol, term.coefficient)
      }
    }

    // Add the necessary slack, error, and dummy variables.
    switch constraint.operation {
    case .le, .ge:
      let coefficient: Double = constraint.operation == .le ? 1.0 : -1.0

      tag.marker = Symbol(.slack, SymID())
      row.insert(symbol: tag.marker, coefficient)

      if constraint.strength < .required {
        tag.other = Symbol(.error, SymID())
        row.insert(symbol: tag.other, -coefficient)
        objective.insert(symbol: tag.other, constraint.strength)
      }

    case .eq:
      if constraint.strength < .required {
        tag.marker = Symbol(.error, SymID())
        tag.other = Symbol(.error, SymID())

        row.insert(symbol: tag.marker, -1.0)  // v = eplus - eminus
        row.insert(symbol: tag.other, 1.0)    // v = eplus + eminus = 0

        objective.insert(symbol: tag.marker, constraint.strength)
        objective.insert(symbol: tag.other, constraint.strength)
      } else {
        tag.marker = Symbol(.dummy, SymID())
        row.insert(symbol: tag.marker)
      }
    }

    // Ensure that the row has a positive constant.
    if row.constant < 0.0 {
      row.invert()
    }

    return (row, tag)
  }


  // Substitute the parameteric symbol with the given row.
  //
  // This method will subsitute all instances of the parametric symbol in the
  // tableau and the objective function with the given row.
  private func substitute(symbol: Symbol, for row: Row) {
    for (s, r) in rows {
      r.substitute(symbol: symbol, from: row)
      if s.type == .external { continue }
      if r.constant < 0.0 {
        infeasible.append(s)
      }
    }

    objective.substitute(symbol: symbol, from: row)
    if let artificial = artificial {
      artificial.substitute(symbol: symbol, from: row)
    }
  }

  // Optimize the system for the given objective function.
  //
  // This method performs iterations of Phase 2 of the simplex method until the
  // objective function reaches a minimum.
  private func optimize(objective: Row) throws {
    while true {
      let entering: Symbol = variable(for: objective)
      if entering.type == .invalid { return }

      guard let (exiting, row) = self.row(entering: entering) else {
        throw InternalSolverError("the objective is unbounded")
      }

      // Pivot the entering symbol into the basis.
      rows.removeValue(forKey: exiting)
      row.solve(for: exiting, and: entering)
      substitute(symbol: entering, for: row)
      rows[entering] = row
    }
  }

  // Optimize the system using the dual of the simplex method.
  //
  // The current state of the system should be such that the objective function
  // is optimal, but not feasible.  THis method will perform an iteration of the
  // dual simplex method to make the solution both optional and feasible.
  private func optimize_() throws {
    while infeasible.count > 0 {
      let exiting: Symbol = infeasible.popLast()!
      guard let row: Row = rows[exiting] else {
        continue
      }

      if row.constant ~= 0.0 || row.constant < 0.0 {
        continue
      }

      let entering: Symbol = variable_(for: row)
      if entering.type == .invalid {
        throw InternalSolverError("dual optimize failed")
      }

      // Pivot the entering symbol into the basis.
      rows.removeValue(forKey: exiting)
      row.solve(for: exiting, and: entering)
      substitute(symbol: entering, for: row)
      rows[entering] = row
    }
  }

  // Compute the entering variable for a pivot operation.
  //
  // This method will return the first symbol in the objective function which is
  // non-dummy and has a coefficient less than zero.  If no symbol meets the
  // criteria, it means that the objective function is at a minimum and an
  // invalid symbol is returned.
  private func variable(for objective: Row) -> Symbol {
    for (symbol, coefficient) in objective.cells {
      if symbol.type == .dummy { continue }
      if coefficient < 0.0 {
        return symbol
      }
    }
    return .invalid
  }

  // Compute the entering symbol for the dual of the optimize operation.
  //
  // This method will return the symol in the row which has a positive
  // coefficient and yields the minimum ratio for its respective symbol in the
  // objective function.  The provided row *must* be infeasible.  If no symbol
  // is found which mets the criteria, an invlaid symbol is returned.
  private func variable_(for objective: Row) -> Symbol {
    var ratio: Double = .greatestFiniteMagnitude
    var entering: Symbol = .invalid

    for (symbol, coefficient) in objective.cells {
      if symbol.type == .dummy { continue }
      if coefficient > 0.0 {
        let r: Double = self.objective.coefficient(for: symbol) / coefficient
        if r < ratio {
          ratio = r
          entering = symbol
        }
      }
    }

    return entering
  }

  // Get the first slack or error symbol in the row.
  //
  // If no such symbol is present, an invalid symbol will be returned.
  private func pivot(for row: Row) -> Symbol {
    for (symbol, _) in row.cells {
      if symbol.type == .slack || symbol.type == .error {
        return symbol
      }
    }
    return .invalid
  }

  // Compute the row which holds the exit symbol for a pivot.
  //
  // This method will return the entry in the row map which holds the exit
  // symbol.  If no appropriate exit symbol is found, `nil` will be returned.
  // This indicates that the object function is unbounded.
  private func row(entering: Symbol) -> (exiting: Symbol, row: Row)? {
    var entry: (exiting: Symbol, row: Row)? = nil

    var ratio: Double = .greatestFiniteMagnitude
    for (symbol, row) in rows {
      if symbol.type == .external { continue }

      let coefficient: Double = row.coefficient(for: entering)
      if coefficient < 0.0 {
        let r: Double = -row.constant / coefficient
        if r < ratio {
          ratio = r
          entry = (exiting: symbol, row: row)
        }
      }
    }

    return entry
  }

  // Compute the leaving row for a marker variable.
  //
  // This method will return the entry in the row map which holds the given
  // marker variable.  The row will be chosen according to the following
  // procedure:
  //
  //  1) The row with a restricted basic variable and a negative coefficient for
  //     the maker with the smallest ratio of -constant / coefficient.
  //  2) The row with a restricted basic variable and the smallest ratio of
  //     constant / coefficient.
  //  3) The last unrestricted row which contains the marker.
  //
  //  If the marker does not exist in any row, `nil` will be returned.  This
  //  indicates an internal solver error since the marker *should* exist
  //  somewhere in the tableau.
  private func row(leaving: Symbol) -> (marker: Symbol, row: Row)? {
    var first: (marker: Symbol, row: Row)? = nil
    var second: (marker: Symbol, row: Row)? = nil
    var third: (marker: Symbol, row: Row)? = nil

    var r1: Double = .greatestFiniteMagnitude
    var r2: Double = .greatestFiniteMagnitude
    for (symbol, row) in rows {
      let coefficient: Double = row.coefficient(for: leaving)
      if coefficient == 0.0 { continue }

      if symbol.type == .external {
        third = (symbol, row)
      } else if coefficient < 0.0 {
        let ratio: Double = -row.constant / coefficient
        if ratio < r1 {
          r1 = ratio
          first = (symbol, row)
        }
      } else {
        let ratio: Double = row.constant / coefficient
        if ratio < r2 {
          r2 = ratio
          second = (symbol, row)
        }
      }
    }

    return first ?? second ?? third
  }

  // Remove the effects of a constraint on the objective function.
  private func nullify(constraint: Constraint, _ tag: Tag) {
    if tag.marker.type == .error {
      nullify(symbol: tag.marker, constraint.strength)
    }

    if tag.other.type == .error {
      nullify(symbol: tag.other, constraint.strength)
    }
  }

  // Remove the efects of an error marker on the objective function.
  private func nullify(symbol: Symbol, _ strength: Double) {
    if let row = rows[symbol] {
      objective.insert(row: row, -strength)
    } else {
      objective.insert(symbol: symbol, -strength)
    }
  }

  // MARK - constraint

  /// Add a constraint to the solver.
  public func add(constraint: Constraint) throws {
    guard constraints[constraint] == nil else {
      throw DuplicateConstraint(constraint)
    }

    // Creating a row causes sybols to be reserved for the variables in the
    // constraint.
    let (row, tag) = self.row(for: constraint)
    var subject: Symbol = self.subject(for: row, with: tag)

    // If we did not find a valid entering symbol, one last option is available
    // if the entire row is composed of dummy variables.  If the constnat of the
    // row is zero, then this represents redundant constraints and the new dummy
    // marker can enter the basis.  If the constant is non-zero, then it
    // represents and unsatisfiable constraint.
    if subject.type == .invalid &&
       row.cells.reduce(true, { $0 && $1.key.type == .dummy }) {
      if row.constant ~= 0.0 {
        throw UnsatisfiableConstraint(constraint)
      }
      subject = tag.marker
    }

    // If an entering symbol still isn't found, then the row must be added using
    // an artificial variable.  If that fails, then the row represents an
    // unsatisfiable constraint.
    if subject.type == .invalid {
      if !add(row: row) {
        throw UnsatisfiableConstraint(constraint)
      }
    } else {
      row.solve(for: subject)
      substitute(symbol: subject, for: row)
      rows[subject] = row
    }

    constraints[constraint] = tag

    // Optimizing after each constraint is added performs less aggregate work
    // due to a smaller average system size.  It also ensures the solver remains
    // in a consistent state.
    try optimize(objective: objective)
  }

  public func add(constraint: Constraint, _ strength: Strength) throws {
    try add(constraint: constraint | strength)
  }

  /// Remove a constraint from the solver
  public func remove(constraint: Constraint) throws {
    guard let tag: Tag = constraints[constraint] else {
      throw UnknownConstraint(constraint)
    }

    constraints.removeValue(forKey: constraint)

    // Remove the error effects from the objective fnction *before* pivoting, or
    // substitutions into the objective will lead to incorrect solver results.
    nullify(constraint: constraint, tag)

    // If the marker is basic, simply drop the row.  Otherwise, pivot the marker
    // into the basis and then drop the row.
    if rows.removeValue(forKey: tag.marker) == nil {
      guard let (leaving, row) = row(leaving: tag.marker) else {
        throw InternalSolverError("failed to find leaving low")
      }

      rows.removeValue(forKey: leaving)
      row.solve(for: leaving, and: tag.marker)
      substitute(symbol: tag.marker, for: row)
    }

    // Optimizing after each constraint is removed ensures that the solver
    // remains consistent.  It makes the solver API easier to use at asmall
    // tradeoff for speed.
    try optimize(objective: objective)
  }

  /// Tests whether a constraint has been added to the solver.
  public func has(constraint: Constraint) -> Bool {
    return constraints[constraint] != nil
  }

  // MARK - Edit Variable

  /// Add an edit variable to the solver.
  //?
  /// This method should be called before the `suggest(value:for:)` method is
  /// used to supply a suggested value for the given edit variable.
  public func add(variable: Variable, strength s: Strength) throws {
    guard edits[variable] == nil else {
      throw DuplicateEditVariable(variable)
    }

    let strength: Strength = Strength.clip(s)
    if strength == .required {
      throw BadRequiredStrength()
    }

    let constraint: Constraint =
        Constraint(Expression(Term(variable)), .eq, strength)
    try add(constraint: constraint)
    edits[variable] = EditInfo(tag: constraints[constraint]!,
                               constraint: constraint, constant: 0.0)
  }

  /// Remove an edit variable from the solver.
  public func remove(variable: Variable) throws {
    guard let edit: EditInfo = edits[variable] else {
      throw UnknownEditVariable(variable)
    }
    try remove(constraint: edit.constraint)
    edits.removeValue(forKey: variable)
  }

  /// Tests whether an edit variable has been added to the solver.
  public func has(variable: Variable) -> Bool {
    return edits[variable] != nil
  }

  /// Suggest a value for the given edit variable.
  ///
  /// This method should be used after an edit variable has been addd to the
  /// solver in order to suggest the value for that variable.
  public func suggest(value: Double, for variable: Variable) throws {
    guard var edit: EditInfo = edits[variable] else {
      throw UnknownEditVariable(variable)
    }

    defer { try! optimize_() }

    let delta: Double = value - edit.constant
    edit.constant = value

    // Check first if the positive error variable is basic.
    if let row: Row = rows[edit.tag.marker] {
      if row.add(-delta) < 0.0 {
        infeasible.append(edit.tag.marker)
      }
      return
    }

    // Next, check if the negative error variable is basic.
    if let row: Row = rows[edit.tag.other] {
      if row.add(delta) < 0.0 {
        infeasible.append(edit.tag.other)
      }
      return
    }

    // Otherwise, update each row where the error variable exists
    for (symbol, row) in rows {
      let coefficient: Double = row.coefficient(for: edit.tag.marker)
      if coefficient != 0.0 && row.add(delta * coefficient) < 0.0 && symbol.type != .external {
         infeasible.append(symbol)
       }
    }
  }

  /// Update the values of the external solver variables.
  public func update() {
    for (variable, symbol) in variables {
      if let row = rows[symbol] {
        variable.value = row.constant
      } else {
        variable.value = 0
      }
    }
  }
}

extension Solver : CustomStringConvertible {
  public var description: String {
    return """
Objective
---------
\(String(describing: objective))

Tableau
-------
\(String(describing: rows))

Infeasible
----------
\(String(describing: infeasible))

Variables
---------
\(String(describing: variables))

Edit Variables
--------------
\(String(describing: edits))

Constraints
-----------
""" +
    constraints.reduce("\n") {
      return $0 + String(describing: $1.key) + "\n"
    }
  }
}

