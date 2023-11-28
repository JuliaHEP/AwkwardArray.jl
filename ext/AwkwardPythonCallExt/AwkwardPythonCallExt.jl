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

end # module
