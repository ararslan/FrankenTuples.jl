# FrankenTuples.jl

[![Build status](https://github.com/ararslan/FrankenTuples.jl/workflows/CI/badge.svg)](https://github.com/ararslan/FrankenTuples.jl/actions?query=workflow%3ACI+branch%3Amain)
[![codecov](https://codecov.io/gh/ararslan/FrankenTuples.jl/branch/main/graph/badge.svg?token=G47EaAAqKi)](https://codecov.io/gh/ararslan/FrankenTuples.jl)
[![][docs-latest-img]][docs-latest-url]

This package defines a type, `FrankenTuple`, which is like a cross between a `Tuple` and a
`NamedTuple`; it contains both positional and named elements.

> _Accursed creator! Why did you form a monster so hideous that even you turned from me in disgust?_

A function call has the form `f(args...; kwargs...)`.
Take away the function, and you get `(args...; kwargs...)`, a tuple with both positional
and named elements.
No one Base type currently models this, so `FrankenTuple` was created as an experiment to
see if and when this precise structure could be useful.

[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-latest-url]: http://ararslan.github.io/FrankenTuples.jl/latest/
