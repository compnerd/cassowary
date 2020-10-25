/*
 * Copyright © 2019 Saleem Abdulrasool <compnerd@compnerd.org>.
 * All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

public extension Symbol {
  enum `Type` {
  case invalid
  case external
  case slack
  case error
  case dummy
  }
}

public struct Symbol {
  public typealias ID = UInt64

  public let id: ID
  public let type: `Type`

  public init(_ type: `Type`, _ id: ID) {
    self.id = id
    self.type = type
  }
}

extension Symbol {
  static let invalid: Symbol = Symbol(.invalid, 0)
}

extension Symbol : Comparable {
  public static func == (lhs: Symbol, rhs: Symbol) -> Bool {
    return lhs.id == rhs.id
  }

  public static func < (lhs: Symbol, rhs: Symbol) -> Bool {
    return lhs.id < rhs.id
  }
}

extension Symbol : Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(type)
  }
}
extension Symbol : CustomStringConvertible {
  public var description: String {
    switch type {
    case .invalid: return "i\(id)"
    case .external: return "v\(id)"
    case .slack: return "s\(id)"
    case .error: return "e\(id)"
    case .dummy: return "d\(id)"
    }
  }
}

