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

# Test pyconvert Python Awkwar Array to Julia Awkward Array
@testset "convert     # PrimitiveArray" begin
    layout = pyimport("awkward").contents.NumpyArray(
        pyimport("numpy").array([1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9], dtype=pyimport("numpy").float64)
    )
    py_array = pyimport("awkward").Array(layout)

    array = pyconvert(AwkwardArray.PrimitiveArray, py_array)
    @test array isa AwkwardArray.PrimitiveArray
end

@testset "convert     # EmptyArray" begin
    layout = pyimport("awkward").contents.EmptyArray()
    py_array = pyimport("awkward").Array(layout)

    array = pyconvert(AwkwardArray.EmptyArray, py_array)
    @test array isa AwkwardArray.EmptyArray
end

@testset "convert     # ListOffsetArray" begin
    py_array = pyimport("awkward").Array([[1.1, 2.2, 3.3], [], [4.4, 5.5]])

    array = pyconvert(AwkwardArray.ListOffsetArray, py_array)
    @test array isa AwkwardArray.ListOffsetArray
end

@testset "convert     # ListArray" begin
    content = pyimport("awkward").contents.NumpyArray(
        pyimport("numpy").array([1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9], dtype=pyimport("numpy").float64)
    )
    starts = pyimport("awkward").index.Index64(pyimport("numpy").array([0, 3, 3, 5, 6], dtype=pyimport("numpy").int64))
    stops = pyimport("awkward").index.Index64(pyimport("numpy").array([3, 3, 5, 6, 9], dtype=pyimport("numpy").int64))
    offsets = pyimport("awkward").index.Index64(pyimport("numpy").array([0, 3, 3, 5, 6, 9], dtype=pyimport("numpy").int64))
    layout = pyimport("awkward").contents.ListArray(starts, stops, content)

    py_array = pyimport("awkward").Array(layout)

    array = pyconvert(AwkwardArray.ListArray, py_array)
    @test array isa AwkwardArray.ListArray
end

@testset "convert     # RegularArray" begin
    content = pyimport("awkward").contents.NumpyArray(
        pyimport("numpy").array([0.0, 1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9], dtype=pyimport("numpy").float64)
    )
    offsets = pyimport("awkward").index.Index64(pyimport("numpy").array([0, 3, 3, 5, 6, 10, 10], dtype=pyimport("numpy").int64))
    listoffsetarray = pyimport("awkward").contents.ListOffsetArray(offsets, content)
    regulararray = pyimport("awkward").contents.RegularArray(listoffsetarray, 2, zeros_length=0)

    py_array = pyimport("awkward").Array(regulararray)

    array = pyconvert(AwkwardArray.RegularArray, py_array)
    @test array isa AwkwardArray.RegularArray
end

@testset "convert     # RecordArray" begin
    content1 = pyimport("awkward").contents.NumpyArray(pyimport("numpy").array([1, 2, 3, 4, 5], dtype=pyimport("numpy").int64))
    content2 = pyimport("awkward").contents.NumpyArray(
        pyimport("numpy").array([1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9], dtype=pyimport("numpy").float64)
    )
    offsets = pyimport("awkward").index.Index64(pyimport("numpy").array([0, 3, 3, 5, 6, 9], dtype=pyimport("numpy").int64))
    listoffsetarray = pyimport("awkward").contents.ListOffsetArray(offsets, content2)
    recordarray = pyimport("awkward").contents.RecordArray(
        [content1, listoffsetarray, content2, content1],
        fields=["one", "two", "2", "wonky"],
    )

    py_array = pyimport("awkward").Array(recordarray)

    array = pyconvert(AwkwardArray.RecordArray, py_array)
    @test array isa AwkwardArray.RecordArray
end

@testset "convert     # TupleArray" begin
    tuplearray = pyimport("awkward").contents.RecordArray([pyimport("awkward").contents.NumpyArray(pyimport("numpy").arange(10))], pybuiltins.None)

    py_array = pyimport("awkward").Array(tuplearray)

    array = pyconvert(AwkwardArray.TupleArray, py_array)
    @test array isa AwkwardArray.TupleArray
end

