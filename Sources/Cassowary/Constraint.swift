// Copyright © 2019 Saleem Abdulrasool <compnerd@compnerd.org>.
// SPDX-License-Identifier: BSD-3-Clause

public extension Constraint {
  enum Relationship {
  case le
  case ge
  case eq
  }
}

/// Describes a constraint over variables in the system.
public final class Constraint {
  /// The expression that is constrained.
  public let expression: Expression

  /// The relationship between the expression and the constant.
  public let operation: Constraint.Relationship

  /// The strength of the constraint.
  public let strength: Strength

  public init(_ expression: Expression, _ operation: Constraint.Relationship,
              _ strength: Strength = .required) {
    self.expression = reduce(expression)
    self.operation = operation
    self.strength = Strength.clip(strength)
  }

  public init(_ constraint: Constraint, _ strength: Strength) {
    self.expression = constraint.expression
    self.operation = constraint.operation
    self.strength = Strength.clip(strength)
  }
}

// MARK: - Hashable

extension Constraint: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(expression)
    hasher.combine(operation)
    hasher.combine(strength)
  }
}

// MARK: - Equatable

extension Constraint: Equatable {
  public static func == (lhs: Constraint, rhs: Constraint) -> Bool {
    return lhs.expression == rhs.expression &&
           lhs.operation == rhs.operation &&
           lhs.strength == rhs.strength
  }
}

// MARK: - CustomStringConvertible

extension Constraint: CustomStringConvertible {
  public var description: String {
    var value: String = expression.terms.reduce("") {
      $0 + "\($1.coefficient) * \($1.variable.name) + "
    }
    value += String(describing: expression.constant)
    switch operation {
    case .le: value += " <= 0 "
    case .ge: value += " >= 0 "
    case .eq: value += " == 0 "
    }
    value += " | strength = \(strength)"
    return value
  }
}
