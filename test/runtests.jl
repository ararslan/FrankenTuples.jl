using FrankenTuples
using Test

@testset "It's alive!" begin
    x = ftuple(1, 2, a=3, b=4)
    @test x == FrankenTuple((1, 2), (a=3, b=4))
    @test x == FrankenTuple(x)
    @test !isempty(x)
    @test length(x) == 4
    @test Tuple(x) == (1, 2)
    @test NamedTuple(x) == (a=3, b=4)
    @test sprint(show, x) == "FrankenTuple((1, 2), (a = 3, b = 4))"
    @test x == @ftuple (1, 2; a=3, b=4)
    @test x == @ftuple (1, a=3, b=4, 2)
    @test keys(x) == (1, 2, :a, :b)
    @test values(x) == (1, 2, 3, 4)
    @test eltype(x) == Int
    @test first(x) == 1
    @test Base.tail(x) == ftuple(2, a=3, b=4)

    y = FrankenTuple{Tuple{Float64,Float64},(:a,:b),Tuple{Float64,Float64}}(x)
    @test y == ftuple(1.0, 2.0, a=3.0, b=4.0)

    t = ftuple(1, 2)
    @test t == FrankenTuple((1, 2))
    @test length(t) == 2
    @test Tuple(t) == (1, 2)
    @test NamedTuple(t) == NamedTuple()
    @test t == convert(FrankenTuple{Tuple{Int,Int},(),Tuple{}}, (1, 2))
    @test sprint(show, t) == "FrankenTuple((1, 2), NamedTuple())"
    @test t == @ftuple (1, 2)
    @test keys(t) == keys(Tuple(t))
    @test values(t) == (1, 2)
    @test first(t) == 1
    @test Base.tail(t) == ftuple(2)

    nt = ftuple(a=3, b=4)
    @test nt == FrankenTuple((a=3, b=4))
    @test length(nt) == 2
    @test Tuple(nt) == ()
    @test NamedTuple(nt) == (a=3, b=4)
    @test nt == convert(FrankenTuple{Tuple{},(:a,:b),Tuple{Int,Int}}, (a=3, b=4))
    @test sprint(show, nt) == "FrankenTuple((), (a = 3, b = 4))"
    @test nt == @ftuple (a=3, b=4)
    @test keys(nt) == (:a, :b)
    @test values(nt) == (3, 4)
    @test first(nt) == 3
    @test Base.tail(nt) == ftuple(b=4)

    e = empty(x)
    @test e == FrankenTuple()
    @test isempty(e)
    @test length(e) == 0
    @test sprint(show, e) == "FrankenTuple()"
    @test e == @ftuple ()
    @test keys(e) == values(e) == ()
    @test_throws ArgumentError first(e)
    @test_throws ArgumentError Base.tail(e)

    @test eltype(ftuple(1, 2.0, a=3, b=4.0f0)) == Real
end

@testset "Indexing and iteration" begin
    x = ftuple(1, 2, a=3, b=4)
    @test x.a == x[:a] == 3
    @test x.b == x[:b] == 4
    for i = 1:4
        @test x[i] == i
    end
    for (i, t) in enumerate(x)
        @test t == i
    end
    @test collect(pairs(x)) == [1 => 1, 2 => 2, :a => 3, :b => 4]
    @test firstindex(x) == 1
    @test lastindex(x) == 4
end

@testset "☎" begin
    @test ftcall(sum, ftuple(abs2, [1 2; 3 4]; dims=2)) == reshape([5, 25], (2, 1))
    @test ftcall(string, ftuple()) == ""
    @test ftcall(+, ftuple(1, 2)) == 3
    @test ftcall((; k...)->sum(values(k)), ftuple(a=3.0, b=0x4)) == 7.0
end

f(x::Int; y=3) = x + y
g(; b, c, a) = a + b + c
h(x::String; a, kwargs...) = x * a

@testset "hasmethod" begin
    @test hasmethod(f, typeof(ftuple(1, y=2)))
    @test hasmethod(f, typeof(ftuple(1)))  # Agreement with using a plain Tuple
    @test !hasmethod(f, typeof(ftuple(1, a=3)))
    @test hasmethod(f, FrankenTuple{Tuple{Int},(:y,)})  # Omitting NamedTuple types
    @test hasmethod(g, typeof(ftuple(a=1, b=2, c=3)))
    @test hasmethod(g, typeof(ftuple(a=1, b=2)))
    @test !hasmethod(g, FrankenTuple{Tuple{},(:a,:b,:d)})
    @test hasmethod(g, FrankenTuple{Tuple{},(:a,:b,:c)})
    @test hasmethod(h, FrankenTuple{Tuple{String},(:a,:b,:c,:d)})
    @test !hasmethod(h, FrankenTuple{Tuple{Int},(:a,)})

    @test !hasmethod(f, FrankenTuple{Tuple{Int},(:y,)}, world=typemin(UInt))
end
