// Copyright © 2019 Saleem Abdulrasool <compnerd@compnerd.org>.
// SPDX-License-Identifier: BSD-3-Clause

/// The constraint cannot be satisfied.
public struct UnsatisfiableConstraint: Error {
  private let constraint: Constraint
  public init(_ constraint: Constraint) {
    self.constraint = constraint
  }
}

// MARK: - CustomStringConvertible

extension UnsatisfiableConstraint: CustomStringConvertible {
  public var description: String {
    return "unable to satisfy constraint: \(constraint)"
  }
}

/// The constraint is not currently in the system.
public struct UnknownConstraint: Error {
  private let constraint: Constraint
  public init(_ constraint: Constraint) {
    self.constraint = constraint
  }
}

// MARK: - CustomStringConvertible

extension UnknownConstraint: CustomStringConvertible {
  public var description: String {
    return "unknown constraint: \(constraint)"
  }
}

/// The constraint is already in the system.
public struct DuplicateConstraint: Error {
  private let constraint: Constraint
  public init(_ constraint: Constraint) {
    self.constraint = constraint
  }
}

// MARK: - CustomStringConvertible

extension DuplicateConstraint: CustomStringConvertible {
  public var description: String {
    return "duplicate constraint: \(constraint)"
  }
}

/// The edit variable is not in the system.
public struct UnknownEditVariable: Error {
  public init(_ variable: Variable) {
  }
}

/// The edit variable is already in the system.
public struct DuplicateEditVariable: Error {
  public init(_ variable: Variable) {
  }
}

/// The required strength is invalid.
public struct BadRequiredStrength: Error {
}

/// An internal solver error occurred.
internal struct InternalSolverError: Error {
  public init(_ message: String) {
  }
}
