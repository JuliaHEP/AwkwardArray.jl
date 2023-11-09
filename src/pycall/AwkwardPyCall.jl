module AwkwardPyCall

if !isdefined(Main, :PyCall)
    println("PyCall is not installed. Installing...")

    import Pkg

    Pkg.add("PyCall")
end
    
using PyCall
@reexport using AwkwardArray

const ak = pyimport("awkward")
const np = pyimport("numpy")

function _as_numpy(array::AbstractVector{UInt8})
    py_array = PyObject(array)
    np.asarray(py_array, dtype=np.uint8)
end

function julia_array_to_python(array)
    form, len, containers = AwkwardArray.to_buffers(array)
    
    py_buffers = Dict{String, Any}()

    for (key, buffer) in containers
        numpy_arrays[key] = _as_numpy(buffer)
    end

    return ak.from_buffers(form, len, py_buffers)
end

end # module
