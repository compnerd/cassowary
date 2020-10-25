/*
 * Copyright © 2019 Saleem Abdulrasool <compnerd@compnerd.org>.
 * All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

public typealias Strength = Double

public extension Strength {
  init(_ a: Double, _ b: Double, _ c: Double, _ w: Double = 1.0) {
    self = max(0.0, min(1000.0, a * w)) * 1000000.0
         + max(0.0, min(1000.0, b * w)) * 1000.0
         + max(0.0, min(1000.0, c * w)) * 1.0
  }
}

public extension Strength {
  static let required: Strength = Strength(1000.0, 1000.0, 1000.0)
  static let strong: Strength = Strength(1.0, 0.0, 0.0)
  static let medium: Strength = Strength(0.0, 1.0, 0.0)
  static let weak: Strength = Strength(0.0, 0.0, 1.0)
}

internal extension Strength {
  static func clip(_ value: Strength) -> Strength {
    return max(0.0, min(Strength.required, value))
  }
}

