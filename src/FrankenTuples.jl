module FrankenTuples

export FrankenTuple, ftuple, @ftuple

"""
    FrankenTuple{T,NT}

A `FrankenTuple` contains a `Tuple` (of type `T`) and a `NamedTuple` (of type `NT`), and
acts like a cross between the two, like a partially-named tuple.

The named portion of a `FrankenTuple` can be accessed using `NamedTuple`, and the unnamed
portion can be accessed with `Tuple`.

# Examples
```jldoctest
julia> ft = FrankenTuple((1, 2), (a=1, b=2))
FrankenTuple((1, 2), (a = 1, b = 2))

julia> Tuple(ft)
(1, 2)

julia> NamedTuple(ft)
(a = 1, b = 2)
```
"""
struct FrankenTuple{T<:Tuple,NT<:NamedTuple}
    t::T
    nt::NT

    FrankenTuple{T,NT}(t, nt) where {T<:Tuple,NT<:NamedTuple} = new{T,NT}(t, nt)
    FrankenTuple{T}(t::Tuple) where {T<:Tuple} = new{T,NamedTuple{(),Tuple{}}}(t, NamedTuple())
    FrankenTuple{T,NT}(nt::NamedTuple) where {T<:Tuple,NT<:NamedTuple} = new{T,NT}((), nt)
    FrankenTuple{T,NT}(ft::FrankenTuple) where {T<:Tuple,NT<:NamedTuple} =
        new{T,NT}(convert(T, getfield(ft, :t)), convert(NT, getfield(ft, :nt)))
end

FrankenTuple(t::T, nt::NT) where {T<:Tuple,NT<:NamedTuple} = FrankenTuple{T,NT}(t, nt)
FrankenTuple() = FrankenTuple{Tuple{},NamedTuple{(),Tuple{}}}((), NamedTuple())

FrankenTuple(t::Tuple) = FrankenTuple(t, NamedTuple())
FrankenTuple(nt::NamedTuple) = FrankenTuple((), nt)

FrankenTuple(ft::FrankenTuple) = ft

"""
    Tuple(ft::FrankenTuple)

Access the `Tuple` part of a `FrankenTuple`, i.e. the "plain," unnamed portion.
"""
Base.Tuple(ft::FrankenTuple) = getfield(ft, :t)

"""
    NamedTuple(ft::FrankenTuple)

Access the `NamedTuple` part of a `FrankenTuple`, i.e. the named portion.
"""
Base.NamedTuple(ft::FrankenTuple) = getfield(ft, :nt)

function Base.show(io::IO, ft::FrankenTuple)
    print(io, "FrankenTuple(")
    show(io, Tuple(ft))
    print(io, ", ")
    show(io, NamedTuple(ft))
    print(io, ')')
    nothing
end
Base.show(io::IO, ft::FrankenTuple{Tuple{},NamedTuple{(),Tuple{}}}) =
    print(io, "FrankenTuple()")

Base.convert(::Type{FrankenTuple{T,NT}}, t::Tuple) where {T<:Tuple,NT<:NamedTuple} =
    FrankenTuple{T,NT}(convert(T, t), NamedTuple())
Base.convert(::Type{FrankenTuple{T,NT}}, nt::NamedTuple) where {T<:Tuple,NT<:NamedTuple} =
    FrankenTuple{T,NT}((), convert(NT, nt))

"""
    isempty(ft::FrankenTuple)

Determine whether the given `FrankenTuple` is empty, i.e. has at least 1 element.
"""
Base.isempty(ft::FrankenTuple) = false
Base.isempty(ft::FrankenTuple{Tuple{},NamedTuple{(),Tuple{}}}) = true

"""
    length(ft::FrankenTuple)

Compute the number of elements in `ft`.
"""
Base.length(ft::FrankenTuple) = length(Tuple(ft)) + length(NamedTuple(ft))
Base.length(ft::FrankenTuple{Tuple{},NamedTuple{(),Tuple{}}}) = 0
Base.length(ft::FrankenTuple{<:Tuple,NamedTuple{(),Tuple{}}}) = length(Tuple(ft))
Base.length(ft::FrankenTuple{Tuple{},<:NamedTuple}) = length(NamedTuple(ft))

