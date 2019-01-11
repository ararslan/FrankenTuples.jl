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

    y = FrankenTuple{Tuple{Float64,Float64},NamedTuple{(:a,:b),Tuple{Float64,Float64}}}(x)
    @test y == ftuple(1.0, 2.0, a=3.0, b=4.0)

    t = ftuple(1, 2)
    @test t == FrankenTuple((1, 2))
    @test length(t) == 2
    @test Tuple(t) == (1, 2)
    @test NamedTuple(t) == NamedTuple()
    @test t == convert(FrankenTuple{Tuple{Int,Int},NamedTuple{(),Tuple{}}}, (1, 2))
    @test sprint(show, t) == "FrankenTuple((1, 2), NamedTuple())"
    @test t == @ftuple (1, 2)
    @test keys(t) == keys(Tuple(t))
    @test values(t) == (1, 2)

    nt = ftuple(a=3, b=4)
    @test nt == FrankenTuple((a=3, b=4))
    @test length(nt) == 2
    @test Tuple(nt) == ()
    @test NamedTuple(nt) == (a=3, b=4)
    @test nt == convert(FrankenTuple{Tuple{},NamedTuple{(:a,:b),Tuple{Int,Int}}}, (a=3, b=4))
    @test sprint(show, nt) == "FrankenTuple((), (a = 3, b = 4))"
    @test nt == @ftuple (a=3, b=4)
    @test keys(nt) == (:a, :b)
    @test values(nt) == (3, 4)

    e = ftuple()
    @test e == FrankenTuple()
    @test isempty(e)
    @test length(e) == 0
    @test sprint(show, e) == "FrankenTuple()"
    @test e == @ftuple ()
    @test keys(e) == values(e) == ()

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
end
