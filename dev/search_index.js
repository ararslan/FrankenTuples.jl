var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "FrankenTuples.jl",
    "title": "FrankenTuples.jl",
    "category": "page",
    "text": "DocTestSetup = :(using FrankenTuples)\nCurrentModule = FrankenTuples"
},

{
    "location": "#FrankenTuples.jl-1",
    "page": "FrankenTuples.jl",
    "title": "FrankenTuples.jl",
    "category": "section",
    "text": "The FrankenTuples package defines a type, FrankenTuple, which is a creature not unlike Frankenstein\'s monster. It is comprised of both a Tuple and a NamedTuple to facilitate situations in which some but not all elements of a tuple are named, e.g. (1, 2; a=3, b=4), and thus acts like a cross between the two."
},

{
    "location": "#FrankenTuples.FrankenTuple",
    "page": "FrankenTuples.jl",
    "title": "FrankenTuples.FrankenTuple",
    "category": "type",
    "text": "FrankenTuple{T<:Tuple, names, NT<:Tuple}\n\nA FrankenTuple contains a Tuple of type T and a NamedTuple with names names and types NT. It acts like a cross between the two, like a partially-named tuple.\n\nThe named portion of a FrankenTuple can be accessed using NamedTuple, and the unnamed portion can be accessed with Tuple.\n\nExamples\n\njulia> ft = FrankenTuple((1, 2), (a=1, b=2))\nFrankenTuple((1, 2), (a = 1, b = 2))\n\njulia> Tuple(ft)\n(1, 2)\n\njulia> NamedTuple(ft)\n(a = 1, b = 2)\n\n\n\n\n\n"
},

{
    "location": "#FrankenTuples.ftuple",
    "page": "FrankenTuples.jl",
    "title": "FrankenTuples.ftuple",
    "category": "function",
    "text": "ftuple(args...; kwargs...)\n\nConstruct a FrankenTuple from the given positional and keyword arguments.\n\nExamples\n\njulia> ftuple(1, 2)\nFrankenTuple((1, 2), NamedTuple())\n\njulia> ftuple(1, 2, a=3, b=4)\nFrankenTuple((1, 2), (a = 3, b = 4))\n\n\n\n\n\n"
},

{
    "location": "#FrankenTuples.@ftuple",
    "page": "FrankenTuples.jl",
    "title": "FrankenTuples.@ftuple",
    "category": "macro",
    "text": "@ftuple (x...; y...)\n@ftuple (a, x=t, b, y=u)\n\nConstruct a FrankenTuple from the given tuple expression, which can contain both positional and named elements. The tuple can be \"sectioned\" in the same manner as a function signature, with positional elements separated from the named elements by a semicolon, or positional and named elements can be intermixed, occurring in any order.\n\nExamples\n\njulia> @ftuple (1, 2; a=3, b=4)\nFrankenTuple((1, 2), (a = 3, b = 4))\n\njulia> @ftuple (1, a=3, 2, b=4)\nFrankenTuple((1, 2), (a = 3, b = 4))\n\n\n\n\n\n"
},

{
    "location": "#Type-and-Constructors-1",
    "page": "FrankenTuples.jl",
    "title": "Type and Constructors",
    "category": "section",
    "text": "FrankenTuples.FrankenTuple\nFrankenTuples.ftuple\nFrankenTuples.@ftuple"
},

{
    "location": "#Core.Tuple",
    "page": "FrankenTuples.jl",
    "title": "Core.Tuple",
    "category": "type",
    "text": "Tuple(ft::FrankenTuple)\n\nAccess the Tuple part of a FrankenTuple, i.e. the \"plain,\" unnamed portion.\n\n\n\n\n\n"
},

{
    "location": "#Core.NamedTuple",
    "page": "FrankenTuples.jl",
    "title": "Core.NamedTuple",
    "category": "type",
    "text": "NamedTuple(ft::FrankenTuple)\n\nAccess the NamedTuple part of a FrankenTuple, i.e. the named portion.\n\n\n\n\n\n"
},

{
    "location": "#Base.length",
    "page": "FrankenTuples.jl",
    "title": "Base.length",
    "category": "function",
    "text": "length(ft::FrankenTuple)\n\nCompute the number of elements in ft.\n\n\n\n\n\n"
},

