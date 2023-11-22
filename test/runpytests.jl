using PyCall
using Test
using AwkwardArray

include("../src/pycall/AwkwardPyCall.jl")

import Main.AwkwardPyCall: julia_array_to_python

# Test julia_array_to_python function
@testset "julia_array_to_python tests" begin
    layout = AwkwardArray.ListOffsetArray(
            [0, 3, 3, 5],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )
    # Test case 1: Check if the function returns an awkward array
    @test isa(julia_array_to_python(layout), PyObject)

    # Test case 2: Check if the awkward array has the correct dtype
    py_array = julia_array_to_python(layout)
    @test typeof(py_array) == PyObject
end

import Main.AwkwardPyCall: python_array_to_julia
import Main.AwkwardPyCall: ak

# Test python_array_to_julia function
@testset "python_array_to_julia tests" begin
    py_array = ak.Array([[1.1, 2.2, 3.3], [], [4.4, 5.5]])
 
    # Test case 1: Check if the function returns an awkward array
    @test isa(python_array_to_julia(py_array), AwkwardArray.ListOffsetArray{SubArray{Int64, 1, Vector{Int64}, Tuple{UnitRange{Int64}}, true}, AwkwardArray.PrimitiveArray{Float64, SubArray{Float64, 1, Vector{Float64}, Tuple{UnitRange{Int64}}, true}, :default}, :default})

    # Test case 2: Check if the awkward array has the correct dtype
    array = python_array_to_julia(py_array)
    @test typeof(array) == AwkwardArray.ListOffsetArray{SubArray{Int64, 1, Vector{Int64}, Tuple{UnitRange{Int64}}, true}, AwkwardArray.PrimitiveArray{Float64, SubArray{Float64, 1, Vector{Float64}, Tuple{UnitRange{Int64}}, true}, :default}, :default}
end
