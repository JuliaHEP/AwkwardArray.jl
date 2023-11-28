using PyCall
using Test

using Pkg

# FIXME: remove after AwkwardArray is released
function add_unreleased_AwkwardArray_package()
    # Specify the Git URL of the AwkwardArray package
    git_url = "https://github.com/JuliaHEP/AwkwardArray.jl"

    # Use Pkg to add the package
    Pkg.add(PackageSpec(url = git_url))
end

# Call the function to add the unreleased AwkwardArray package
add_unreleased_AwkwardArray_package()

using AwkwardArray

Pkg.add("JSON")
using JSON

include("../src/pycall/AwkwardPyCall.jl")

import Main.AwkwardPyCall: convert

# Test convert Julia array to Python function
@testset "convert Julia array to Python tests" begin
    array = AwkwardArray.ListOffsetArray(
        [0, 3, 3, 5],
        AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    )
    # Test case 1: Check if the function returns an awkward array
    @test isa(convert(array), PyObject)

    # Test case 2: Check if the awkward array has the correct layout
    py_array = convert(array)
    @test typeof(py_array) == PyObject
    @test pyimport("awkward").to_list(py_array) == [[1.1, 2.2, 3.3], [], [4.4, 5.5]]


end

# Test convert Python array to Julia function
@testset "convert Python array to Julia tests" begin
    py_array = pyimport("awkward").Array([[1.1, 2.2, 3.3], [], [4.4, 5.5]])

    # Test case 1: Check if the function returns an awkward array
    @test isa(
        convert(py_array),
        AwkwardArray.ListOffsetArray{
            SubArray{Int64,1,Vector{Int64},Tuple{UnitRange{Int64}},true},
            AwkwardArray.PrimitiveArray{
                Float64,
                SubArray{Float64,1,Vector{Float64},Tuple{UnitRange{Int64}},true},
                :default,
            },
            :default,
        },
    )

    # Test case 2: Check if the awkward array has the correct layout
    array = convert(py_array)
    @test typeof(array) == AwkwardArray.ListOffsetArray{
        SubArray{Int64,1,Vector{Int64},Tuple{UnitRange{Int64}},true},
        AwkwardArray.PrimitiveArray{
            Float64,
            SubArray{Float64,1,Vector{Float64},Tuple{UnitRange{Int64}},true},
            :default,
        },
        :default,
    }
    @test array == [[1.1, 2.2, 3.3], [], [4.4, 5.5]]
end
