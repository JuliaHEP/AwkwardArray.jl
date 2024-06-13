
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
end

@testset "Key generate" begin
    begin
        id = 1
        ref = Ref(id)
        out = AwkwardArray._generate_form_key!(ref)
        @test out == "node1"
        @test ref[] == 2
    end
end
