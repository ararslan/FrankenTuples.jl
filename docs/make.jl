using Documenter
using FrankenTuples

makedocs(modules=[FrankenTuples],
         sitename="FrankenTuples.jl",
         authors="Alex Arslan",
         pages=["index.md"])

deploydocs(repo="github.com/ararslan/FrankenTuples.jl.git", target="build")
