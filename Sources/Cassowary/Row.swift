// Copyright © 2019 Saleem Abdulrasool <compnerd@compnerd.org>.
// SPDX-License-Identifier: BSD-3-Clause

@_implementationOnly
import OrderedCollections

internal final class Row {
  // Must be in insertion order
  public private(set) var cells: OrderedDictionary<Symbol, Double> = [:]
  public private(set) var constant: Double

  public init() {
    self.constant = 0.0
  }

  public init(_ constant: Double) {
    self.constant = constant
  }

  public init(copy rhs: Row) {
    self.cells = rhs.cells
    self.constant = rhs.constant
  }

  /// Add a constant value to the row constant.
  ///
  /// The new value of the constant is returned.
  public func add(_ value: Double) -> Double {
    constant += value
    return self.constant
  }

  /// Insert a symbol into the row with a given coefficient.
  ///
  /// If the symbol already exists in the row, the coefficient will be added to
  /// the existing coefficient.  If the resulting coefficient is zero, the
  /// symbol will be removed from the row.
  public func insert(symbol: Symbol, _ coefficient: Double = 1.0) {
    cells[symbol] = cells[symbol, default: 0.0] + coefficient
    if cells[symbol]! ~= 0.0 {
      cells.removeValue(forKey: symbol)
    }
  }

  /// Insert a row into this row with a given coefficient.
  ///
  /// The constant and the cells of the inserted row will be multiplied by the
  /// coefficient and be added to this row.  Any cell with a resulting
  /// coefficient of zero will be removed from the row.
  public func insert(row: Row, _ coefficient: Double = 1.0) {
    constant = constant + (row.constant * coefficient)

    for (r, c) in row.cells {
      cells[r] = cells[r, default: 0.0] + (c * coefficient)
      if cells[r]! ~= 0.0 {
        cells.removeValue(forKey: r)
      }
    }
  }

  /// Remove the given symbol from the row.
  public func remove(_ symbol: Symbol) {
    cells.removeValue(forKey: symbol)
  }

  /// Invert the sign of the constant and all cells in the row.
  public func invert() {
    constant = -1 * constant
    cells = cells.mapValues { -1 * $0 }
  }

  /// Solve the row for the given symbol.
  ///
  /// This method assymes that the row is of the form ax + by + c = 0 and
  /// (assuming solve for x) will modify the row to represent the right hand
  /// side of the x = -b/a * y - c/a.  The target symbol will be removed from the
  /// row, and the constant and other clls wiill be multipied by the negative
  /// inverse of the target coefficient.
  ///
  /// The given symbol *must* exist in the row.
  public func solve(for symbol: Symbol) {
    let coefficient: Double = -1.0 / cells[symbol]!
    cells.removeValue(forKey: symbol)
    constant *= coefficient
    cells = cells.mapValues { $0 * coefficient }
  }

  /// Solve the row for the given symbols.
  ///
  /// This method assumes that he row is of the form x = by + c and will solve
  /// the row such that y = x/b - c/b.  The rhs symbol will be removed from the
  /// row, the lhs added, and the result divided by the negative inverse of the
  /// rhs coefficient.
  ///
  /// The lhs symbol *must not* exist in the row, and the rhs symbol *must*
  /// exist in the row.
  public func solve(for lhs: Symbol, and rhs: Symbol) {
    insert(symbol: lhs, -1.0)
    solve(for: rhs)
  }

  /// Get the coefficient for the given symbol
  ///
  /// If the symbol does not exist in the row, zero will be returned.
  public func coefficient(for symbol: Symbol) -> Double {
    return cells[symbol] ?? 0.0
  }

  /// Substitute a symbol with the data from another row.
  ///
  /// Given a row of the form ax + b and a substitution of the form x = 3y + c
  /// the row will be updated to reflect the expression 3ay + ac + b.
  ///
  /// If the symbol does not exist in the row, this is a no-op.
  public func substitute(symbol: Symbol, from row: Row) {
    if let coefficient = cells[symbol] {
      cells.removeValue(forKey: symbol)
      insert(row: row, coefficient)
    }
  }
}

// MARK: - CustomStringConvertible

extension Row: CustomStringConvertible {
  public var description: String {
    return cells.reduce("\(constant)") {
      return $0 + " + \($1.value) * \(String(describing: $1.key))"
    }
  }
}

