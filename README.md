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

## Documenttion
[User Guilde](https://juliahep.github.io/AwkwardArray.jl/dev/)

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

## Composability

AwkwardArray.jl accepts any `AbstractVector` for index and data buffers, so that buffers on GPUs, data with units, etc. can be used in place of the usual `Vector` type.

None of AwkwardArray.jl's algorithms assume that these buffers are 1-indexed, so even [OffsetArrays.jl](https://github.com/JuliaArrays/OffsetArrays.jl) could be used as buffers. This is also important because the data _in_ the index buffers are 0-indexed, so that they can be zero-copy exchanged with Python.

## Array layout classes

In Python, we make a distinction between high-level `ak.Array` (for data analysts) and low-level `Content` memory layouts (for downstream developers). In Julia, it's more advantageous to expose the concrete type details to all users, particularly for defining functions with multiple dispatch. Thus, there is no `ak.Array` equivalent.

The layout classes (subclasses of `AwkwardArray.Content`) are:

| Julia class | corresponding Python | corresponding Arrow | description |
|:--|:--|:--|:--|
| PrimitiveArray | [NumpyArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.NumpyArray.html) | [primitive](https://arrow.apache.org/docs/format/Columnar.html#fixed-size-primitive-layout) | one-dimensional array of booleans, numbers, date-times, or time-differences |
| EmptyArray | [EmptyArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.EmptyArray.html) | _(none)_ | length-zero array with unknown type (usually derived from untyped sources) |
| ListOffsetArray | [ListOffsetArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.ListOffsetArray.html) | [list](https://arrow.apache.org/docs/format/Columnar.html#variable-size-list-layout) | variable-length lists defined by an index of `offsets` |
| ListArray | [ListArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.ListArray.html) | _(none)_ | variable-length lists defined by more general `starts` and `stops` indexes |
| RegularArray | [RegularArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.RegularArray.html) | [fixed-size](https://arrow.apache.org/docs/format/Columnar.html#fixed-size-list-layout) | lists of uniform `size` |
| RecordArray | [RecordArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.RecordArray.html) with `fields` | [struct](https://arrow.apache.org/docs/format/Columnar.html#struct-layout) | struct-like records with named fields of different types |
| TupleArray | [RecordArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.RecordArray.html) with `fields=None` | _(none)_ | tuples of unnamed fields of different types |
| IndexedArray | [IndexedArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.IndexedArray.html) | [dictionary](https://arrow.apache.org/docs/format/Columnar.html#dictionary-encoded-layout) | data that are lazily filtered, duplicated, and/or rearranged by an integer `index` |
| IndexedOptionArray | [IndexedOptionArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.IndexedOptionArray.html) | _(none)_ | same but negative values in the `index` correspond to `Missing` values |
| ByteMaskedArray | [ByteMaskedArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.ByteMaskedArray.html) | _(none)_ | possibly-missing data, defined by a byte `mask` |
| BitMaskedArray (only `lsb_order = true`) | [BitMaskedArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.BitMaskedArray.html) | [bitmaps](https://arrow.apache.org/docs/format/Columnar.html#validity-bitmaps) | same, defined by a `BitVector` |
| UnmaskedArray | [UnmaskedArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.UnmaskedArray.html) | same | in-principle missing data, but none are actually missing so no mask |
| UnionArray | [UnionArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.UnionArray.html) | [dense union](https://arrow.apache.org/docs/format/Columnar.html#dense-union) | data of different types in the same array |

Any node in the data-type tree can carry `Dict{String,Any}` metadata as `parameters`, as well as a `behavior::Symbol` that can be used to define specialized behaviors. For instance, arrays of strings (constructed with `StringOffsetArray`, `StringArray`, or `StringRegularArray`) are defined by `behavior = :string` (instead of `behavior = :default`).

```julia
julia> using AwkwardArray: StringOffsetArray

julia> array = StringOffsetArray()
0-element ListOffsetArray{Vector{Int64}, PrimitiveArray{UInt8, Vector{UInt8}, :char}, :string}

julia> append!(array, ["one", "two", "three", "four", "five"])
5-element ListOffsetArray{Vector{Int64}, PrimitiveArray{UInt8, Vector{UInt8}, :char}, :string}:
 "one"
 "two"
 "three"
 "four"
 "five"

julia> array[3]
"three"

julia> typeof(array[3])
String
```

Most applications of `behavior` apply to `RecordArrays` (e.g. [Vector](https://github.com/scikit-hep/vector) in Python).

## List of functions

Every `Content` subclass has the following built-in functions:

* `Base.length`
* `Base.size` (1-tuple of `length`)
* `Base.firstindex`, `Base.lastindex` (1-based or inherited from its index)
* `Base.getindex`: select by `Int` (single item), `UnitRange{Int}` (slice), and `Symbol` (record field)
* `Base.iterate`
* `Base.(==)` (equality defined by values: a `ListOffsetArray` and a `ListArray` may be considered the same)
* `Base.push!`
* `Base.append!`
* `Base.show`

They also have the following functions for manipulating and checking structure:

* `AwkwardArray.parameters_of`: gets all parameters
* `AwkwardArray.has_parameter`: returns true if a parameter exists
* `AwkwardArray.get_parameter`: returns a parameter or raises an error
* `AwkwardArray.with_parameter`: returns a copy of this node with a specified parameter
* `AwkwardArray.copy`: shallow-copy of the array, allowing properties to be replaced
* `AwkwardArray.is_valid`: verifies that the structure adheres to Awkward Array's protocol

They have the following functions for filling an array:

* `AwkwardArray.end_list!`: closes off a `ListType` array (`ListOffsetArray`, `ListArray`, or `RegularArray`) in the manner of Python's [ak.ArrayBuilder](https://awkward-array.org/doc/main/reference/generated/ak.ArrayBuilder.html) (no `begin_list` is necessary)
* `AwkwardArray.end_record!`: closes off a `RecordArray`
* `AwkwardArray.end_tuple!`: closes off a `TupleArray`
* `AwkwardArray.push_null!`: pushes a missing value onto `OptionType` arrays (`IndexedOptionArray`, `ByteMaskedArray`, `BitMaskedArray`, or `UnmaskedArray`)
* `AwkwardArray.push_dummy!`: pushes an unspecified value onto the array (used by `ByteMaskedArray` and `BitMaskedArray`, which need to have a placeholder in memory behind each `missing` value)

`RecordArray` and `TupleArray` have the following for selecting fields (as opposed to rows):

* `AwkwardArray.slot`: gets a `RecordArray` or `TupleArray` field, to avoid conflicts with `Base.getindex` for `TupleArrays` (both use integers to select a field)
* `AwkwardArray.Record`: scalar representation of an item from a `RecordArray`
* `AwkwardArray.Tuple`: scalar representation of an item from a `TupleArray` (note: not the same as `Base.Tuple`)

`UnionArray` has the following for dealing with specializations:

* `AwkwardArray.Specialization`: selects a `UnionArray` specialization for `push!`, `append!`, etc.

Finally, all `Content` subclasses can be converted with the following:

* `AwkwardArray.layout_for`: returns an appropriately-nested `Content` type for a given Julia type (`DataType`)
* `AwkwardArray.from_iter`: converts Julia data into an Awkward Array
* `AwkwardArray.to_vector`: converts an Awkward Array into Julia data
* `AwkwardArray.from_buffers`: constructs an Awkward Array from a Form (JSON), length, and buffers for zero-copy passing from Python
* `AwkwardArray.to_buffers`: deconstructs an Awkward Array into a Form (JSON), length, and buffers for zero-copy passing to Python

_(This will turn into proper documentation, eventually.)_
