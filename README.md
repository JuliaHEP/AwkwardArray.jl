![](https://github.com/JuliaHEP/AwkwardArray.jl/blob/main/docs/img/logo-500px.png)

**for Julia!**

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliahep.github.io/AwkwardArray.jl/dev/)
[![Build Status](https://github.com/JuliaHEP/AwkwardArray.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaHEP/AwkwardArray.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![codecov](https://codecov.io/gh/JuliaHEP/AwkwardArray.jl/graph/badge.svg?token=eWHsBiyaPd)](https://codecov.io/gh/JuliaHEP/AwkwardArray.jl)

## Why?

[Awkward Array](https://github.com/scikit-hep/awkward) is a library for manipulating large-scale arrays of nested, variable-sized data in Python, using array-oriented idioms: like NumPy, but for any JSON-like data. In Python, using array-oriented idioms to avoid imperative for loops is necessary for fast computations. In Julia, imperative code is already fast, thanks to JIT-compilation, so you may be wondering why this package exists.

This package is a complete, one-to-one implementation of the Awkward Array data structures in Julia, which makes it possible to zero-copy share data between the two languages. Python scripts can sneak out to Julia to run a calculation at high speed. Julia programs can duck into Python to access some code that has been written in that language. [PythonCall & JuliaCall](https://juliapy.github.io/PythonCall.jl) provide these capabilities (which this package uses) for ordinary data types; this package allows arrays of complex data to be shared as well.

Beyond communication with Python, columnar memory layouts have some advantages: data in an Awkward Array is less fragmented than the equivalent `Vectors` of `Vectors`, `NamedTuples`, `Missing`, and `Union` data of the built-in Julia types. Other, well-established packages provide some of these capabilities: [ArraysOfArrays.jl](https://github.com/JuliaArrays/ArraysOfArrays.jl) does `Vectors` of variable-length `Vectors`, and [StructArrays.jl](https://github.com/JuliaArrays/StructArrays.jl) toggles between array-of-structs/struct-of-arrays like Awkward records do, but Awkward Arrays represent a closure over a large suite of data types:

  * booleans/numbers/dates/times
  * variable-length and regular-sized lists
  * structs with named (record) and unnamed (tuple) fields
  * missing data in a variety of representations (bit vectors, byte vectors, union-indexes)
  * heterogeneous unions

with the ability to add metadata and overload behavior at every level. (For instance, an array of strings is an array of lists of bytes with overloaded methods, taking advantage of Julia's multiple dispatch.)

Additionally, [arrow-julia](https://github.com/apache/arrow-julia) provides Julia access to the Apache Arrow format, which is also good for in-memory interprocess communication, but the Awkward Array format is a superset of this format to make it easier to represent intermediate calculations.

## Reading and writing the same data type

AwkwardArray.jl is a reimplementation of the concept of Awkward Arrays in Julia, taking advantage of Julia's capabilities. Python's Awkward Array has other backends for sending data to JIT-compiled languages—Numba (CPU and GPU) and C++ (with cppyy and ROOT's RDataFrame)—but as read-only views, owned exclusively by Python, for brief excursions only. Creating new Awkward Arrays in those JIT-compiled languages requires special tools, [ak.ArrayBuilder](https://awkward-array.org/doc/main/reference/generated/ak.ArrayBuilder.html) (discovers data type during iteration) and [LayoutBuilder](https://awkward-array.org/doc/main/user-guide/how-to-use-header-only-layoutbuilder.html) (fills a specified data type; faster).

In Julia, the array/builder dichotomy can be eliminated. Every Awkward Array is also a LayoutBuilder: they are appendable with the built-in `push!` and `append!` functions.

```julia
julia> using AwkwardArray: Index64, ListOffsetArray, PrimitiveArray

julia> array = ListOffsetArray{Index64,PrimitiveArray{Float64}}()
0-element ListOffsetArray{Vector{Int64}, PrimitiveArray{Float64, Vector{Float64}, :default}, :default}

julia> push!(array, [1.1, 2.2, 3.3])
1-element ListOffsetArray{Vector{Int64}, PrimitiveArray{Float64, Vector{Float64}, :default}, :default}:
 [1.1, 2.2, 3.3]

julia> push!(array, [4.4])
2-element ListOffsetArray{Vector{Int64}, PrimitiveArray{Float64, Vector{Float64}, :default}, :default}:
 [1.1, 2.2, 3.3]
 [4.4]

julia> append!(array, [[5.5, 6.6], [7.7, 8.8, 9.9]])
4-element ListOffsetArray{Vector{Int64}, PrimitiveArray{Float64, Vector{Float64}, :default}, :default}:
 [1.1, 2.2, 3.3]
 [4.4]
 [5.5, 6.6]
 [7.7, 8.8, 9.9]
```

This is the same type of array that can be iterated over

```julia
julia> total = 0.0
0.0

julia> for list in array
           for item in list
               total += item
           end
       end

julia> total
49.5
```

converted to and from Julia objects

```julia
julia> using AwkwardArray

julia> AwkwardArray.to_vector(array)
4-element Vector{Vector{Float64}}:
 [1.1, 2.2, 3.3]
 [4.4]
 [5.5, 6.6]
 [7.7, 8.8, 9.9]

julia> AwkwardArray.from_iter(AwkwardArray.to_vector(array))
4-element ListOffsetArray{Vector{Int64}, PrimitiveArray{Float64, Vector{Float64}, :default}, :default}:
 [1.1, 2.2, 3.3]
 [4.4]
 [5.5, 6.6]
 [7.7, 8.8, 9.9]
```

and passed to and from Python. Thus, AwkwardArray.jl is the only JIT-compiled Awkward Array backend that can own its own data.


## Documentation
For more details and examples check [User Guilde](https://juliahep.github.io/AwkwardArray.jl/dev/)
