using AwkwardArray: type_to_form

@testset "Form from type" begin
    begin
        id = 1
        ref = Ref(id)
        out = AwkwardArray.generate_form_key!(ref)
        @test out == "node1"
    end
    begin
        form = type_to_form(Int, 1)
        @test form == """{"class": "NumpyArray", "primitive": "int64", "form_key": "node1"}"""
    end
    begin
        form = type_to_form(Int32, 1)
        @test form == """{"class": "NumpyArray", "primitive": "int32", "form_key": "node1"}"""
    end
    begin
        form = type_to_form(Vector{Int32}, 1)
        @test form == """{"class": "ListOffsetArray", "offsets": "int64", "content":{"class": "NumpyArray", "primitive": "int64", "form_key": "node2"}, "form_key": "node1"}"""
    end
end