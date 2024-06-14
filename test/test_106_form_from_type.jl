
@testset "Form from type" begin

    @test AwkwardArray.type_to_form(Bool, 1) == """{"class": "NumpyArray", "primitive": "bool", "form_key": "node1"}"""
    @test AwkwardArray.type_to_form(Int, 1) == """{"class": "NumpyArray", "primitive": "int64", "form_key": "node1"}"""
    @test AwkwardArray.type_to_form(Int32, 1) == """{"class": "NumpyArray", "primitive": "int32", "form_key": "node1"}"""
    @test AwkwardArray.type_to_form(Int32, 0) == """{"class": "NumpyArray", "primitive": "int32", "form_key": "node0"}"""
    @test AwkwardArray.type_to_form(Int64, 1) == "{\"class\": \"NumpyArray\", \"primitive\": \"int64\", \"form_key\": \"node1\"}"
    @test AwkwardArray.type_to_form(Char, 1) == "{\"class\": \"NumpyArray\", \"primitive\": \"uint8\", \"parameters\": { \"__array__\": \"char\" }, \"form_key\": \"node1\"}"
    @test AwkwardArray.type_to_form(String, 1) == "{\"class\": \"ListOffsetArray\", \"offsets\": \"int64\", \"content\": {\"class\": \"NumpyArray\", \"primitive\": \"uint8\", \"parameters\": { \"__array__\": \"char\" }, \"form_key\": \"node2\"},  \"parameters\": { \"__array__\": \"string\" }, \"form_key\": \"node1\"}"
    
    @test AwkwardArray.type_to_form(Vector{Int}, 1) == "{\"class\": \"ListOffsetArray\", \"offsets\": \"int64\", \"content\": {\"class\": \"NumpyArray\", \"primitive\": \"int64\", \"form_key\": \"node2\"}, \"form_key\": \"node1\"}"
    @test AwkwardArray.type_to_form(Vector{Int32}, 1) == """{"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "NumpyArray", "primitive": "int32", "form_key": "node2"}, "form_key": "node1"}"""
    @test AwkwardArray.type_to_form(Vector{Int64}, 1) == """{"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "NumpyArray", "primitive": "int64", "form_key": "node2"}, "form_key": "node1"}"""
    @test AwkwardArray.type_to_form(Vector{Float32}, 1) == """{"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "NumpyArray", "primitive": "float32", "form_key": "node2"}, "form_key": "node1"}"""
    @test AwkwardArray.type_to_form(Vector{Float64}, 1) == """{"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "NumpyArray", "primitive": "float64", "form_key": "node2"}, "form_key": "node1"}"""

    @test AwkwardArray.type_to_form(Vector{Vector{Int}}, 0)     == """{"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "NumpyArray", "primitive": "int64", "form_key": "node2"}, "form_key": "node1"}, "form_key": "node0"}"""
    @test AwkwardArray.type_to_form(Vector{Vector{Int32}}, 0)   == """{"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "NumpyArray", "primitive": "int32", "form_key": "node2"}, "form_key": "node1"}, "form_key": "node0"}"""
    @test AwkwardArray.type_to_form(Vector{Vector{Int64}}, 0)   == """{"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "NumpyArray", "primitive": "int64", "form_key": "node2"}, "form_key": "node1"}, "form_key": "node0"}"""
    @test AwkwardArray.type_to_form(Vector{Vector{Float32}}, 0) == """{"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "NumpyArray", "primitive": "float32", "form_key": "node2"}, "form_key": "node1"}, "form_key": "node0"}"""
    @test AwkwardArray.type_to_form(Vector{Vector{Float64}}, 0) == """{"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "NumpyArray", "primitive": "float64", "form_key": "node2"}, "form_key": "node1"}, "form_key": "node0"}"""

    @test AwkwardArray.type_to_form(SubArray{Int32, 1, nothing}, 1) == "{\"class\": \"ListOffsetArray\", \"offsets\": \"int64\", \"content\": {\"class\": \"NumpyArray\", \"primitive\": \"int32\", \"form_key\": \"node2\"}, \"form_key\": \"node1\"}"

end

