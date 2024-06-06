```@meta
CurrentModule = AwkwardArray
```

# Functions

```@contents
Pages = ["functions.md"]
```

## Built-in functions

Every [`Content`](@ref) subclass has the following built-in functions:

* [`Base.length`](@ref)
* [`Base.size`](@ref) (1-tuple of `length`)
* [`Base.firstindex`](@ref), [`Base.lastindex`](@ref)(1-based or inherited from its index)
* [`Base.getindex`](@ref) select by `Int`(single item), `UnitRange{Int}`(slice), and `Symbol`(record field)
* [`Base.iterate`](@ref)
* [`Base.:(==)`](@ref) (equality defined by values: a [`ListOffsetArray`](@ref) and a [`ListArray`](@ref) may be considered the same)
* [`Base.push!`](@ref)
* [`Base.append!`](@ref)
* [`Base.show`](@ref)

```@docs
Base.length
Base.size
Base.firstindex
Base.lastindex
Base.getindex
Base.iterate
Base.eltype
Base.:(==)
Base.push!
Base.append!
Base.show
Base.keys
```

## Manipulating and checking structure

Every [`Content`](@ref) subclass has the following functions for manipulating and checking structure:

* [`AwkwardArray.parameters_of`](@ref) gets all parameters
* [`AwkwardArray.has_parameter`](@ref) returns true if a parameter exists
* [`AwkwardArray.get_parameter`](@ref) returns a parameter or raises an error
* [`AwkwardArray.with_parameter`](@ref) returns a copy of this node with a specified parameter
* [`AwkwardArray.copy`](@ref) shallow-copy of the array, allowing properties to be replaced
* [`AwkwardArray.is_valid`](@ref) verifies that the structure adheres to Awkward Array's protocol

```@docs
parameters_of
has_parameter
get_parameter
with_parameter
copy
is_valid
```

## Filling an array

Every [`Content`](@ref) subclass has the following functions for filling an array:

* [`AwkwardArray.end_list!`](@ref): closes off a [`ListType`](@ref) array ([`ListOffsetArray`](@ref), [`ListArray`](@ref), or [`RegularArray`](@ref)) in the manner of Python's [ak.ArrayBuilder](https://awkward-array.org/doc/main/reference/generated/ak.ArrayBuilder.html) (no `begin_list` is necessary)
* [`AwkwardArray.end_record!`](@ref) closes off a [`RecordArray`](@ref)
* [`AwkwardArray.end_tuple!`](@ref) closes off a [`TupleArray`](@ref)
* [`AwkwardArray.push_null!`](@ref) pushes a missing value onto [`OptionType`](@ref) arrays ([`IndexedOptionArray`](@ref) [`ByteMaskedArray`](@ref) [`BitMaskedArray`](@ref) or [`UnmaskedArray`](@ref))
* [`AwkwardArray.push_dummy!`](@ref) pushes an unspecified value onto the array (used by [`ByteMaskedArray`](@ref) and [`BitMaskedArray`](@ref) which need to have a placeholder in memory behind each `missing` value)

```@docs
end_list!
end_record!
end_tuple!
push_null!
push_dummy!
```
## Selecting fields

[`RecordArray`](@ref)and [`TupleArray`](@ref) have the following for selecting fields (as opposed to rows):

* [`AwkwardArray.slot`](@ref) gets a [`RecordArray`](@ref)or [`TupleArray`](@ref) field, to avoid conflicts with [`Base.getindex`](@ref) for `TupleArrays` (both use integers to select a field)
* [`AwkwardArray.Record`](@ref) scalar representation of an item from a [`RecordArray`](@ref)
* [`AwkwardArray.SlotRecord`](@ref) scalar representation of an item from a [`TupleArray`](@ref)(note: not the same as `Base.Tuple`)

```@docs
AwkwardArray.slot
```

## Specializations

[`UnionArray`](@ref)has the following for dealing with specializations:

* [`AwkwardArray.Specialization`](@ref) selects a [`UnionArray`](@ref)specialization for [`push!`](@ref) [`append!`](@ref) etc.

## Convertion

Finally, all [`Content`](@ref)subclasses can be converted with the following:

* [`AwkwardArray.layout_for`](@ref) returns an appropriately-nested [`Content`](@ref)type for a given Julia type (`DataType`)
* [`AwkwardArray.from_iter`](@ref) converts Julia data into an Awkward Array
* [`AwkwardArray.to_vector`](@ref) converts an Awkward Array into Julia data
* [`AwkwardArray.from_buffers`](@ref) constructs an Awkward Array from a Form (JSON), length, and buffers for zero-copy passing from Python
* [`AwkwardArray.to_buffers`](@ref) deconstructs an Awkward Array into a Form (JSON), length, and buffers for zero-copy passing to Python

```@docs
AwkwardArray.layout_for
AwkwardArray.from_iter
AwkwardArray.to_vector
AwkwardArray.to_vector_or_scalar
AwkwardArray.from_buffers
AwkwardArray.to_buffers
```

## Arrays of Stings

```@docs
ByteStringOffsetArray
ByteStringArray
ByteStringRegularArray
StringArray
StringOffsetArray
StringRegularArray
```

## Utilities

```@docs
AwkwardArray.isprimitive
AwkwardArray.default_buffer_key
AwkwardArray.compatible
AwkwardArray.check_primitive_type
```

## Private functions

```@docs
AwkwardArray._alternate
AwkwardArray._get_buffer
AwkwardArray._get_index
AwkwardArray._horizontal
AwkwardArray._to_buffers!
AwkwardArray._to_buffers_index
AwkwardArray._to_buffers_parameters
AwkwardArray._vertical
```

# Index

```@index
Pages = ["functions.md"]
```
