// Copyright © 2019 Saleem Abdulrasool <compnerd@compnerd.org>.
// SPDX-License-Identifier: BSD-3-Clause

public final class Variable {
  public var name: String
  public var value: Double

  public init(_ name: String, _ value: Double = 0.0) {
    self.name = name
    self.value = value
  }
}

// MARK: - Hashable

extension Variable: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }
}

// MARK: - Equatable

extension Variable: Equatable {
  public static func == (lhs: Variable, rhs: Variable) -> Bool {
    return lhs.name == rhs.name && lhs.value == rhs.value
  }
}
