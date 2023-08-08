using AwkwardArray
using Test

@testset "AwkwardArray.jl" begin
    begin
        layout = AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5])
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 5
        @test layout[2] == 2.2
        @test layout[end] == 5.5
        @test layout[end-1] == 4.4
        @test layout[2:4] == AwkwardArray.PrimitiveArray([2.2, 3.3, 4.4])
        tmp = 0.0
        for x in layout
            @test x < 6
            tmp += x
        end
        @test tmp == 16.5
    end

    begin
        layout = AwkwardArray.ListOffsetArray(
            [0, 3, 3, 5],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 3
        @test layout[1] == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3])
        @test layout[end-1] == AwkwardArray.PrimitiveArray([])
        @test layout[end] == AwkwardArray.PrimitiveArray([4.4, 5.5])
        @test layout[1:2] == AwkwardArray.ListOffsetArray(
            [0, 3, 3],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3]),
        )
        tmp = 0
        for x in layout
            @test length(x) <= 3
            tmp += length(x)
        end
        @test tmp == 5
    end
end
