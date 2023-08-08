using AwkwardArray
using Test

@testset "AwkwardArray.jl" begin
    layout_PrimitiveArray = AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5])

    @test length(layout_PrimitiveArray) == 5
end