"""
    getindex(ft::FrankenTuple, i)

Retrieve the value of `ft` at the given index `i`. When `i::Integer`, this gets the value
at index `i` in iteration order.
When `i::Symbol`, this gets the value from the named section with name `i`.
(`getproperty` can also be used for the `Symbol` case.)

# Examples
```jldoctest
julia> ftuple(1, 2; a=3, b=4)[3]
3

julia> ftuple(1, 2; a=3, b=4)[:a]
3
```
"""
function Base.getindex(ft::FrankenTuple, i::Integer)
    t = Tuple(ft)
    n = length(t)
    if i <= n
        getfield(t, i)
    else
        getfield(NamedTuple(ft), i - n)
    end
end
Base.getindex(ft::FrankenTuple, x::Symbol) = getfield(NamedTuple(ft), x)

Base.getproperty(ft::FrankenTuple, x::Symbol) = getfield(NamedTuple(ft), x)

"""
    firstindex(ft::FrankenTuple)

Retrieve the first index of `ft`, which is always 1.
"""
Base.firstindex(ft::FrankenTuple) = 1

"""
    lastindex(ft::FrankenTuple)

Retrieve the last index of `ft`, which is equivalent to its `length`.
"""
Base.lastindex(ft::FrankenTuple) = length(ft)

"""
    first(ft::FrankenTuple)

Get the first value in `ft` in iteration order.
`ft` must be non-empty.
"""
Base.first(ft::FrankenTuple) = @inbounds ft[1]
Base.first(ft::FrankenTuple{Tuple{},NamedTuple{(),Tuple{}}}) =
    throw(ArgumentError("FrankenTuple must be non-empty"))

"""
    Base.tail(ft::FrankenTuple)

Return the tail portion of `ft`: a new `FrankenTuple` with the first element of `ft`
removed.
`ft` must be non-empty.

# Examples
```jldoctest
julia> Base.tail(ftuple(a=4, b=5))
FrankenTuple((), (b = 5,))
```
"""
Base.tail(ft::FrankenTuple) = _tail(Tuple(ft), NamedTuple(ft))
# TODO: Should be able to get rid of the helper after VERSION >= v"1.1.0-DEV.553"
_tail(t::Tuple{}, nt::NamedTuple{(),Tuple{}}) =
    throw(ArgumentError("FrankenTuple must be non-empty"))
_tail(t::Tuple{}, nt::NamedTuple{N,<:Tuple}) where {N} =
    FrankenTuple(t, NamedTuple{Base.tail(N)}(nt))
_tail(t::Tuple, nt::NamedTuple) = FrankenTuple(Base.tail(t), nt)

"""
    iterate(ft::FrankenTuple[, state])

Iterate over `ft`.
This yields the values of the unnamed section first, then the values of the named section.

# Examples
```jldoctest
julia> ft = @ftuple (1, a=3, 2, b=4)
FrankenTuple((1, 2), (a = 3, b = 4))

julia> collect(ft)
4-element Array{Int64,1}:
 1
 2
 3
 4
```
"""
Base.iterate(ft::FrankenTuple, state...) =
    iterate(Iterators.flatten((Tuple(ft), NamedTuple(ft))), state...)

"""
    keys(ft::FrankenTuple)

Get the keys of the given `FrankenTuple`, i.e. the set of valid indices into `ft`.
The unnamed section of `ft` has 1-based integer keys and the named section is keyed by
name, given as `Symbol`s.

# Examples
```jldoctest
julia> keys(ftuple(1, 2; a=3, b=4))
(1, 2, :a, :b)
```
"""
Base.keys(ft::FrankenTuple) = (keys(Tuple(ft))..., keys(NamedTuple(ft))...)
Base.keys(ft::FrankenTuple{Tuple{},NamedTuple{(),Tuple{}}}) = ()
Base.keys(ft::FrankenTuple{Tuple{},NamedTuple{N,<:Tuple}}) where {N} = N
Base.keys(ft::FrankenTuple{<:Tuple,NamedTuple{(),Tuple{}}}) = keys(Tuple(ft))

