using PythonCall
using AwkwardArray: convert

# Test convert Julia array to Python function
@testset "convert Julia array to Python tests" begin
    array = AwkwardArray.ListOffsetArray(
        [0, 3, 3, 5],
        AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    )
    py_array = convert(array)

    # Test case 1: Check if the function returns an awkward array
    @test py_array isa Py

    # Test case 2: Check if the awkward array has the correct layout
    @test typeof(py_array) == Py

    ak_array = pyconvert(Vector, pyimport("awkward").to_list(py_array))
    @test ak_array == [[1.1, 2.2, 3.3], [], [4.4, 5.5]]

end

# Test convert Python array to Julia function
@testset "convert Python array to Julia tests" begin
    py_array = pyimport("awkward").Array([[1.1, 2.2, 3.3], [], [4.4, 5.5]])

    # Test case 1: Check if the function returns an awkward array
    array = convert(py_array)
    @test array isa AwkwardArray.ListOffsetArray

    @test array == [[1.1, 2.2, 3.3], [], [4.4, 5.5]]
end

# Test passing Python array to Julia function
@testset "pass Python array to Julia test" begin
    function f1(x)
        x
    end

    py_array = pyimport("awkward").Array([[1.1, 2.2, 3.3], [], [4.4, 5.5]])

    array = f1(py_array)
    @test array isa AwkwardArray.ListOffsetArray
end
