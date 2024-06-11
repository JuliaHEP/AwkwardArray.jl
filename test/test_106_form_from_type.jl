using AwkwardArray

@testset "Form from type" begin
    begin
        form = AwkwardArray.type_to_form(Int, 1)
        @test form == """{"class": "NumpyArray", "primitive": "int64", "form_key": "node1"}"""
    end
end