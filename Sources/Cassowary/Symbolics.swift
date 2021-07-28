// Copyright © 2019 Saleem Abdulrasool <compnerd@compnerd.org>.
// SPDX-License-Identifier: BSD-3-Clause

// MARK - epsilon check

infix operator ~=
public func ~= (_ lhs: Double, _ rhs: Double) -> Bool {
  let epsilon: Double = 1.0e-8
  return abs(lhs - rhs) <= epsilon
}

// MARK - expression operations

public prefix func - (_ expression: Expression) -> Expression {
  return expression * -1.0
}

public func + (_ lhs: Expression, _ rhs: Expression) -> Expression {
  return Expression(lhs.terms + rhs.terms, lhs.constant + rhs.constant)
}

public func + (_ lhs: Expression, _ rhs: Term) -> Expression {
  return Expression(lhs.terms + [rhs], lhs.constant)
}

public func + (_ lhs: Expression, _ rhs: Variable) -> Expression {
  return lhs + Term(rhs)
}

public func + (_ lhs: Expression, _ rhs: Double) -> Expression {
  return Expression(lhs.terms, lhs.constant + rhs)
}

public func - (_ lhs: Expression, _ rhs: Expression) -> Expression {
  return lhs + -rhs
}

public func - (_ lhs: Expression, _ rhs: Term) -> Expression {
  return lhs + -rhs
}

public func - (_ lhs: Expression, _ rhs: Variable) -> Expression {
  return lhs + -rhs
}

public func - (_ lhs: Expression, _ rhs: Double) -> Expression {
  return lhs + -rhs
}

public func * (_ expression: Expression, _ coefficient: Double) -> Expression {
  return Expression(expression.terms.map { $0 * coefficient },
                    expression.constant * coefficient)
}

public func / (_ expression: Expression, _ denominator: Double) -> Expression {
  return expression * (1.0 / denominator)
}

// MARK - term operations

public prefix func - (_ term: Term) -> Term {
  return term * -1.0
}

public func + (_ lhs: Term, _ rhs: Expression) -> Expression {
  return rhs + lhs
}

public func + (_ lhs: Term, _ rhs: Term) -> Expression {
  return Expression([lhs, rhs])
}

public func + (_ lhs: Term, _ rhs: Variable) -> Expression {
  return lhs + Term(rhs)
}

public func + (_ lhs: Term, _ rhs: Double) -> Expression {
  return Expression(lhs, rhs)
}

public func - (_ lhs: Term, _ rhs: Expression) -> Expression {
  return -rhs + lhs
}

public func - (_ lhs: Term, _ rhs: Term) -> Expression {
  return lhs + -rhs
}

public func - (_ lhs: Term, _ rhs: Variable) -> Expression {
  return lhs + -rhs
}

public func - (_ lhs: Term, _ rhs: Double) -> Expression {
  return lhs + -rhs
}

public func * (_ term: Term, _ coefficient: Double) -> Term {
  return Term(term.variable, term.coefficient * coefficient)
}

public func / (_ term: Term, _ denominator: Double) -> Term {
  return term * (1.0 / denominator)
}

// MARK - variable operations

public prefix func - (_ variable: Variable) -> Term {
  return variable * -1.0
}

public func + (_ lhs: Variable, _ rhs: Expression) -> Expression {
  return rhs + lhs
}

public func + (_ lhs: Variable, _ rhs: Term) -> Expression {
  return rhs + lhs
}

public func + (_ lhs: Variable, _ rhs: Variable) -> Expression {
  return Term(lhs) + rhs
}

public func + (_ lhs: Variable, _ rhs: Double) -> Expression {
  return Term(lhs) + rhs
}

public func - (_ lhs: Variable, _ rhs: Expression) -> Expression {
  return lhs + -rhs
}

public func - (_ lhs: Variable, _ rhs: Term) -> Expression {
  return lhs + -rhs
}

public func - (_ lhs: Variable, _ rhs: Variable) -> Expression {
  return lhs + -rhs
}

public func - (_ lhs: Variable, _ rhs: Double) -> Expression {
  return lhs + -rhs
}

public func * (_ variable: Variable, _ coefficient: Double) -> Term {
  return Term(variable, coefficient)
}

public func / (_ variable: Variable, _ denominator: Double) -> Term {
  return variable * (1.0 / denominator)
}

// MARK - double operations

public func + (_ lhs: Double, _ rhs: Expression) -> Expression {
  return rhs + lhs
}

public func + (_ lhs: Double, _ rhs: Term) -> Expression {
  return rhs + lhs
}

public func + (_ lhs: Double, _ rhs: Variable) -> Expression {
  return rhs + lhs
}

public func - (_ lhs: Double, _ rhs: Expression) -> Expression {
  return -rhs + lhs
}

public func - (_ lhs: Double, _ rhs: Term) -> Expression {
  return -rhs + lhs
}

public func - (_ lhs: Double, _ rhs: Variable) -> Expression {
  return -rhs + lhs
}

public func * (_ coefficient: Double, _ expression: Expression) -> Expression {
  return expression * coefficient
}

public func * (_ coefficient: Double, _ term: Term) -> Term {
  return term * coefficient
}

public func * (_ coefficient: Double, _ variable: Variable) -> Term {
  return variable * coefficient
}

// MARK - expression constraints

public func == (_ lhs: Expression, _ rhs: Expression) -> Constraint {
  return Constraint(lhs - rhs, .eq)
}

public func == (_ lhs: Expression, _ rhs: Term) -> Constraint {
  return lhs == Expression(rhs)
}

