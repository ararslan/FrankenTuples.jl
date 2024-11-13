using Documenter
using FrankenTuples

DocMeta.setdocmeta!(FrankenTuples, :DocTestSetup, :(using FrankenTuples); recursive=true)

makedocs(modules=[FrankenTuples],
         sitename="FrankenTuples.jl",
         authors="Alex Arslan",
         pages=["index.md"])

deploydocs(repo="github.com/ararslan/FrankenTuples.jl.git")
