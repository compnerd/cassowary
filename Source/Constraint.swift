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

public extension Constraint {
  enum Relationship {
  case le
  case ge
  case eq
  }
}

public class Constraint {
  public let expression: Expression
  public let operation: Constraint.Relationship
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

extension Constraint : Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(expression)
    hasher.combine(operation)
    hasher.combine(strength)
  }
}

extension Constraint : Equatable {
  public static func == (lhs: Constraint, rhs: Constraint) -> Bool {
    return lhs.expression == rhs.expression &&
           lhs.operation == rhs.operation &&
           lhs.strength == rhs.strength
  }
}

extension Constraint : CustomStringConvertible {
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

