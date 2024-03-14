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
