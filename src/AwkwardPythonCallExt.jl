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

# rule functions
function pyconvert_rule_awkward_array_primitive(::Type{AwkwardArray.PrimitiveArray}, x::Py)
    py_arr = pyconvert(AwkwardArray.PrimitiveArray, x)
    array = AwkwardArray.convert(py_arr)
    return PythonCall.pyconvert_return(array)
end

function pyconvert_rule_awkward_array_empty(::Type{AwkwardArray.EmptyArray}, x::Py)
    py_arr = pyconvert(AwkwardArray.EmptyArray, x)
    array = AwkwardArray.convert(py_arr)
    return PythonCall.pyconvert_return(array)
end

function pyconvert_rule_awkward_array_listoffset(::Type{AwkwardArray.ListOffsetArray}, x::Py)
    py_arr = pyconvert(AwkwardArray.ListOffsetArray, x)
    array = AwkwardArray.convert(py_arr)
    return PythonCall.pyconvert_return(array)
end

function pyconvert_rule_awkward_array_list(::Type{AwkwardArray.ListArray}, x::Py)
    py_arr = pyconvert(AwkwardArray.ListArray, x)
    array = AwkwardArray.convert(py_arr)
    return PythonCall.pyconvert_return(array)
end
function pyconvert_rule_awkward_array_regular(::Type{AwkwardArray.RegularArray}, x::Py)
    py_arr = pyconvert(AwkwardArray.RegularArray, x)
    array = AwkwardArray.convert(py_arr)
    return PythonCall.pyconvert_return(array)
end

function pyconvert_rule_awkward_array_record(::Type{AwkwardArray.RecordArray}, x::Py)
    py_arr = pyconvert(AwkwardArray.RecordArray, x)
    array = AwkwardArray.convert(py_arr)
    return PythonCall.pyconvert_return(array)
end

function pyconvert_rule_awkward_array_tuple(::Type{AwkwardArray.TupleArray}, x::Py)
    py_arr = pyconvert(AwkwardArray.TupleArray, x)
    array = AwkwardArray.convert(py_arr)
    return PythonCall.pyconvert_return(array)
end

function pyconvert_rule_awkward_array_indexed(::Type{AwkwardArray.IndexedArray}, x::Py)
    py_arr = pyconvert(AwkwardArray.IndexedArray, x)
    array = AwkwardArray.convert(py_arr)
    return PythonCall.pyconvert_return(array)
end

function pyconvert_rule_awkward_array_indexedoption(::Type{AwkwardArray.IndexedOptionArray}, x::Py)
    py_arr = pyconvert(AwkwardArray.IndexedOptionArray, x)
    array = AwkwardArray.convert(py_arr)
    return PythonCall.pyconvert_return(array)
end

function pyconvert_rule_awkward_array_bytemasked(::Type{AwkwardArray.ByteMaskedArray}, x::Py)
    py_arr = pyconvert(AwkwardArray.ByteMaskedArray, x)
    array = AwkwardArray.convert(py_arr)
    return PythonCall.pyconvert_return(array)
end

function pyconvert_rule_awkward_array_bitmasked(::Type{AwkwardArray.BitMaskedArray}, x::Py)
    py_arr = pyconvert(AwkwardArray.BitMaskedArray, x)
    array = AwkwardArray.convert(py_arr)
    return PythonCall.pyconvert_return(array)
end

function pyconvert_rule_awkward_array_unmasked(::Type{AwkwardArray.UnmaskedArray}, x::Py)
    py_arr = pyconvert(AwkwardArray.UnmaskedArray, x)
    array = AwkwardArray.convert(py_arr)
    return PythonCall.pyconvert_return(array)
end

function pyconvert_rule_awkward_array_union(::Type{AwkwardArray.UnionArray}, x::Py)
    py_arr = pyconvert(AwkwardArray.UnionArray, x)
    array = AwkwardArray.convert(py_arr)
    return PythonCall.pyconvert_return(array)
end

function __init__()
    PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.PrimitiveArray, pyconvert_rule_awkward_array_primitive, PythonCall.PYCONVERT_PRIORITY_ARRAY)
    PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.EmptyArray, pyconvert_rule_awkward_array_empty, PythonCall.PYCONVERT_PRIORITY_ARRAY)
    PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.ListOffsetArray, pyconvert_rule_awkward_array_listoffset, PythonCall.PYCONVERT_PRIORITY_ARRAY)
    PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.ListArray, pyconvert_rule_awkward_array_list, PythonCall.PYCONVERT_PRIORITY_ARRAY)
    PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.RegularArray, pyconvert_rule_awkward_array_regular, PythonCall.PYCONVERT_PRIORITY_ARRAY)
    PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.RecordArray, pyconvert_rule_awkward_array_record, PythonCall.PYCONVERT_PRIORITY_ARRAY)
    PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.TupleArray, pyconvert_rule_awkward_array_tuple, PythonCall.PYCONVERT_PRIORITY_ARRAY)
    PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.IndexedArray, pyconvert_rule_awkward_array_indexed, PythonCall.PYCONVERT_PRIORITY_ARRAY)
    PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.IndexedOptionArray, pyconvert_rule_awkward_array_indexedoption, PythonCall.PYCONVERT_PRIORITY_ARRAY)
    PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.ByteMaskedArray, pyconvert_rule_awkward_array_bytemasked, PythonCall.PYCONVERT_PRIORITY_ARRAY)
    PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.BitMaskedArray, pyconvert_rule_awkward_array_bitmasked, PythonCall.PYCONVERT_PRIORITY_ARRAY)
    PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.UnmaskedArray, pyconvert_rule_awkward_array_unmasked, PythonCall.PYCONVERT_PRIORITY_ARRAY)
    PythonCall.pyconvert_add_rule("awkward.highlevel:Array", AwkwardArray.UnionArray, pyconvert_rule_awkward_array_union, PythonCall.PYCONVERT_PRIORITY_ARRAY)
end

end # module