@testset "convert     # IndexedArray" begin
    content = pyimport("awkward").contents.NumpyArray(pyimport("numpy").array([0.0, 1.1, 2.2, 3.3, 4.4]))

    ind = pyimport("numpy").array([2, 2, 0, 3, 4], dtype=pyimport("numpy").int32)
    index = pyimport("awkward").index.Index32(ind)
    indexedarray = pyimport("awkward").contents.IndexedArray(index, content)

    py_array = pyimport("awkward").Array(indexedarray)

    array = pyconvert(AwkwardArray.IndexedArray, py_array)
    @test array isa AwkwardArray.IndexedArray
end

@testset "convert     # IndexedOptionArray" begin
    content = pyimport("awkward").contents.NumpyArray(pyimport("numpy").array([0.0, 1.1, 2.2, 3.3, 4.4]))
    index = pyimport("awkward").index.Index64(pyimport("numpy").array([2, 2, 0, -1, 4], dtype=pyimport("numpy").int64))
    indexedoptionarray = pyimport("awkward").contents.IndexedOptionArray(index, content)

    py_array = pyimport("awkward").Array(indexedoptionarray)

    array = pyconvert(AwkwardArray.IndexedOptionArray, py_array)
    @test array isa AwkwardArray.IndexedOptionArray
end

@testset "convert     # ByteMaskedArray" begin
    layout = pyimport("awkward").contents.ByteMaskedArray(
        pyimport("awkward").index.Index8(pyimport("numpy").array([0, 1, 0, 1, 0], dtype=pyimport("numpy").int8)),
        pyimport("awkward").contents.NumpyArray(pyimport("numpy").arange(5)),
        valid_when=pybuiltins.True,
    )
    py_array = pyimport("awkward").Array(layout)

    array = pyconvert(AwkwardArray.ByteMaskedArray, py_array)
    @test array isa AwkwardArray.ByteMaskedArray
end

@testset "convert     # BitMaskedArray" begin
    content = pyimport("awkward").operations.from_iter(
        [[0.0, 1.1, 2.2], [3.3, 4.4], [5.5], [6.6, 7.7, 8.8, 9.9]], highlevel=pybuiltins.False
    )
    mask = pyimport("awkward").index.IndexU8(pyimport("numpy").array([66], dtype=pyimport("numpy").uint8))
    maskedarray = pyimport("awkward").contents.BitMaskedArray(
        mask, content, valid_when=pybuiltins.False, length=4, lsb_order=pybuiltins.True
    )
    py_array = pyimport("awkward").Array(maskedarray)

    array = pyconvert(AwkwardArray.BitMaskedArray, py_array)
    @test array isa AwkwardArray.BitMaskedArray
end

@testset "convert     # UnmaskedArray" begin
    unmaskedarray = pyimport("awkward").contents.UnmaskedArray(
        pyimport("awkward").contents.NumpyArray(
            pyimport("numpy").array([0.0, 1.1, 2.2, 3.3], dtype=pyimport("numpy").float64)
        )
    )
    py_array = pyimport("awkward").Array(unmaskedarray)

    array = pyconvert(AwkwardArray.UnmaskedArray, py_array)
    @test array isa AwkwardArray.UnmaskedArray
end

@testset "convert     # UnionArray" begin
    layout = pyimport("awkward").contents.unionarray.UnionArray(
        pyimport("awkward").index.Index(pyimport("numpy").array([1, 1, 0, 0, 1, 0, 1], dtype=pyimport("numpy").int8)),
        pyimport("awkward").index.Index(pyimport("numpy").array([4, 3, 0, 1, 2, 2, 4, 100])),
        [
            pyimport("awkward").contents.recordarray.RecordArray(
            [pyimport("awkward").from_iter(["1", "2", "3"], highlevel=pybuiltins.False)], ["nest"]
            ),
            pyimport("awkward").contents.recordarray.RecordArray(
            [
                pyimport("awkward").contents.numpyarray.NumpyArray(
                    pyimport("numpy").array([1.1, 2.2, 3.3, 4.4, 5.5])
                )
            ],
            ["nest"],
            ),
        ],
    )
    py_array = pyimport("awkward").Array(layout)

    array = pyconvert(AwkwardArray.UnionArray, py_array)
    @test array isa AwkwardArray.UnionArray
end
