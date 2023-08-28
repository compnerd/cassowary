// Copyright © 2019 Saleem Abdulrasool <compnerd@compnerd.org>.
// SPDX-License-Identifier: BSD-3-Clause

public final class Term {
  public let variable: Variable
  public let coefficient: Double

  public var value: Double {
    return self.coefficient * self.variable.value
  }

  public init(_ variable: Variable, _ coefficient: Double = 1.0) {
    self.variable = variable
    self.coefficient = coefficient
  }
}

// MARK: - Hashable

extension Term: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(variable)
    hasher.combine(coefficient)
  }
}

// MARK: - Equatable

extension Term: Equatable {
  public static func == (lhs: Term, rhs: Term) -> Bool {
    return lhs.variable == rhs.variable && lhs.coefficient == rhs.coefficient
  }
}
