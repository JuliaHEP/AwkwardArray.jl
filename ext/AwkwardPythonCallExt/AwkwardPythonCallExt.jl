module AwkwardPythonCallExt
using PythonCall
using JSON
import AwkwardArray

function AwkwardArray.convert(layout::AwkwardArray.Content)::Py
    form, len, containers = AwkwardArray.to_buffers(layout)

    py_buffers = Dict{String,Any}()

    for (key, buffer) in containers
        py_buffers[key] = pyimport("numpy").asarray(buffer, dtype = pyimport("numpy").uint8)
    end

    pyimport("awkward").from_buffers(form, len, py_buffers)
end

function AwkwardArray.convert(array::Py)::AwkwardArray.Content
    form, len, _containers = pyimport("awkward").to_buffers(array)
    containers = pyconvert(Dict, _containers)

    julia_buffers = Dict{String,AbstractVector{UInt8}}()

    for (key, buffer) in containers
        julia_buffers[key] = reinterpret(UInt8, buffer)
    end

    AwkwardArray.from_buffers(
        pyconvert(String, form.to_json()),
        pyconvert(Int, len),
        julia_buffers,
    )
end

function AwkwardArray.convert(array::PyIterable{Any})::AwkwardArray.Content
    form, len, _containers = pyimport("awkward").to_buffers(array)
    containers = pyconvert(Dict, _containers)

    julia_buffers = Dict{String,AbstractVector{UInt8}}()
    for (key, buffer) in containers
        julia_buffers[key] = reinterpret(UInt8, buffer)
    end

    AwkwardArray.from_buffers(
        pyconvert(String, form.to_json()),
        pyconvert(Int, len),
        julia_buffers,
    )
end


PythonCall.pyconvert_rule_array_nocopy(::Type{AwkwardArray.PrimitiveArray}, x::Py) = AwkwardArray.convert(x)
PythonCall.pyconvert_rule_array_nocopy(::Type{AwkwardArray.EmptyArray}, x::Py) = AwkwardArray.convert(x)
PythonCall.pyconvert_rule_array_nocopy(::Type{AwkwardArray.ListOffsetArray}, x::Py) = AwkwardArray.convert(x)
PythonCall.pyconvert_rule_array_nocopy(::Type{AwkwardArray.ListArray}, x::Py) = AwkwardArray.convert(x)
PythonCall.pyconvert_rule_array_nocopy(::Type{AwkwardArray.RegularArray}, x::Py) = AwkwardArray.convert(x)
PythonCall.pyconvert_rule_array_nocopy(::Type{AwkwardArray.StringOffsetArray}, x::Py) = AwkwardArray.convert(x)
PythonCall.pyconvert_rule_array_nocopy(::Type{AwkwardArray.StringArray}, x::Py) = AwkwardArray.convert(x)
PythonCall.pyconvert_rule_array_nocopy(::Type{AwkwardArray.StringRegularArray}, x::Py) = AwkwardArray.convert(x)
PythonCall.pyconvert_rule_array_nocopy(::Type{AwkwardArray.ByteStringOffsetArray}, x::Py) = AwkwardArray.convert(x)
PythonCall.pyconvert_rule_array_nocopy(::Type{AwkwardArray.ByteStringArray}, x::Py) = AwkwardArray.convert(x)
PythonCall.pyconvert_rule_array_nocopy(::Type{AwkwardArray.ByteStringRegularArray}, x::Py) = AwkwardArray.convert(x)
PythonCall.pyconvert_rule_array_nocopy(::Type{AwkwardArray.RecordArray}, x::Py) = AwkwardArray.convert(x)
PythonCall.pyconvert_rule_array_nocopy(::Type{AwkwardArray.TupleArray}, x::Py) = AwkwardArray.convert(x)
PythonCall.pyconvert_rule_array_nocopy(::Type{AwkwardArray.IndexedArray}, x::Py) = AwkwardArray.convert(x)
PythonCall.pyconvert_rule_array_nocopy(::Type{AwkwardArray.IndexedOptionArray}, x::Py) = AwkwardArray.convert(x)
PythonCall.pyconvert_rule_array_nocopy(::Type{AwkwardArray.ByteMaskedArray}, x::Py) = AwkwardArray.convert(x)
PythonCall.pyconvert_rule_array_nocopy(::Type{AwkwardArray.BitMaskedArray}, x::Py) = AwkwardArray.convert(x)
PythonCall.pyconvert_rule_array_nocopy(::Type{AwkwardArray.UnmaskedArray}, x::Py) = AwkwardArray.convert(x)
PythonCall.pyconvert_rule_array_nocopy(::Type{AwkwardArray.UnionArray}, x::Py) = AwkwardArray.convert(x)

PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.PrimitiveArray, PythonCall.pyconvert_rule_array_nocopy, PythonCall.PYCONVERT_PRIORITY_ARRAY)
PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.EmptyArray, PythonCall.pyconvert_rule_array_nocopy, PythonCall.PYCONVERT_PRIORITY_ARRAY)
PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.ListOffsetArray, PythonCall.pyconvert_rule_array_nocopy, PythonCall.PYCONVERT_PRIORITY_ARRAY)
PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.ListArray, PythonCall.pyconvert_rule_array_nocopy, PythonCall.PYCONVERT_PRIORITY_ARRAY)
PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.RegularArray, PythonCall.pyconvert_rule_array_nocopy, PythonCall.PYCONVERT_PRIORITY_ARRAY)
# FIXME: PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.StringOffsetArray, PythonCall.pyconvert_rule_array_nocopy, PythonCall.PYCONVERT_PRIORITY_ARRAY)
# FIXME: PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.StringArray, PythonCall.pyconvert_rule_array_nocopy, PythonCall.PYCONVERT_PRIORITY_ARRAY)
# FIXME: PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.StringRegularArray, PythonCall.pyconvert_rule_array_nocopy, PythonCall.PYCONVERT_PRIORITY_ARRAY)
# FIXME: PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.ByteStringOffsetArray, PythonCall.pyconvert_rule_array_nocopy, PythonCall.PYCONVERT_PRIORITY_ARRAY)
# FIXME: PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.ByteStringArray, PythonCall.pyconvert_rule_array_nocopy, PythonCall.PYCONVERT_PRIORITY_ARRAY)
# FIXME: PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.ByteStringRegularArray, PythonCall.pyconvert_rule_array_nocopy, PythonCall.PYCONVERT_PRIORITY_ARRAY)
PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.RecordArray, PythonCall.pyconvert_rule_array_nocopy, PythonCall.PYCONVERT_PRIORITY_ARRAY)
PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.TupleArray, PythonCall.pyconvert_rule_array_nocopy, PythonCall.PYCONVERT_PRIORITY_ARRAY)
PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.IndexedArray, PythonCall.pyconvert_rule_array_nocopy, PythonCall.PYCONVERT_PRIORITY_ARRAY)
PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.IndexedOptionArray, PythonCall.pyconvert_rule_array_nocopy, PythonCall.PYCONVERT_PRIORITY_ARRAY)
PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.ByteMaskedArray, PythonCall.pyconvert_rule_array_nocopy, PythonCall.PYCONVERT_PRIORITY_ARRAY)
PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.BitMaskedArray, PythonCall.pyconvert_rule_array_nocopy, PythonCall.PYCONVERT_PRIORITY_ARRAY)
PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.UnmaskedArray, PythonCall.pyconvert_rule_array_nocopy, PythonCall.PYCONVERT_PRIORITY_ARRAY)
PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.UnionArray, PythonCall.pyconvert_rule_array_nocopy, PythonCall.PYCONVERT_PRIORITY_ARRAY)

end # module
