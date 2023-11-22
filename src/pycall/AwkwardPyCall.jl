module AwkwardPyCall
using PyCall
using JSON

if !isdefined(Main, :PyCall)
    println("PyCall is not installed. Installing...")

    import Pkg

    Pkg.add("PyCall")
end
    
using PyCall
using AwkwardArray

function _as_numpy(array::AbstractVector{UInt8})
    py_array = PyObject(array)
    pyimport("numpy").asarray(py_array, dtype = pyimport("numpy").uint8)
end

function julia_array_to_python(array)
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

function python_array_to_julia(py_array)
    form, len, containers = pyimport("awkward").to_buffers(py_array)

    julia_buffers = Dict{String,AbstractVector{UInt8}}()
    for (key, buffer) in containers
        julia_buffers[key] = _as_julia(buffer)
    end

    return AwkwardArray.from_buffers(form.to_json(), len, julia_buffers)
end

end # module
