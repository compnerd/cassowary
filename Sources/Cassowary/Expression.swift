// Copyright © 2019 Saleem Abdulrasool <compnerd@compnerd.org>.
// SPDX-License-Identifier: BSD-3-Clause

public struct Expression {
  public let terms: [Term]
  public let constant: Double

  public var value: Double {
    return terms.reduce(constant, { $0 + $1.value })
  }

  public init(_ constant: Double = 0.0) {
    self.terms = []
    self.constant = constant
  }

  public init(_ term: Term, _ constant: Double = 0.0) {
    self.init([term], constant)
  }

  public init(_ terms: [Term], _ constant: Double = 0.0) {
    self.terms = terms
    self.constant = constant
  }
}

extension Expression : Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(terms)
    hasher.combine(constant)
  }
}

extension Expression : Equatable {
  public static func == (lhs: Expression, rhs: Expression) -> Bool {
    return lhs.terms == rhs.terms && lhs.constant == rhs.constant
  }
}

internal func reduce(_ expression: Expression) -> Expression {
  var vars: [Variable:Double] = [:]
  for term in expression.terms {
    vars[term.variable] = vars[term.variable, default: 0.0] + term.coefficient
  }
  return Expression(vars.map { Term($0, $1) }, expression.constant)
}

