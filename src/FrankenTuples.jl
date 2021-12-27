module FrankenTuples

export FrankenTuple, ftuple, @ftuple, ftcall

"""
    FrankenTuple{T<:Tuple, names, NT<:Tuple}

A `FrankenTuple` contains a `Tuple` of type `T` and a `NamedTuple` with names `names`
and types `NT`.
It acts like a cross between the two, like a partially-named tuple.

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
struct FrankenTuple{T<:Tuple,names,NT<:Tuple}
    t::T
    nt::NamedTuple{names,NT}

    FrankenTuple{T,names,NT}(t, nt) where {T<:Tuple,names,NT<:Tuple} = new{T,names,NT}(t, nt)
    FrankenTuple{T}(t::Tuple) where {T<:Tuple} = new{T,(),Tuple{}}(t, NamedTuple())
    FrankenTuple{T,names,NT}(nt::NamedTuple) where {T<:Tuple,names,NT<:Tuple} =
        new{T,names,NT}((), nt)
    FrankenTuple{T,names,NT}(ft::FrankenTuple) where {T<:Tuple,names,NT<:Tuple} =
        new{T,names,NT}(convert(T, getfield(ft, :t)),
                        convert(NamedTuple{names,NT}, getfield(ft, :nt)))
end

FrankenTuple(t::T, nt::NamedTuple{names,NT}) where {T<:Tuple,names,NT<:Tuple} =
    FrankenTuple{T,names,NT}(t, nt)
FrankenTuple() = FrankenTuple{Tuple{},(),Tuple{}}((), NamedTuple())

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
Base.show(io::IO, ft::FrankenTuple{Tuple{},(),Tuple{}}) =
    print(io, "FrankenTuple()")

Base.convert(::Type{FrankenTuple{T,names,NT}}, t::Tuple) where {T<:Tuple,names,NT<:Tuple} =
    FrankenTuple{T,names,NT}(convert(T, t), NamedTuple())
Base.convert(::Type{FrankenTuple{T,names,NT}}, nt::NamedTuple) where {T<:Tuple,names,NT<:Tuple} =
    FrankenTuple{T,names,NT}((), convert(NamedTuple{names,NT}, nt))

"""
    isempty(ft::FrankenTuple)

Determine whether the given `FrankenTuple` is empty, i.e. has at least 1 element.
"""
Base.isempty(ft::FrankenTuple) = false
Base.isempty(ft::FrankenTuple{Tuple{},(),Tuple{}}) = true

"""
    length(ft::FrankenTuple)

Compute the number of elements in `ft`.
"""
Base.length(ft::FrankenTuple) = length(Tuple(ft)) + length(NamedTuple(ft))
Base.length(ft::FrankenTuple{Tuple{},(),Tuple{}}) = 0
Base.length(ft::FrankenTuple{<:Tuple,(),Tuple{}}) = length(Tuple(ft))
Base.length(ft::FrankenTuple{Tuple{},names}) where {names} = length(names)

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
Base.first(ft::FrankenTuple{Tuple{},(),Tuple{}}) =
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
_tail(t::Tuple{}, nt::NamedTuple{names,<:Tuple}) where {names} =
    FrankenTuple(t, NamedTuple{Base.tail(names)}(nt))
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
Base.keys(ft::FrankenTuple{Tuple{},(),Tuple{}}) = ()
Base.keys(ft::FrankenTuple{Tuple{},N,<:Tuple}) where {N} = N
Base.keys(ft::FrankenTuple{<:Tuple,(),Tuple{}}) = keys(Tuple(ft))

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
Base.values(ft::FrankenTuple{Tuple{},(),Tuple{}}) = ()
Base.values(ft::FrankenTuple{Tuple{},names,<:Tuple}) where {names} = values(NamedTuple(ft))
Base.values(ft::FrankenTuple{<:Tuple,(),Tuple{}}) = Tuple(ft)

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
This is the immediate supertype of the elements in `ft` if they are not homogeneously typed.

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
Base.eltype(::Type{FrankenTuple{T,names,V}}) where {T<:Tuple,names,V<:Tuple} =
    Base.promote_typejoin(eltype(T), eltype(V))

"""
    empty(ft::FrankenTuple)

