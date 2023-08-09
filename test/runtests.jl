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
        layout = AwkwardArray.PrimitiveArray{Float64}()
        @test length(layout) == 0
        AwkwardArray.push!(layout, 1.1)
        @test length(layout) == 1
        AwkwardArray.push!(layout, 2.2)
        @test length(layout) == 2
        AwkwardArray.push!(layout, 3.3)
        @test length(layout) == 3
        AwkwardArray.push!(layout, 4.4)
        @test length(layout) == 4
        AwkwardArray.push!(layout, 5.5)
        @test length(layout) == 5
        @test layout == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5])
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

    begin
        layout = AwkwardArray.ListOffsetArray(
            [0, 3, 2, 5],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )
        @test !AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.ListOffsetArray(
            [0, 3, 3, 6],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )
        @test !AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.ListOffsetArray(
            [-1, 3, 3, 5],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )
        @test !AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.ListOffsetArray{
            AwkwardArray.Index64,
            AwkwardArray.PrimitiveArray{Float64},
        }()
        sublayout = layout.content
        @test length(layout) == 0
        AwkwardArray.push!(sublayout, 1.1)
        AwkwardArray.push!(sublayout, 2.2)
        AwkwardArray.push!(sublayout, 3.3)
        AwkwardArray.end_list!(layout)
        @test length(layout) == 1
        AwkwardArray.end_list!(layout)
        @test length(layout) == 2
        AwkwardArray.push!(sublayout, 4.4)
        AwkwardArray.push!(sublayout, 5.5)
        AwkwardArray.end_list!(layout)
        @test length(layout) == 3
        @test layout == AwkwardArray.ListOffsetArray(
            [0, 3, 3, 5],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )
    end

end
