using PythonCall 
using AwkwardArray: julia_array_to_python

# Test julia_array_to_python function
@testset "julia_array_to_python tests" begin
    array = AwkwardArray.ListOffsetArray(
        [0, 3, 3, 5],
        AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    )
    # Test case 1: Check if the function returns an awkward array
    @test isa(julia_array_to_python(array), Py)

    # Test case 2: Check if the awkward array has the correct layout
    py_array = julia_array_to_python(array)
    @test typeof(py_array) == Py
    ak_array = pyconvert(Vector, pyimport("awkward").to_list(py_array))
    @test ak_array == [[1.1, 2.2, 3.3], [], [4.4, 5.5]]


end

using AwkwardArray: python_array_to_julia

# Test python_array_to_julia function
@testset "python_array_to_julia tests" begin
    py_array = pyimport("awkward").Array([[1.1, 2.2, 3.3], [], [4.4, 5.5]])

    array = python_array_to_julia(py_array)
    # Test case 1: Check if the function returns an awkward array
    @test array isa AwkwardArray.ListOffsetArray

    @test array == [[1.1, 2.2, 3.3], [], [4.4, 5.5]]
end
