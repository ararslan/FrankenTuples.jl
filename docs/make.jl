using Documenter
using FrankenTuples

makedocs(modules=[FrankenTuples],
         sitename="FrankenTuples.jl",
         authors="Alex Arslan",
         pages=["index.md"])

deploydocs(repo="github.com/invenia/Nabla.jl.git", target="build")