"""
    values(ft::FrankenTuple)

Get the values of the given `FrankenTuple` in iteration order.
The values for the unnamed section appear before that of the named section.

# Examples
```jldoctest
julia> values(ftuple(1, 2; a=3, b=4))
(1, 2, 3, 4)
```
"""
Base.values(ft::FrankenTuple) = (Tuple(ft)..., NamedTuple(ft)...)
Base.values(ft::FrankenTuple{Tuple{},NamedTuple{(),Tuple{}}}) = ()
Base.values(ft::FrankenTuple{Tuple{},<:NamedTuple}) = values(NamedTuple(ft))
Base.values(ft::FrankenTuple{<:Tuple,NamedTuple{(),Tuple{}}}) = Tuple(ft)

"""
    pairs(ft::FrankenTuple)

Construct a `Pairs` iterator that associates the `keys` of `ft` with its `values`.

# Examples
```jldoctest
julia> collect(pairs(ftuple(1, 2; a=3, b=4)))
4-element Array{Pair{Any,Int64},1}:
  1 => 1
  2 => 2
 :a => 3
 :b => 4
```
"""
Base.pairs(ft::FrankenTuple) = Iterators.Pairs(ft, keys(ft))

"""
    eltype(ft::FrankenTuple)

Determine the element type of `ft`.
This is the immedate supertype of the elements in `ft` if they are not homogeneously typed.

# Examples
```jldoctest
julia> eltype(ftuple(1, 2; a=3, b=4))
Int64

julia> eltype(ftuple(0x0, 1))
Integer

julia> eltype(ftuple(a=2.0, b=0x1))
Real

julia> eltype(ftuple())
Union{}
```
"""
Base.eltype(::Type{FrankenTuple{T,NamedTuple{N,V}}}) where {T<:Tuple,N,V<:Tuple} =
    Base.promote_typejoin(eltype(T), eltype(V))

"""
    empty(ft::FrankenTuple)

Construct an empty `FrankenTuple`.
"""
Base.empty(@nospecialize ft::FrankenTuple) = FrankenTuple()

"""
    ftuple(args...; kwargs...)

Construct a [`FrankenTuple`](@ref) from the given positional and keyword arguments.

# Examples
```jldoctest
julia> ftuple(1, 2)
FrankenTuple((1, 2), NamedTuple())

julia> ftuple(1, 2, a=3, b=4)
FrankenTuple((1, 2), (a = 3, b = 4))
```
"""
ftuple(args...; kwargs...) = FrankenTuple(args, kwargs.data)

"""
    @ftuple (x...; y...)
    @ftuple (a, x=t, b, y=u)

Construct a [`FrankenTuple`](@ref) from the given tuple expression, which can contain
both positional and named elements. The tuple can be "sectioned" in the same manner as
a function signature, with positional elements separated from the named elements by a
semicolon, or positional and named elements can be intermixed, occurring in any order.

# Examples
```jldoctest
julia> @ftuple (1, 2; a=3, b=4)
FrankenTuple((1, 2), (a = 3, b = 4))

julia> @ftuple (1, a=3, 2, b=4)
FrankenTuple((1, 2), (a = 3, b = 4))
```
"""
macro ftuple(ex::Expr)
    ex.head === :tuple || throw(ArgumentError("@ftuple: expected tuple expression"))
    # ()
    if isempty(ex.args)
        t = Expr(:tuple)
        nt = Expr(:call, :NamedTuple)
    # (a, b; x=t, y=u)
    elseif ex.args[1] isa Expr && ex.args[1].head === :parameters
        t = Expr(:tuple)
        length(ex.args) > 1 && append!(t.args, ex.args[2:end])
        nt = Expr(:tuple)
        for kw in ex.args[1].args
            @assert kw isa Expr && kw.head === :kw
            push!(nt.args, Expr(:(=), esc(kw.args[1]), kw.args[2]))
        end
    # (a, x=t, b, y=u)
    else
        t = Expr(:tuple)
        nt = Expr(:tuple)
        for arg in ex.args
            if arg isa Expr && arg.head === :(=)
                push!(nt.args, esc(arg))
            else
                push!(t.args, arg)
            end
        end
        if nt == Expr(:tuple)
            # No named elements found
            nt = Expr(:call, :NamedTuple)
        end
    end
    :(FrankenTuple($t, $nt))
end

end # module