Construct an empty `FrankenTuple`.
"""
Base.empty(@nospecialize ft::FrankenTuple) = FrankenTuple()

if VERSION < v"1.2.0-DEV.217"
    function Base.hasmethod(@nospecialize(f),
                            ::Type{FrankenTuple{T,names,NT}};
                            world=typemax(UInt)) where {T,names,NT}
        hasmethod(f, T; world=world) || return false
        m = which(f, T)
        kws = Base.kwarg_decl(m, Core.kwftype(typeof(f)))
        for kw in kws
            endswith(String(kw), "...") && return true
        end
        issubset(names, kws)
    end

else
    function Base.hasmethod(@nospecialize(f),
                            ::Type{FrankenTuple{T,names,NT}};
                            world=typemax(UInt)) where {T,names,NT}
        hasmethod(f, T, names; world=world)
    end
end

function Base.hasmethod(@nospecialize(f),
                        ::Type{FrankenTuple{T,(),Tuple{}}};
                        world=typemax(UInt)) where {T}
    hasmethod(f, T; world=world)
end

function Base.hasmethod(@nospecialize(f),
                        ::Type{FrankenTuple{T,names}};
                        world=typemax(UInt)) where {T,names}
    NT = Tuple{Iterators.repeated(Any, length(names))...}
    hasmethod(f, FrankenTuple{T,names,NT}; world=world)
end

"""
    hasmethod(f, ft::Type{<:FrankenTuple})

Determine whether the function `f` has a method with positional argument types matching
those in the unnamed portion of `ft` and with keyword arguments named in accordance with
those in the named portion of `ft`.

Note that the types in the named portion of `ft` do not factor into determining the
existence of a matching method because keyword arguments to not participate in dispatch.
Similarly, calling `hasmethod` with a `FrankenTuple` with an empty named portion will
still return `true` if the positional arguments match, even if `f` only has methods that
accept keyword arguments.
This ensures agreement with the behavior of `hasmethod` on `Tuple`s.

More generally, the names in the `FrankenTuple` must be a subset of the keyword argument
names in the matching method, _except_ when the method accepts a variable number of
keyword arguments (e.g. `kwargs...`).
In that case, the names in the method must be a subset of the `FrankenTuple`'s names.

# Examples
```jldoctest
julia> f(x::Int; y=3, z=4) = x + y + z;

julia> hasmethod(f, FrankenTuple{Tuple{Int},(:y,)})
true

julia> hasmethod(f, FrankenTuple{Tuple{Int},(:a,)}) # no keyword `a`
false

julia> g(; a, b, kwargs...) = +(a, b, kwargs...);

julia> hasmethod(g, FrankenTuple{Tuple{},(:a,:b,:c,:d)}) # g accepts arbitrarily many kwargs
true
```
"""
Base.hasmethod(::Any, ::Type{<:FrankenTuple})

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
function ftuple(args...; kwargs...)
    @static if VERSION < v"1.7.0-DEV.1017"
        nt = kwargs.data
    else
        # NOTE: We don't use this unconditionally because the `NamedTuple` constructor
        # method that accepts arbitrary key-value iterators requires 1.6.0-DEV.877
        nt = NamedTuple(kwargs)
    end
    FrankenTuple(args, nt)
end

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

# XXX: I'm not convinced that I like this or think it's useful in any way, but it's cute
"""
    ftcall(f::Function, ft::FrankenTuple)

Call the function `f` using the unnamed portion of `ft` as its positional arguments and
the named portion of `ft` as its keyword arguments.

# Examples
```jldoctest
julia> ftcall(mapreduce, ftuple(abs2, -, 1:4; init=0))
-30
```
"""
ftcall(f, ft::FrankenTuple) = f(Tuple(ft)...; NamedTuple(ft)...)
ftcall(f, ft::FrankenTuple{Tuple{},(),Tuple{}}) = f()

end # module
