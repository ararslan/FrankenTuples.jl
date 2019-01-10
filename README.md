# FrankenTuples.jl

[![Travis](https://travis-ci.org/ararslan/FrankenTuples.jl.svg?branch=master)](https://travis-ci.org/ararslan/FrankenTuples.jl)
[![Coveralls](https://coveralls.io/repos/github/ararslan/FrankenTuples.jl/badge.svg?branch=master)](https://coveralls.io/github/ararslan/FrankenTuples.jl?branch=master)

This package defines a type, `FrankenTuple`, which is like a cross between a `Tuple` and a
`NamedTuple`; it contains both positional and named elements.

> _Accursed creator! Why did you form a monster so hideous that even you turned from me in disgust?_

A function call has the form `f(args...; kwargs...)`.
Take away the function, and you get `(args...; kwargs...)`, a tuple with both positional
and named elements.
No one Base type currently models this, so `FrankenTuple` was created as an experiment to
see if and when this precise structure could be useful.
