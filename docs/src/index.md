```@meta
DocTestSetup = :(using FrankenTuples)
CurrentModule = FrankenTuples
```

# FrankenTuples.jl

The FrankenTuples package defines a type, `FrankenTuple`, which is a creature not unlike
Frankenstein's monster.
It is comprised of both a `Tuple` and a `NamedTuple` to facilitate situations in which
some but not all elements of a tuple are named, e.g. `(1, 2; a=3, b=4)`, and thus acts
like a cross between the two.

## Type and Constructors

```@docs
FrankenTuples.FrankenTuple
FrankenTuples.ftuple
FrankenTuples.@ftuple
```

## API

`FrankenTuple`s adhere as closely as makes sense to the API for `Tuple`s and `NamedTuple`s.

```@docs
Base.Tuple
Base.NamedTuple
Base.length
Base.isempty
Base.iterate
Base.keys
Base.values
Base.pairs
Base.getindex
Base.firstindex
Base.lastindex
Base.first
Base.tail
Base.empty
Base.eltype
```
