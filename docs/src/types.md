```@meta
CurrentModule = AwkwardArray
```

# Types

## Array layout classes

In Python, we make a distinction between high-level `ak.Array` (for data analysts) and low-level `Content` memory layouts (for downstream developers). In Julia, it's more advantageous to expose the concrete type details to all users, particularly for defining functions with multiple dispatch. Thus, there is no `ak.Array` equivalent.

The layout classes (subclasses of `AwkwardArray.Content`) are:

| Julia class | corresponding Python | corresponding Arrow | description |
|:--|:--|:--|:--|
| [`PrimitiveArray`](@ref) | [NumpyArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.NumpyArray.html) | [primitive](https://arrow.apache.org/docs/format/Columnar.html#fixed-size-primitive-layout) | one-dimensional array of booleans, numbers, date-times, or time-differences |
| [`EmptyArray`](@ref) | [EmptyArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.EmptyArray.html) | _(none)_ | length-zero array with unknown type (usually derived from untyped sources) |
| [`ListOffsetArray`](@ref) | [ListOffsetArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.ListOffsetArray.html) | [list](https://arrow.apache.org/docs/format/Columnar.html#variable-size-list-layout) | variable-length lists defined by an index of `offsets` |
| [`ListArray`](@ref) | [ListArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.ListArray.html) | _(none)_ | variable-length lists defined by more general `starts` and `stops` indexes |
| [`RegularArray`](@ref) | [RegularArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.RegularArray.html) | [fixed-size](https://arrow.apache.org/docs/format/Columnar.html#fixed-size-list-layout) | lists of uniform `size` |
| [`RecordArray`](@ref) | [RecordArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.RecordArray.html) with `fields` | [struct](https://arrow.apache.org/docs/format/Columnar.html#struct-layout) | struct-like records with named fields of different types |
| [`TupleArray`](@ref) | [RecordArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.RecordArray.html) with `fields=None` | _(none)_ | tuples of unnamed fields of different types |
| [`IndexedArray`](@ref) | [IndexedArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.IndexedArray.html) | [dictionary](https://arrow.apache.org/docs/format/Columnar.html#dictionary-encoded-layout) | data that are lazily filtered, duplicated, and/or rearranged by an integer `index` |
| [`IndexedOptionArray`](@ref) | [IndexedOptionArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.IndexedOptionArray.html) | _(none)_ | same but negative values in the `index` correspond to `Missing` values |
| [`ByteMaskedArray`](@ref) | [ByteMaskedArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.ByteMaskedArray.html) | _(none)_ | possibly-missing data, defined by a byte `mask` |
| [`BitMaskedArray`](@ref) (only `lsb_order = true`) | [BitMaskedArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.BitMaskedArray.html) | [bitmaps](https://arrow.apache.org/docs/format/Columnar.html#validity-bitmaps) | same, defined by a `BitVector` |
| [`UnmaskedArray`](@ref) | [UnmaskedArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.UnmaskedArray.html) | same | in-principle missing data, but none are actually missing so no mask |
| [`UnionArray`](@ref) | [UnionArray](https://awkward-array.org/doc/main/reference/generated/ak.contents.UnionArray.html) | [dense union](https://arrow.apache.org/docs/format/Columnar.html#dense-union) | data of different types in the same array |

Any node in the data-type tree can carry `Dict{String,Any}` metadata as `parameters`, as well as a `behavior::Symbol` that can be used to define specialized behaviors. For instance, arrays of strings (constructed with `StringOffsetArray`, `StringArray`, or `StringRegularArray`) are defined by `behavior = :string` (instead of `behavior = :default`).

## Types specification

```@autodocs
Modules = [AwkwardArray]
Public = true
Order = [:type]
```

## Examples

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

## Index

```@index
Pages = ["types.md"]
```
