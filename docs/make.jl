using Documenter, AwkwardArray

makedocs(;
    modules=[AwkwardArray],
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        assets=String["img/logo-300px.ico"],
    ),
    pages=[
        "Introduction" => "index.md",
        "Example Usage" => "exampleusage.md",
        "API" => Any[
            "Types" => "types.md",
            "Functions" => "functions.md",
            "Indexing" => "indexing.md",
            hide("Internals" => "internals.md"),
        ],
        "Reference Guide" => "api.md",
        "LICENSE" => "LICENSE.md",
    ],
    repo="https://github.com/JuliaHEP/AwkwardArray.jl/blob/{commit}{path}#L{line}",
    sitename="AwkwardArray.jl",
    authors="Jim Pivarski, Jerry Ling, and contributors",
)

deploydocs(;
    repo="github.com/JuliaHEP/AwkwardArray.jl",
    push_preview=true
)
