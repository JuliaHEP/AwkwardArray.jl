# AwkwardArray

[![Build Status](https://github.com/jpivarski/AwkwardArray.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jpivarski/AwkwardArray.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/jpivarski/AwkwardArray.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/jpivarski/AwkwardArray.jl)

Julia-based Awkward Arrays are only layouts, no `ak.Array` wrapper. `PrimitiveArray` (renamed from `NumpyArray`) and `ListOffsetArray` implemented so far.

The buffers that the layouts wrap can be any `AbstractArray`, and we are careful to count between `firstindex` and `lastindex`, rather than assume `1` and `length`.

Index values in buffers are 0-indexed so that they can be zero-copy shared with Python.

Since Julia has penalty-free imperative iteration, layouts and LayoutBuilders are unified in the same interface.

Example:

```julia
julia> using AwkwardArray
[ Info: Precompiling AwkwardArray [7d259134-7f60-4bf1-aa00-7452e11bde56]

julia> layout = AwkwardArray.ListOffsetArray{
           AwkwardArray.Index64, AwkwardArray.PrimitiveArray{Float64}
       }()
0-element AwkwardArray.ListOffsetArray{Vector{Int64}, AwkwardArray.PrimitiveArray{Float64, Vector{Float64}}}

julia> sublayout = layout.content
0-element AwkwardArray.PrimitiveArray{Float64, Vector{Float64}}

julia> AwkwardArray.push!(sublayout, 1.1);

julia> AwkwardArray.push!(sublayout, 2.2);

julia> AwkwardArray.push!(sublayout, 3.3);

julia> AwkwardArray.end_list!(layout);

julia> AwkwardArray.end_list!(layout);

julia> AwkwardArray.push!(sublayout, 4.4);

julia> AwkwardArray.push!(sublayout, 5.5);

julia> AwkwardArray.end_list!(layout);

julia> length(layout)
3

julia> layout[1]
3-element AwkwardArray.PrimitiveArray{Float64, Vector{Float64}}:
 1.1
 2.2
 3.3

julia> layout[2]
0-element AwkwardArray.PrimitiveArray{Float64, Vector{Float64}}

julia> layout[3]
2-element AwkwardArray.PrimitiveArray{Float64, Vector{Float64}}:
 4.4
 5.5

julia> layout[1][3]
3.3

julia> layout == AwkwardArray.ListOffsetArray(
           [0, 3, 3, 5],
           AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
       )
true

julia> for x in layout
           print("[ ")
           for y in x
               print(y, " ")
           end
           print("] ")
       end
[ 1.1 2.2 3.3 ] [ ] [ 4.4 5.5 ] 
```