{
    "location": "#Base.isempty",
    "page": "FrankenTuples.jl",
    "title": "Base.isempty",
    "category": "function",
    "text": "isempty(ft::FrankenTuple)\n\nDetermine whether the given FrankenTuple is empty, i.e. has at least 1 element.\n\n\n\n\n\n"
},

{
    "location": "#Base.iterate",
    "page": "FrankenTuples.jl",
    "title": "Base.iterate",
    "category": "function",
    "text": "iterate(ft::FrankenTuple[, state])\n\nIterate over ft. This yields the values of the unnamed section first, then the values of the named section.\n\nExamples\n\njulia> ft = @ftuple (1, a=3, 2, b=4)\nFrankenTuple((1, 2), (a = 3, b = 4))\n\njulia> collect(ft)\n4-element Array{Int64,1}:\n 1\n 2\n 3\n 4\n\n\n\n\n\n"
},

{
    "location": "#Base.keys",
    "page": "FrankenTuples.jl",
    "title": "Base.keys",
    "category": "function",
    "text": "keys(ft::FrankenTuple)\n\nGet the keys of the given FrankenTuple, i.e. the set of valid indices into ft. The unnamed section of ft has 1-based integer keys and the named section is keyed by name, given as Symbols.\n\nExamples\n\njulia> keys(ftuple(1, 2; a=3, b=4))\n(1, 2, :a, :b)\n\n\n\n\n\n"
},

{
    "location": "#Base.values",
    "page": "FrankenTuples.jl",
    "title": "Base.values",
    "category": "function",
    "text": "values(ft::FrankenTuple)\n\nGet the values of the given FrankenTuple in iteration order. The values for the unnamed section appear before that of the named section.\n\nExamples\n\njulia> values(ftuple(1, 2; a=3, b=4))\n(1, 2, 3, 4)\n\n\n\n\n\n"
},

{
    "location": "#Base.pairs",
    "page": "FrankenTuples.jl",
    "title": "Base.pairs",
    "category": "function",
    "text": "pairs(ft::FrankenTuple)\n\nConstruct a Pairs iterator that associates the keys of ft with its values.\n\nExamples\n\njulia> collect(pairs(ftuple(1, 2; a=3, b=4)))\n4-element Array{Pair{Any,Int64},1}:\n  1 => 1\n  2 => 2\n :a => 3\n :b => 4\n\n\n\n\n\n"
},

{
    "location": "#Base.getindex",
    "page": "FrankenTuples.jl",
    "title": "Base.getindex",
    "category": "function",
    "text": "getindex(ft::FrankenTuple, i)\n\nRetrieve the value of ft at the given index i. When i::Integer, this gets the value at index i in iteration order. When i::Symbol, this gets the value from the named section with name i. (getproperty can also be used for the Symbol case.)\n\nExamples\n\njulia> ftuple(1, 2; a=3, b=4)[3]\n3\n\njulia> ftuple(1, 2; a=3, b=4)[:a]\n3\n\n\n\n\n\n"
},

{
    "location": "#Base.firstindex",
    "page": "FrankenTuples.jl",
    "title": "Base.firstindex",
    "category": "function",
    "text": "firstindex(ft::FrankenTuple)\n\nRetrieve the first index of ft, which is always 1.\n\n\n\n\n\n"
},

{
    "location": "#Base.lastindex",
    "page": "FrankenTuples.jl",
    "title": "Base.lastindex",
    "category": "function",
    "text": "lastindex(ft::FrankenTuple)\n\nRetrieve the last index of ft, which is equivalent to its length.\n\n\n\n\n\n"
},

{
    "location": "#Base.first",
    "page": "FrankenTuples.jl",
    "title": "Base.first",
    "category": "function",
    "text": "first(ft::FrankenTuple)\n\nGet the first value in ft in iteration order. ft must be non-empty.\n\n\n\n\n\n"
},

