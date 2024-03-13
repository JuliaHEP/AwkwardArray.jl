# Use
#
#     DOCUMENTER_DEBUG=true julia --color=yes make.jl local [nonstrict] [fixdoctests]
#
# for local builds.
using Documenter, AwkwardArray

# Doctest setup
DocMeta.setdocmeta!(
    AwkwardArray,
    :DocTestSetup,
    :(using AwkwardArray);
    recursive=true,
)
 
makedocs(
    sitename = "AwkwardArray",
    modules = [AwkwardArray],
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        canonical = "https://JuliaHEP.github.io/AwkwardArray.jl/stable/"
    ),
    pages = [
        "Home" => "index.md",
        "API" => "api.md",
        "LICENSE" => "LICENSE.md",
    ],
    doctest = ("fixdoctests" in ARGS) ? :fix : true,
    linkcheck = !("nonstrict" in ARGS),
)

deploydocs(
    repo = "github.com/JuliaHEP/AwkwardArray.jl",
    forcepush = true,
    push_preview = true,
)

