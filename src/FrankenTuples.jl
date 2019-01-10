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

Base.Tuple(ft::FrankenTuple) = getfield(ft, :t)
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

Base.isempty(ft::FrankenTuple{Tuple{},NamedTuple{(),Tuple{}}}) = true
Base.isempty(ft::FrankenTuple) = false

Base.length(ft::FrankenTuple{Tuple{},NamedTuple{(),Tuple{}}}) = 0
Base.length(ft::FrankenTuple{<:Tuple,NamedTuple{(),Tuple{}}}) = length(Tuple(ft))
Base.length(ft::FrankenTuple{Tuple{},<:NamedTuple}) = length(NamedTuple(ft))
Base.length(ft::FrankenTuple) = length(Tuple(ft)) + length(NamedTuple(ft))

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
