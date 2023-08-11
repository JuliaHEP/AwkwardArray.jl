using AwkwardArray
using Test

@testset "AwkwardArray.jl" begin
    ### PrimitiveArray #######################################################

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

    ### ListOffsetArray ######################################################

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

    ### ListOffsetArray with behavior = :string ##############################

    begin
        layout = AwkwardArray.ListOffsetArray(
            [0, 3, 8, 9, 11, 14, 18],
            AwkwardArray.PrimitiveArray(
                [
                    0x68,
                    0x65,
                    0x79,
                    0x74,
                    0x68,
                    0x65,
                    0x72,
                    0x65,
                    0x24,
                    0xc2,
                    0xa2,
                    0xe2,
                    0x82,
                    0xac,
                    0xf0,
                    0x9f,
                    0x92,
                    0xb0,
                ],
                behavior = :char,
            ),
            behavior = :string,
        )

        @test layout[1] == "hey"
        @test layout[2] == "there"
        @test layout[3] == "\$"
        @test layout[4] == "¢"
        @test layout[5] == "€"
        @test layout[6] == "💰"

        @test Vector(layout) == ["hey", "there", "\$", "¢", "€", "💰"]
    end

    ### ListOffsetArray with behavior = :bytestring ##########################

    begin
        layout = AwkwardArray.ListOffsetArray(
            [0, 3, 8, 9, 11, 14, 18],
            AwkwardArray.PrimitiveArray(
                [
                    0x68,
                    0x65,
                    0x79,
                    0x74,
                    0x68,
                    0x65,
                    0x72,
                    0x65,
                    0x24,
                    0xc2,
                    0xa2,
                    0xe2,
                    0x82,
                    0xac,
                    0xf0,
                    0x9f,
                    0x92,
                    0xb0,
                ],
                behavior = :byte,
            ),
            behavior = :bytestring,
        )

        @test layout[1] == [0x68, 0x65, 0x79]
        @test layout[2] == [0x74, 0x68, 0x65, 0x72, 0x65]
        @test layout[3] == [0x24]
        @test layout[4] == [0xc2, 0xa2]
        @test layout[5] == [0xe2, 0x82, 0xac]
        @test layout[6] == [0xf0, 0x9f, 0x92, 0xb0]
    end

    ### ListOffsetArray with other parameters ################################

    begin
        layout = AwkwardArray.ListOffsetArray(
            [0, 3, 3, 8],
            AwkwardArray.PrimitiveArray([0x68, 0x65, 0x79, 0x74, 0x68, 0x65, 0x72, 0x65],),
            parameters = AwkwardArray.Parameters("__doc__" => "nice list"),
        )

        @test AwkwardArray.get_parameter(layout, "__doc__") == "nice list"
        @test !AwkwardArray.has_parameter(layout, "__list__")
    end

    begin
        layout = AwkwardArray.ListOffsetArray(
            [0, 3, 3, 8],
            AwkwardArray.PrimitiveArray(
                [0x68, 0x65, 0x79, 0x74, 0x68, 0x65, 0x72, 0x65],
                behavior = :char,
            ),
            parameters = AwkwardArray.Parameters("__doc__" => "nice string"),
            behavior = :string,
        )

        @test AwkwardArray.get_parameter(layout, "__doc__") == "nice string"
        @test !AwkwardArray.has_parameter(layout, "__list__")
    end

    ### RecordArray ##########################################################

    begin
        layout = AwkwardArray.RecordArray(
            NamedTuple{(:a, :b)}((
                AwkwardArray.PrimitiveArray([1, 2, 3, 4, 5]),
                AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
            )),
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 5
        @test layout[3][:a] == 3
        @test layout[3][:b] == 3.3

        @test layout == layout
        @test layout[3] == layout[3]

        tmp = 0.0
        for x in layout
            @test x[:b] < 6
            tmp += x[:b]
        end
        @test tmp == 16.5
    end

    begin
        layout = AwkwardArray.RecordArray(
            NamedTuple{(:a, :b)}((
                AwkwardArray.PrimitiveArray([1, 2, 3]),
                AwkwardArray.ListOffsetArray(
                    [0, 3, 3, 5],
                    AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
                ),
            )),
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 3
        @test layout[3][:a] == 3
        @test layout[3][:b][1] == 4.4

        @test layout == layout
        @test layout[3] == layout[3]
        @test layout[1][:b] == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3])
        @test layout[2][:b] == AwkwardArray.PrimitiveArray([])
        @test layout[3][:b] == AwkwardArray.PrimitiveArray([4.4, 5.5])

        tmp = 0.0
        for x in layout
            for y in x[:b]
                @test y < 6
                tmp += y
            end
        end
        @test tmp == 16.5
    end

end