@testset "Form from type with an id reference" begin
    id = 1
    id_ref = Ref(id)

    @test AwkwardArray.type_to_form(Bool, id_ref) == """{"class": "NumpyArray", "primitive": "bool", "form_key": "node1"}"""
    @test AwkwardArray.type_to_form(Int, id_ref) == """{"class": "NumpyArray", "primitive": "int64", "form_key": "node2"}"""
    @test AwkwardArray.type_to_form(Int32, id_ref) == """{"class": "NumpyArray", "primitive": "int32", "form_key": "node3"}"""
    @test AwkwardArray.type_to_form(Int32, id_ref) == """{"class": "NumpyArray", "primitive": "int32", "form_key": "node4"}"""
    @test AwkwardArray.type_to_form(Int64, id_ref) == "{\"class\": \"NumpyArray\", \"primitive\": \"int64\", \"form_key\": \"node5\"}"
    @test AwkwardArray.type_to_form(Char, id_ref) == "{\"class\": \"NumpyArray\", \"primitive\": \"uint8\", \"parameters\": { \"__array__\": \"char\" }, \"form_key\": \"node6\"}"
    @test AwkwardArray.type_to_form(String, id_ref) == "{\"class\": \"ListOffsetArray\", \"offsets\": \"int64\", \"content\": {\"class\": \"NumpyArray\", \"primitive\": \"uint8\", \"parameters\": { \"__array__\": \"char\" }, \"form_key\": \"node8\"},  \"parameters\": { \"__array__\": \"string\" }, \"form_key\": \"node7\"}"
    
    @test AwkwardArray.type_to_form(Vector{Int}, id_ref) == "{\"class\": \"ListOffsetArray\", \"offsets\": \"int64\", \"content\": {\"class\": \"NumpyArray\", \"primitive\": \"int64\", \"form_key\": \"node10\"}, \"form_key\": \"node9\"}"
    @test AwkwardArray.type_to_form(Vector{Int32}, id_ref) == """{"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "NumpyArray", "primitive": "int32", "form_key": "node12"}, "form_key": "node11"}"""
    @test AwkwardArray.type_to_form(Vector{Int64}, id_ref) == """{"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "NumpyArray", "primitive": "int64", "form_key": "node14"}, "form_key": "node13"}"""
    @test AwkwardArray.type_to_form(Vector{Float32}, id_ref) == """{"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "NumpyArray", "primitive": "float32", "form_key": "node16"}, "form_key": "node15"}"""
    @test AwkwardArray.type_to_form(Vector{Float64}, id_ref) == """{"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "NumpyArray", "primitive": "float64", "form_key": "node18"}, "form_key": "node17"}"""

    @test AwkwardArray.type_to_form(Vector{Vector{Int}}, id_ref)     == """{"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "NumpyArray", "primitive": "int64", "form_key": "node21"}, "form_key": "node20"}, "form_key": "node19"}"""
    @test AwkwardArray.type_to_form(Vector{Vector{Int32}}, id_ref)   == """{"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "NumpyArray", "primitive": "int32", "form_key": "node24"}, "form_key": "node23"}, "form_key": "node22"}"""
    @test AwkwardArray.type_to_form(Vector{Vector{Int64}}, id_ref)   == """{"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "NumpyArray", "primitive": "int64", "form_key": "node27"}, "form_key": "node26"}, "form_key": "node25"}"""
    @test AwkwardArray.type_to_form(Vector{Vector{Float32}}, id_ref) == """{"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "NumpyArray", "primitive": "float32", "form_key": "node30"}, "form_key": "node29"}, "form_key": "node28"}"""
    @test AwkwardArray.type_to_form(Vector{Vector{Float64}}, id_ref) == """{"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "ListOffsetArray", "offsets": "int64", "content": {"class": "NumpyArray", "primitive": "float64", "form_key": "node33"}, "form_key": "node32"}, "form_key": "node31"}"""

    @test AwkwardArray.type_to_form(SubArray{Int32, 1, nothing}, id_ref) == "{\"class\": \"ListOffsetArray\", \"offsets\": \"int64\", \"content\": {\"class\": \"NumpyArray\", \"primitive\": \"int32\", \"form_key\": \"node35\"}, \"form_key\": \"node34\"}"

end

@testset "type_to_form error tests" begin
    try
        AwkwardArray.type_to_form(Any, 1)
        @test false  # This line should never be reached
    catch e
        @test isa(e, ErrorException)
        @test occursin("Type 'Any' is not supported yet.", e.msg)
    end

    try
        AwkwardArray.type_to_form(Nothing, 1)
        @test false  # This line should never be reached
    catch e
        @test isa(e, ErrorException)
        @test occursin("Type 'Nothing' is not supported yet.", e.msg)
    end
end

@testset "Key generate" begin
    begin
        id = 1
        id_ref = Ref(id)
        node_key = AwkwardArray._generate_form_key!(id_ref)
        @test node_key == "node1"
        @test id_ref[] == 2
    end
end

@testset "tree_branches_type tests" begin
    mutable struct TestTree
        field1::Vector{Int}
        field2::Vector{Int}
    end
        
    tree = TestTree([1, 2, 3], [4, 5, 6])
    expected_form = """{"class": "RecordArray", "fields": [field1, field2], "contents": [{"class": "NumpyArray", "primitive": "int64", "form_key": "node0"}, {"class": "NumpyArray", "primitive": "int64", "form_key": "node1"}], "parameters": {}, "form_key": "node2"}"""
    @test AwkwardArray.tree_branches_type(tree) == expected_form
end
