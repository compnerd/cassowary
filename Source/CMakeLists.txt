
add_library(cassowary
  Constraint.swift
  Errors.swift
  Expression.swift
  Row.swift
  Solver.swift
  Strength.swift
  Symbol.swift
  Symbolics.swift
  Term.swift
  Variable.swift)
set_target_properties(cassowary PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY})

