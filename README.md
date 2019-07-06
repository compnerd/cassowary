# cassowary

This is a Swift implementation of the cassowary<sup id="a1">[1](#f1)</sup>
simplex solver inspired by the C++ implementation, Kiwi<sup id="a2">[2](#f2)</sup>.

## Constraints

Cassowary supports linear equations and non-strict inequalities.  Additionally,
a strength may be associated with each constraint in the system, constrolling
its importance to the overall solution to the system.

### Defining Variables and Constraints

Variables are the values which the solver is trying to resolve.  These
correspond to the `Variable` type in the implementation.  The variables can be
used to create the expressions which form constraints of the system.  These must
be added to an instance of the solver.

```Swift
import cassowary

let simplex: Solver = Solver()

let x_l: Variable = Variable("x_l")
let x_r: Variable = Variable("x_r")
let x_m: Variable = Variable("x_m")

simplex.add(constraint: 2.0 * x_m == x_l + x_r)
simplex.add(constraint: x_l + 10.0 <= x_r)
simplex.add(constraint: x_l >= -10.0)
simplex.add(constraint: x_r <= 100.0)
```

This creates a system with three variables (x<sub>l</sub>, x<sub>r</sub>,
x<sub>m</sub>) representings points on a line segment.  x<sub>m</sub> is
constrained to the midpoint between x<sub>l</sub> and x<sub>r</sub>,
x<sub>l</sub> is constrained to be at least 10 to the left of x<sub>r</sub>, and
all variables must lie in the range [-10, 100].  All constraints must be
satisfied and are considered as `required` by the cassowary algorithm.

**NOTE** The same constraint in the same form cannot be added to the solver
multiply.  Redundant constraints, as per cassowary, are supported.  That is, the
following set of constraints can be added to the solver:

```
x     == 10
x + y == 30
    y == 20
```

### Managing Constraint Strength

Cassowary supports constraints which are not required but are handled as
best-effort.  Such a constraint is modelled as having a _strength_ other than
`required`.  The constraints are considered in order of the value of their
strengths.  Three standard strengths are defined by default:
1. `strong`
1. `medium`
1. `weak`

We can add a constraint to our previous example to place x<sub>m</sub> at 50 by
adding a new `weak` constraint:

```Swift
simplex.add(constraint: (x_m == 50.0) | Strength.weak)
```

### Edit Variables

The system described thus far has been static.  In order to find solutions for
particular value of x<sub>m</sub>, Cassowary provides the concept of _edit
variables_ which allows you to suggest values for the variable before evaluating
the system.  These variables can have any strength other than `required`.

Continuing our example, we could make x<sub>m</sub> editable and suggest a value
of `60` for it.

```Swift
simplex.add(variable: x_m, .strong)
simplex.suggest(value: 60.0, for: x_m)
```

### Solving and Updating Variables

This implementation solves the system each time a constraint is added or
removed, or when a new value is suggested for an edit variable.  However, the
variable values are not updated automatically and you must request the solver to
update the values.

```Swift
simplex.suggest(value: 90, for: x_m)
simplex.update()
```

#
<b name="f1">1</b> https://constraints.cs.washington.edu/solvers/cassowary-tochi.pdf [↩](#a1)<br/>
<b name="f2">2</b> https://github.com/nucleic/kiwi [↩](#a2)

