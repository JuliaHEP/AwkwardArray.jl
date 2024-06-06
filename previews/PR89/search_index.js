var documenterSearchIndex = {"docs":
[{"location":"api/#API","page":"APIs","title":"API","text":"","category":"section"},{"location":"exampleusage/#Converting-to-and-from-Julia-objects","page":"Example Usage","title":"Converting to and from Julia objects","text":"","category":"section"},{"location":"exampleusage/","page":"Example Usage","title":"Example Usage","text":"using AwkwardArray\n\nAwkwardArray.to_vector(array)\n4-element Vector{Vector{Float64}}:\n [1.1, 2.2, 3.3]\n [4.4]\n [5.5, 6.6]\n [7.7, 8.8, 9.9]\n\nAwkwardArray.from_iter(AwkwardArray.to_vector(array))\n4-element ListOffsetArray{Vector{Int64}, PrimitiveArray{Float64, Vector{Float64}, :default}, :default}:\n [1.1, 2.2, 3.3]\n [4.4]\n [5.5, 6.6]\n [7.7, 8.8, 9.9]","category":"page"},{"location":"exampleusage/#Converting-from-Python-to-Julia","page":"Example Usage","title":"Converting from Python to Julia","text":"","category":"section"},{"location":"exampleusage/","page":"Example Usage","title":"Example Usage","text":"PythonCall is currently configured to use the Julia-specific Python distribution installed by the CondaPkg.jl package.","category":"page"},{"location":"exampleusage/","page":"Example Usage","title":"Example Usage","text":"using CondaPkg\nCondaPkg.add(\"numpy\")\nCondaPkg.add(\"awkward\")","category":"page"},{"location":"exampleusage/","page":"Example Usage","title":"Example Usage","text":"using PythonCall\n\nconst ak = pyimport(\"awkward\")\n\nprintln(ak.__version__)\n2.5.0","category":"page"},{"location":"LICENSE/","page":"LICENSE","title":"LICENSE","text":"MIT License","category":"page"},{"location":"LICENSE/","page":"LICENSE","title":"LICENSE","text":"Copyright (c) 2023 Jim Pivarski <pivarski@princeton.edu>, Jerry Ling <jerry.ling@cern.ch>, and contributors","category":"page"},{"location":"LICENSE/","page":"LICENSE","title":"LICENSE","text":"Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:","category":"page"},{"location":"LICENSE/","page":"LICENSE","title":"LICENSE","text":"The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.","category":"page"},{"location":"LICENSE/","page":"LICENSE","title":"LICENSE","text":"THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.","category":"page"},{"location":"#Why?","page":"Introduction","title":"Why?","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"Awkward Array is a library for manipulating large-scale arrays of nested, variable-sized data in Python, using array-oriented idioms: like NumPy, but for any JSON-like data. In Python, using array-oriented idioms to avoid imperative for loops is necessary for fast computations. In Julia, imperative code is already fast, thanks to JIT-compilation, so you may be wondering why this package exists.","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"This package is a complete, one-to-one implementation of the Awkward Array data structures in Julia, which makes it possible to zero-copy share data between the two languages. Python scripts can sneak out to Julia to run a calculation at high speed. Julia programs can duck into Python to access some code that has been written in that language. PythonCall & JuliaCall provide these capabilities (which this package uses) for ordinary data types; this package allows arrays of complex data to be shared as well.","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"Beyond communication with Python, columnar memory layouts have some advantages: data in an Awkward Array is less fragmented than the equivalent Vectors of Vectors, NamedTuples, Missing, and Union data of the built-in Julia types. Other, well-established packages provide some of these capabilities: ArraysOfArrays.jl does Vectors of variable-length Vectors, and StructArrays.jl toggles between array-of-structs/struct-of-arrays like Awkward records do, but Awkward Arrays represent a closure over a large suite of data types:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"booleans/numbers/dates/times\nvariable-length and regular-sized lists\nstructs with named (record) and unnamed (tuple) fields\nmissing data in a variety of representations (bit vectors, byte vectors, union-indexes)\nheterogeneous unions","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"with the ability to add metadata and overload behavior at every level. (For instance, an array of strings is an array of lists of bytes with overloaded methods, taking advantage of Julia's multiple dispatch.)","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"Additionally, arrow-julia provides Julia access to the Apache Arrow format, which is also good for in-memory interprocess communication, but the Awkward Array format is a superset of this format to make it easier to represent intermediate calculations.","category":"page"},{"location":"#Reading-and-writing-the-same-data-type","page":"Introduction","title":"Reading and writing the same data type","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"AwkwardArray.jl is a reimplementation of the concept of Awkward Arrays in Julia, taking advantage of Julia's capabilities. Python's Awkward Array has other backends for sending data to JIT-compiled languages—Numba (CPU and GPU) and C++ (with cppyy and ROOT's RDataFrame)—but as read-only views, owned exclusively by Python, for brief excursions only. Creating new Awkward Arrays in those JIT-compiled languages requires special tools, ak.ArrayBuilder (discovers data type during iteration) and LayoutBuilder (fills a specified data type; faster).","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"In Julia, the array/builder dichotomy can be eliminated. Every Awkward Array is also a LayoutBuilder: they are appendable with the built-in push! and append! functions.","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"julia> using AwkwardArray: Index64, ListOffsetArray, PrimitiveArray\n\njulia> array = ListOffsetArray{Index64,PrimitiveArray{Float64}}()\n0-element ListOffsetArray{Vector{Int64}, PrimitiveArray{Float64, Vector{Float64}, :default}, :default}\n\njulia> push!(array, [1.1, 2.2, 3.3])\n1-element ListOffsetArray{Vector{Int64}, PrimitiveArray{Float64, Vector{Float64}, :default}, :default}:\n [1.1, 2.2, 3.3]\n\njulia> push!(array, [4.4])\n2-element ListOffsetArray{Vector{Int64}, PrimitiveArray{Float64, Vector{Float64}, :default}, :default}:\n [1.1, 2.2, 3.3]\n [4.4]\n\njulia> append!(array, [[5.5, 6.6], [7.7, 8.8, 9.9]])\n4-element ListOffsetArray{Vector{Int64}, PrimitiveArray{Float64, Vector{Float64}, :default}, :default}:\n [1.1, 2.2, 3.3]\n [4.4]\n [5.5, 6.6]\n [7.7, 8.8, 9.9]","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"This is the same type of array that can be iterated over","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"julia> total = 0.0\n0.0\n\njulia> for list in array\n           for item in list\n               total += item\n           end\n       end\n\njulia> total\n49.5","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"converted to and from Julia objects","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"julia> using AwkwardArray\n\njulia> AwkwardArray.to_vector(array)\n4-element Vector{Vector{Float64}}:\n [1.1, 2.2, 3.3]\n [4.4]\n [5.5, 6.6]\n [7.7, 8.8, 9.9]\n\njulia> AwkwardArray.from_iter(AwkwardArray.to_vector(array))\n4-element ListOffsetArray{Vector{Int64}, PrimitiveArray{Float64, Vector{Float64}, :default}, :default}:\n [1.1, 2.2, 3.3]\n [4.4]\n [5.5, 6.6]\n [7.7, 8.8, 9.9]","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"and passed to and from Python. Thus, AwkwardArray.jl is the only JIT-compiled Awkward Array backend that can own its own data.","category":"page"},{"location":"#Composability","page":"Introduction","title":"Composability","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"AwkwardArray.jl accepts any AbstractVector for index and data buffers, so that buffers on GPUs, data with units, etc. can be used in place of the usual Vector type.","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"None of AwkwardArray.jl's algorithms assume that these buffers are 1-indexed, so even OffsetArrays.jl could be used as buffers. This is also important because the data in the index buffers are 0-indexed, so that they can be zero-copy exchanged with Python.","category":"page"},{"location":"#Array-layout-classes","page":"Introduction","title":"Array layout classes","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"In Python, we make a distinction between high-level ak.Array (for data analysts) and low-level Content memory layouts (for downstream developers). In Julia, it's more advantageous to expose the concrete type details to all users, particularly for defining functions with multiple dispatch. Thus, there is no ak.Array equivalent.","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"The layout classes (subclasses of AwkwardArray.Content) are:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"Julia class corresponding Python corresponding Arrow description\nPrimitiveArray NumpyArray primitive one-dimensional array of booleans, numbers, date-times, or time-differences\nEmptyArray EmptyArray (none) length-zero array with unknown type (usually derived from untyped sources)\nListOffsetArray ListOffsetArray list variable-length lists defined by an index of offsets\nListArray ListArray (none) variable-length lists defined by more general starts and stops indexes\nRegularArray RegularArray fixed-size lists of uniform size\nRecordArray RecordArray with fields struct struct-like records with named fields of different types\nTupleArray RecordArray with fields=None (none) tuples of unnamed fields of different types\nIndexedArray IndexedArray dictionary data that are lazily filtered, duplicated, and/or rearranged by an integer index\nIndexedOptionArray IndexedOptionArray (none) same but negative values in the index correspond to Missing values\nByteMaskedArray ByteMaskedArray (none) possibly-missing data, defined by a byte mask\nBitMaskedArray (only lsb_order = true) BitMaskedArray bitmaps same, defined by a BitVector\nUnmaskedArray UnmaskedArray same in-principle missing data, but none are actually missing so no mask\nUnionArray UnionArray dense union data of different types in the same array","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"Any node in the data-type tree can carry Dict{String,Any} metadata as parameters, as well as a behavior::Symbol that can be used to define specialized behaviors. For instance, arrays of strings (constructed with StringOffsetArray, StringArray, or StringRegularArray) are defined by behavior = :string (instead of behavior = :default).","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"julia> using AwkwardArray: StringOffsetArray\n\njulia> array = StringOffsetArray()\n0-element ListOffsetArray{Vector{Int64}, PrimitiveArray{UInt8, Vector{UInt8}, :char}, :string}\n\njulia> append!(array, [\"one\", \"two\", \"three\", \"four\", \"five\"])\n5-element ListOffsetArray{Vector{Int64}, PrimitiveArray{UInt8, Vector{UInt8}, :char}, :string}:\n \"one\"\n \"two\"\n \"three\"\n \"four\"\n \"five\"\n\njulia> array[3]\n\"three\"\n\njulia> typeof(array[3])\nString","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"Most applications of behavior apply to RecordArrays (e.g. Vector in Python).","category":"page"},{"location":"#List-of-functions","page":"Introduction","title":"List of functions","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"Every Content subclass has the following built-in functions:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"Base.length\nBase.size (1-tuple of length)\nBase.firstindex, Base.lastindex (1-based or inherited from its index)\nBase.getindex: select by Int (single item), UnitRange{Int} (slice), and Symbol (record field)\nBase.iterate\nBase.(==) (equality defined by values: a ListOffsetArray and a ListArray may be considered the same)\nBase.push!\nBase.append!\nBase.show","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"They also have the following functions for manipulating and checking structure:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"AwkwardArray.parameters_of: gets all parameters\nAwkwardArray.has_parameter: returns true if a parameter exists\nAwkwardArray.get_parameter: returns a parameter or raises an error\nAwkwardArray.with_parameter: returns a copy of this node with a specified parameter\nAwkwardArray.copy: shallow-copy of the array, allowing properties to be replaced\nAwkwardArray.is_valid: verifies that the structure adheres to Awkward Array's protocol","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"They have the following functions for filling an array:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"AwkwardArray.end_list!: closes off a ListType array (ListOffsetArray, ListArray, or RegularArray) in the manner of Python's ak.ArrayBuilder (no begin_list is necessary)\nAwkwardArray.end_record!: closes off a RecordArray\nAwkwardArray.end_tuple!: closes off a TupleArray\nAwkwardArray.push_null!: pushes a missing value onto OptionType arrays (IndexedOptionArray, ByteMaskedArray, BitMaskedArray, or UnmaskedArray)\nAwkwardArray.push_dummy!: pushes an unspecified value onto the array (used by ByteMaskedArray and BitMaskedArray, which need to have a placeholder in memory behind each missing value)","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"RecordArray and TupleArray have the following for selecting fields (as opposed to rows):","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"AwkwardArray.slot: gets a RecordArray or TupleArray field, to avoid conflicts with Base.getindex for TupleArrays (both use integers to select a field)\nAwkwardArray.Record: scalar representation of an item from a RecordArray\nAwkwardArray.Tuple: scalar representation of an item from a TupleArray (note: not the same as Base.Tuple)","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"UnionArray has the following for dealing with specializations:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"AwkwardArray.Specialization: selects a UnionArray specialization for push!, append!, etc.","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"Finally, all Content subclasses can be converted with the following:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"AwkwardArray.layout_for: returns an appropriately-nested Content type for a given Julia type (DataType)\nAwkwardArray.from_iter: converts Julia data into an Awkward Array\nAwkwardArray.to_vector: converts an Awkward Array into Julia data\nAwkwardArray.from_buffers: constructs an Awkward Array from a Form (JSON), length, and buffers for zero-copy passing from Python\nAwkwardArray.to_buffers: deconstructs an Awkward Array into a Form (JSON), length, and buffers for zero-copy passing to Python","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"(This will turn into proper documentation, eventually.)","category":"page"}]
}