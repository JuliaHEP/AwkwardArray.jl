## Converting to and from Julia objects

```julia
using AwkwardArray

AwkwardArray.to_vector(array)
4-element Vector{Vector{Float64}}:
 [1.1, 2.2, 3.3]
 [4.4]
 [5.5, 6.6]
 [7.7, 8.8, 9.9]

AwkwardArray.from_iter(AwkwardArray.to_vector(array))
4-element ListOffsetArray{Vector{Int64}, PrimitiveArray{Float64, Vector{Float64}, :default}, :default}:
 [1.1, 2.2, 3.3]
 [4.4]
 [5.5, 6.6]
 [7.7, 8.8, 9.9]
```