public func == (_ lhs: Expression, _ rhs: Variable) -> Constraint {
  return lhs == Term(rhs)
}

public func == (_ lhs: Expression, _ rhs: Double) -> Constraint {
  return lhs == Expression(rhs)
}

public func <= (_ lhs: Expression, _ rhs: Expression) -> Constraint {
  return Constraint(lhs - rhs, .le)
}

public func <= (_ lhs: Expression, _ rhs: Term) -> Constraint {
  return lhs <= Expression(rhs)
}

public func <= (_ lhs: Expression, _ rhs: Variable) -> Constraint {
  return lhs <= Term(rhs)
}

public func <= (_ lhs: Expression, _ rhs: Double) -> Constraint {
  return lhs <= Expression(rhs)
}

public func >= (_ lhs: Expression, _ rhs: Expression) -> Constraint {
  return Constraint(lhs - rhs, .ge)
}

public func >= (_ lhs: Expression, _ rhs: Term) -> Constraint {
  return lhs >= Expression(rhs)
}

public func >= (_ lhs: Expression, _ rhs: Variable) -> Constraint {
  return lhs >= Term(rhs)
}

public func >= (_ lhs: Expression, _ rhs: Double) -> Constraint {
  return lhs >= Expression(rhs)
}

// MARK - term constraints

public func == (_ lhs: Term, _ rhs: Expression) -> Constraint {
  return rhs == lhs
}

public func == (_ lhs: Term, _ rhs: Term) -> Constraint {
  return Expression(lhs) == rhs
}

public func == (_ lhs: Term, _ rhs: Variable) -> Constraint {
  return Expression(lhs) == rhs
}

public func == (_ lhs: Term, _ rhs: Double) -> Constraint {
  return Expression(lhs) == rhs
}

public func <= (_ lhs: Term, _ rhs: Expression) -> Constraint {
  return rhs >= lhs
}

public func <= (_ lhs: Term, _ rhs: Term) -> Constraint {
  return Expression(lhs) <= rhs
}

public func <= (_ lhs: Term, _ rhs: Variable) -> Constraint {
  return Expression(lhs) <= rhs
}

public func <= (_ lhs: Term, _ rhs: Double) -> Constraint {
  return Expression(lhs) <= rhs
}

public func >= (_ lhs: Term, _ rhs: Expression) -> Constraint {
  return rhs <= lhs
}

public func >= (_ lhs: Term, _ rhs: Term) -> Constraint {
  return Expression(lhs) >= rhs
}

public func >= (_ lhs: Term, _ rhs: Variable) -> Constraint {
  return Expression(lhs) >= rhs
}

public func >= (_ lhs: Term, _ rhs: Double) -> Constraint {
  return Expression(lhs) >= rhs
}

// MARK - Variable constraints

public func == (_ lhs: Variable, _ rhs: Expression) -> Constraint {
  return rhs == lhs
}

public func == (_ lhs: Variable, _ rhs: Term) -> Constraint {
  return rhs == lhs
}

public func == (_ lhs: Variable, _ rhs: Variable) -> Constraint {
  return Term(lhs) == rhs
}

public func == (_ lhs: Variable, _ rhs: Double) -> Constraint {
  return Term(lhs) == rhs
}

public func <= (_ lhs: Variable, _ rhs: Expression) -> Constraint {
  return rhs >= lhs
}

public func <= (_ lhs: Variable, _ rhs: Term) -> Constraint {
  return rhs >= lhs
}

public func <= (_ lhs: Variable, _ rhs: Variable) -> Constraint {
  return Term(lhs) <= rhs
}

public func <= (_ lhs: Variable, _ rhs: Double) -> Constraint {
  return Term(lhs) <= rhs
}

public func >= (_ lhs: Variable, _ rhs: Expression) -> Constraint {
  return rhs <= lhs
}

public func >= (_ lhs: Variable, _ rhs: Term) -> Constraint {
  return rhs <= lhs
}

public func >= (_ lhs: Variable, _ rhs: Variable) -> Constraint {
  return Term(lhs) >= rhs
}

public func >= (_ lhs: Variable, _ rhs: Double) -> Constraint {
  return Term(lhs) >= rhs
}

// MARK - double constraints

public func == (_ lhs: Double, _ rhs: Expression) -> Constraint {
  return rhs == lhs
}

public func == (_ lhs: Double, _ rhs: Term) -> Constraint {
  return rhs == lhs
}

public func == (_ lhs: Double, _ rhs: Variable) -> Constraint {
  return rhs == lhs
}

public func <= (_ lhs: Double, _ rhs: Expression) -> Constraint {
  return rhs >= lhs
}

public func <= (_ lhs: Double, _ rhs: Term) -> Constraint {
  return rhs >= lhs
}

public func <= (_ lhs: Double, _ rhs: Variable) -> Constraint {
  return rhs >= lhs
}

public func >= (_ lhs: Double, _ rhs: Expression) -> Constraint {
  return rhs <= lhs
}

public func >= (_ lhs: Double, _ rhs: Term) -> Constraint {
  return rhs <= lhs
}

public func >= (_ lhs: Double, _ rhs: Variable) -> Constraint {
  return rhs <= lhs
}

// MARK - constraint strength modifiers

@available(*, deprecated, message: "explicitly pass strength when adding the constraint")
public func | (_ lhs: Constraint, _ rhs: Strength) -> Constraint {
  return Constraint(lhs, rhs)
}

@available(*, deprecated, message: "explicitly pass strength when adding the constraint")
public func | (_ lhs: Strength, _ rhs: Constraint) -> Constraint {
  return Constraint(rhs, lhs)
}

