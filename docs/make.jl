using Documenter, AwkwardArray

makedocs(;
    modules=[AwkwardArray],
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        assets=["assets/logo-300px.ico"],
    ),
    pages=[
        "Introduction" => "index.md",
        "Getting started" => "getting_started.md",
        "Converting Arrays" => "exampleusage.md",
        "API" => Any[
            "Types" => "types.md",
            "Functions" => "functions.md",
            hide("Indexing" => "indexing.md"),
            hide("Internals" => "internals.md"),
        ],
        hide("Reference Guide" => "api.md"),
        hide("HowTo" => "howto.md"),
        "LICENSE" => "LICENSE.md",
    ],
    repo="https://github.com/JuliaHEP/AwkwardArray.jl/blob/{commit}{path}#L{line}",
    sitename="for Julia!",
    authors="Jim Pivarski, Jerry Ling, and contributors",
)

deploydocs(;
    repo = "github.com/JuliaHEP/AwkwardArray.jl",
    branch = "gh-pages",
    push_preview=true,
    deploy_config = Documenter.GitHubActions(),
)

