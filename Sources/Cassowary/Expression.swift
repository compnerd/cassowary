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

