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

function convert(layout::AwkwardArray.Content)::PyObject
    form, len, containers = AwkwardArray.to_buffers(layout)

    py_buffers = Dict{String,Any}()

    for (key, buffer) in containers
        py_buffers[key] =
            pyimport("numpy").asarray(PyObject(buffer), dtype = pyimport("numpy").uint8)
    end

    pyimport("awkward").from_buffers(form, len, py_buffers)
end

function convert(array::PyObject)::AwkwardArray.Content
    form, len, containers = pyimport("awkward").to_buffers(array)

    julia_buffers = Dict{String,AbstractVector{UInt8}}()

    for (key, buffer) in containers
        julia_buffers[key] = reinterpret(UInt8, buffer)
    end

    AwkwardArray.from_buffers(form.to_json(), len, julia_buffers)
end

end # module
