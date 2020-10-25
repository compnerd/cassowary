/*
 * Copyright © 2019 Saleem Abdulrasool <compnerd@compnerd.org>.
 * All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

public struct UnsatisfiableConstraint : Error {
  private let constraint: Constraint
  public init(_ constraint: Constraint) {
    self.constraint = constraint
  }
}

extension UnsatisfiableConstraint : CustomStringConvertible {
  public var description: String {
    return "unable to satisfy constraint: \(constraint)"
  }
}

public struct UnknownConstraint : Error {
  private let constraint: Constraint
  public init(_ constraint: Constraint) {
    self.constraint = constraint
  }
}

extension UnknownConstraint : CustomStringConvertible {
  public var description: String {
    return "unknown constraint: \(constraint)"
  }
}

public struct DuplicateConstraint : Error {
  private let constraint: Constraint
  public init(_ constraint: Constraint) {
    self.constraint = constraint
  }
}

extension DuplicateConstraint : CustomStringConvertible {
  public var description: String {
    return "duplicate constraint: \(constraint)"
  }
}

public struct UnknownEditVariable : Error {
  public init(_ variable: Variable) {
  }
}

public struct DuplicateEditVariable : Error {
  public init(_ variable: Variable) {
  }
}

public struct BadRequiredStrength : Error {
}

internal struct InternalSolverError : Error {
  public init(_ message: String) {
  }
}


