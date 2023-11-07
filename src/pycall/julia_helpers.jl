using PyCall
using AwkwardArray

const ak = pyimport("awkward")
const np = pyimport("numpy")

function julia_array_to_numpy(array)
    py_array = PyObject(array)
    np.array(py_array)
end

### convert a Julia AwkwardArray to a Python Awkward Array
### via buffers
function julia_array_to_python(array)
    form, len, containers = AwkwardArray.to_buffers(array)
    
    numpy_arrays = Dict{String, Any}()

    for (key, value) in containers
        numpy_arrays[key] = np.array(value, dtype=np.uint8)
    end

    ### a bytes-like object is required
    return ak.from_buffers(form, len, numpy_arrays)
end
