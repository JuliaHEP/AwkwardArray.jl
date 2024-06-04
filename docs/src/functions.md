```@meta
CurrentModule = AwkwardArray
```
## List of [`Content`](@ref) functions

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

They also have the following functions for manipulating and checking structure:

* [`AwkwardArray.parameters_of`](@ref) gets all parameters
* [`AwkwardArray.has_parameter`](@ref) returns true if a parameter exists
* [`AwkwardArray.get_parameter`](@ref) returns a parameter or raises an error
* [`AwkwardArray.with_parameter`](@ref) returns a copy of this node with a specified parameter
* [`AwkwardArray.copy`](@ref) shallow-copy of the array, allowing properties to be replaced
* [`AwkwardArray.is_valid`](@ref) verifies that the structure adheres to Awkward Array's protocol

They have the following functions for filling an array:

* [`AwkwardArray.end_list!`](@ref): closes off a [`ListType`](@ref) array ([`ListOffsetArray`](@ref), [`ListArray`](@ref), or [`RegularArray`](@ref)) in the manner of Python's [ak.ArrayBuilder](https://awkward-array.org/doc/main/reference/generated/ak.ArrayBuilder.html) (no `begin_list` is necessary)
* [`AwkwardArray.end_record!`](@ref) closes off a [`RecordArray`](@ref)
* [`AwkwardArray.end_tuple!`](@ref) closes off a [`TupleArray`](@ref)
* [`AwkwardArray.push_null!`](@ref) pushes a missing value onto [`OptionType`](@ref) arrays (`IndexedOptionArray`](@ref) [`ByteMaskedArray`](@ref) [`BitMaskedArray`](@ref) or [`UnmaskedArray`](@ref))
* [`AwkwardArray.push_dummy!`](@ref) pushes an unspecified value onto the array (used by [`ByteMaskedArray`](@ref) and [`BitMaskedArray`](@ref) which need to have a placeholder in memory behind each `missing` value)

[`RecordArray`](@ref)and [`TupleArray`](@ref) have the following for selecting fields (as opposed to rows):

* [`AwkwardArray.slot`](@ref) gets a [`RecordArray`](@ref)or [`TupleArray`](@ref) field, to avoid conflicts with [`Base.getindex`](@ref) for `TupleArrays` (both use integers to select a field)
* [`AwkwardArray.Record`](@ref) scalar representation of an item from a [`RecordArray`](@ref)
* [`AwkwardArray.SlotRecord`](@ref) scalar representation of an item from a [`TupleArray`](@ref)(note: not the same as `Base.Tuple`)

[`UnionArray`](@ref)has the following for dealing with specializations:

* [`AwkwardArray.Specialization`](@ref) selects a [`UnionArray`](@ref)specialization for [`push!`](@ref) [`append!`](@ref) etc.

Finally, all [`Content`](@ref)subclasses can be converted with the following:

* [`AwkwardArray.layout_for`](@ref) returns an appropriately-nested [`Content`](@ref)type for a given Julia type (`DataType`)
* [`AwkwardArray.from_iter`](@ref) converts Julia data into an Awkward Array
* [`AwkwardArray.to_vector`](@ref) converts an Awkward Array into Julia data
* [`AwkwardArray.from_buffers`](@ref) constructs an Awkward Array from a Form (JSON), length, and buffers for zero-copy passing from Python
* [`AwkwardArray.to_buffers`](@ref) deconstructs an Awkward Array into a Form (JSON), length, and buffers for zero-copy passing to Python


## Array functions

```@autodocs
Modules = [AwkwardArray]
Public = true
Order = [:function]
```

# Index

```@index
Pages = ["functions.md"]
```