{
    "location": "#Base.tail",
    "page": "FrankenTuples.jl",
    "title": "Base.tail",
    "category": "function",
    "text": "Base.tail(ft::FrankenTuple)\n\nReturn the tail portion of ft: a new FrankenTuple with the first element of ft removed. ft must be non-empty.\n\nExamples\n\njulia> Base.tail(ftuple(a=4, b=5))\nFrankenTuple((), (b = 5,))\n\n\n\n\n\n"
},

{
    "location": "#Base.empty",
    "page": "FrankenTuples.jl",
    "title": "Base.empty",
    "category": "function",
    "text": "empty(ft::FrankenTuple)\n\nConstruct an empty FrankenTuple.\n\n\n\n\n\n"
},

{
    "location": "#Base.eltype",
    "page": "FrankenTuples.jl",
    "title": "Base.eltype",
    "category": "function",
    "text": "eltype(ft::FrankenTuple)\n\nDetermine the element type of ft. This is the immedate supertype of the elements in ft if they are not homogeneously typed.\n\nExamples\n\njulia> eltype(ftuple(1, 2; a=3, b=4))\nInt64\n\njulia> eltype(ftuple(0x0, 1))\nInteger\n\njulia> eltype(ftuple(a=2.0, b=0x1))\nReal\n\njulia> eltype(ftuple())\nUnion{}\n\n\n\n\n\n"
},

{
    "location": "#API-1",
    "page": "FrankenTuples.jl",
    "title": "API",
    "category": "section",
    "text": "FrankenTuples adhere as closely as makes sense to the API for Tuples and NamedTuples.Base.Tuple\nBase.NamedTuple\nBase.length\nBase.isempty\nBase.iterate\nBase.keys\nBase.values\nBase.pairs\nBase.getindex\nBase.firstindex\nBase.lastindex\nBase.first\nBase.tail\nBase.empty\nBase.eltype"
},

{
    "location": "#Base.hasmethod",
    "page": "FrankenTuples.jl",
    "title": "Base.hasmethod",
    "category": "function",
    "text": "hasmethod(f::Function, ft::Type{<:FrankenTuple})\n\nDetermine whether the function f has a method with positional argument types matching those in the unnamed portion of ft and with keyword arguments named in accordance with those in the named portion of ft.\n\nNote that the types in the named portion of ft do not factor into determining the existence of a matching method because keyword arguments to not participate in dispatch. Similarly, calling hasmethod with a FrankenTuple with an empty named portion will still return true if the positional arguments match, even if f only has methods that accept keyword arguments. This ensures agreement with the behavior of hasmethod on Tuples.\n\nMore generally, the names in the FrankenTuple must be a subset of the keyword argument names in the matching method, except when the method accepts a variable number of keyword arguments (e.g. kwargs...). In that case, the names in the method must be a subset of the FrankenTuple\'s names.\n\nExamples\n\njulia> f(x::Int; y=3, z=4) = x + y + z;\n\njulia> hasmethod(f, FrankenTuple{Tuple{Int},(:y,)})\ntrue\n\njulia> hasmethod(f, FrankenTuple{Tuple{Int},(:a,)) # no keyword `a`\nfalse\n\njulia> g(; a, b, kwargs...) = +(a, b, kwargs...);\n\njulia> hasmethod(g, FrankenTuple{Tuple{},(:a,:b,:c,:d)}) # g accepts arbitrarily many kwargs\ntrue\n\n\n\n\n\n"
},

{
    "location": "#FrankenTuples.ftcall",
    "page": "FrankenTuples.jl",
    "title": "FrankenTuples.ftcall",
    "category": "function",
    "text": "ftcall(f::Function, ft::FrankenTuple)\n\nCall the function f using the unnamed portion of ft as its positional arguments and the named portion of ft as its keyword arguments.\n\nExamples\n\njulia> ftcall(mapreduce, ftuple(abs2, -, 1:4; init=0))\n-30\n\n\n\n\n\n"
},

{
    "location": "#Additional-Methods-1",
    "page": "FrankenTuples.jl",
    "title": "Additional Methods",
    "category": "section",
    "text": "These are some additional ways to use FrankenTuples. The most interesting of these is perhaps hasmethod, which permits looking for methods that have particular keyword arguments. This is not currently possible with the generic method in Base.Base.hasmethod\nFrankenTuples.ftcall"
},

]}
