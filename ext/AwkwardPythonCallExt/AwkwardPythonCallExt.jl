module AwkwardPythonCallExt
using PythonCall
using JSON
import AwkwardArray

function _as_numpy(array::AbstractVector{UInt8})
    np = pyimport("numpy")
    np.asarray(array, dtype = np.uint8)
end

function AwkwardArray.julia_array_to_python(array)
    form, len, containers = AwkwardArray.to_buffers(array)

    py_buffers = Dict{String,Any}()

    for (key, buffer) in containers
        py_buffers[key] = _as_numpy(buffer)
    end

    return pyimport("awkward").from_buffers(form, len, py_buffers)
end

function _as_julia(py_buffer)
    uint8_buffer = reinterpret(UInt8, py_buffer)
    return uint8_buffer
end

function AwkwardArray.python_array_to_julia(py_array)
    form, len, _containers = pyimport("awkward").to_buffers(py_array)
    containers = pyconvert(Dict, _containers)

    julia_buffers = Dict{String,AbstractVector{UInt8}}()
    for (key, buffer) in containers
        julia_buffers[key] = _as_julia(buffer)
    end

    return AwkwardArray.from_buffers(pyconvert(String, form.to_json()), pyconvert(Int, len), julia_buffers)
end

end # module
