using AwkwardArray
using Test

@testset "AwkwardArray.jl" begin
    # ### PrimitiveArray #######################################################

    # begin
    #     layout = AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5])
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 5
    #     @test layout[2] == 2.2
    #     @test layout[end] == 5.5
    #     @test layout[end-1] == 4.4
    #     @test layout[2:4] == AwkwardArray.PrimitiveArray([2.2, 3.3, 4.4])
    #     tmp = 0.0
    #     for x in layout
    #         @test x < 6
    #         tmp += x
    #     end
    #     @test tmp == 16.5

    #     @inferred layout[2]
    #     @inferred layout[2:4]

    #     @test AwkwardArray.to_vector(layout) == [1.1, 2.2, 3.3, 4.4, 5.5]
    # end

    # begin
    #     layout = AwkwardArray.PrimitiveArray{Float64}()
    #     @test length(layout) == 0
    #     push!(layout, 1.1)
    #     @test length(layout) == 1
    #     push!(layout, 2.2)
    #     @test length(layout) == 2
    #     push!(layout, 3.3)
    #     @test length(layout) == 3
    #     push!(layout, 4.4)
    #     @test length(layout) == 4
    #     push!(layout, 5.5)
    #     @test length(layout) == 5
    #     @test layout == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5])

    #     AwkwardArray.push_dummy!(layout)
    #     @test length(layout) == 6
    #     @test layout == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5, 0.0])
    #     @test AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.PrimitiveArray{Int32}()

    #     push!(layout, 1)
    #     @test layout == AwkwardArray.PrimitiveArray(Vector{Int32}([1]))

    #     append!(layout, Vector{Int64}([2, 3]))
    #     @test layout == AwkwardArray.PrimitiveArray(Vector{Int32}([1, 2, 3]))

    #     append!(layout, Vector{Int16}([4, 5]))
    #     @test layout == AwkwardArray.PrimitiveArray(Vector{Int32}([1, 2, 3, 4, 5]))
    # end

    # begin
    #     layout = AwkwardArray.PrimitiveArray{Float32}()

    #     push!(layout, 1)
    #     @test layout == AwkwardArray.PrimitiveArray(Vector{Float32}([1.0]))

    #     append!(layout, Vector{Int64}([2, 3]))
    #     @test layout == AwkwardArray.PrimitiveArray(Vector{Float32}([1.0, 2.0, 3.0]))

    #     append!(layout, Vector{Int16}([4, 5]))
    #     @test layout ==
    #           AwkwardArray.PrimitiveArray(Vector{Float32}([1.0, 2.0, 3.0, 4.0, 5.0]))

    #     push!(layout, 3.14)
    #     @test layout ==
    #           AwkwardArray.PrimitiveArray(Vector{Float32}([1.0, 2.0, 3.0, 4.0, 5.0, 3.14]))

    #     append!(layout, Vector{Float64}([2.71]))
    #     @test layout == AwkwardArray.PrimitiveArray(
    #         Vector{Float32}([1.0, 2.0, 3.0, 4.0, 5.0, 3.14, 2.71]),
    #     )
    # end

    # ### EmptyArray ###########################################################

    # begin
    #     layout = AwkwardArray.EmptyArray()
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 0
    #     @test layout[100:99] == layout
    #     tmp = 0.0
    #     for x in layout
    #         tmp += x
    #     end
    #     @test tmp == 0.0
    #     @test layout == AwkwardArray.PrimitiveArray(Vector{Float64}())

    #     @test AwkwardArray.to_vector(layout) == []
    # end

    # begin
    #     layout = AwkwardArray.EmptyArray()
    #     @test length(layout) == 0
    #     @test layout == AwkwardArray.EmptyArray()
    # end

    # begin
    #     layout = AwkwardArray.EmptyArray()
    #     append!(layout, [])
    #     append!(layout, Vector{Int64}([]))
    # end

    # ### ListOffsetArray ######################################################

    # begin
    #     layout = AwkwardArray.ListOffsetArray(
    #         [0, 3, 3, 5],
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #     )
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 3
    #     @test layout[1] == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3])
    #     @test layout[end-1] == AwkwardArray.PrimitiveArray([])
    #     @test layout[end] == AwkwardArray.PrimitiveArray([4.4, 5.5])
    #     @test layout[1:2] == AwkwardArray.ListOffsetArray(
    #         [0, 3, 3],
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3]),
    #     )
    #     tmp = 0
    #     for x in layout
    #         @test length(x) <= 3
    #         tmp += length(x)
    #     end
    #     @test tmp == 5

    #     @inferred layout[1]
    #     @inferred layout[1][1]
    #     @inferred layout[1:2]

    #     @test AwkwardArray.to_vector(layout) == [[1.1, 2.2, 3.3], [], [4.4, 5.5]]
    # end

    # begin
    #     layout = AwkwardArray.ListOffsetArray(
    #         [0, 3, 2, 5],
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #     )
    #     @test !AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.ListOffsetArray(
    #         [0, 3, 3, 6],
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #     )
    #     @test !AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.ListOffsetArray(
    #         [-1, 3, 3, 5],
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #     )
    #     @test !AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.ListOffsetArray{
    #         AwkwardArray.Index64,
    #         AwkwardArray.PrimitiveArray{Float64},
    #     }()
    #     sublayout = layout.content
    #     @test length(layout) == 0
    #     push!(sublayout, 1.1)
    #     push!(sublayout, 2.2)
    #     push!(sublayout, 3.3)
    #     AwkwardArray.end_list!(layout)
    #     @test length(layout) == 1
    #     AwkwardArray.end_list!(layout)
    #     @test length(layout) == 2
    #     push!(sublayout, 4.4)
    #     push!(sublayout, 5.5)
    #     AwkwardArray.end_list!(layout)
    #     @test length(layout) == 3
    #     @test layout == AwkwardArray.ListOffsetArray(
    #         [0, 3, 3, 5],
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #     )

    #     AwkwardArray.push_dummy!(layout)
    #     @test length(layout) == 4
    #     @test layout == AwkwardArray.ListOffsetArray(
    #         [0, 3, 3, 5, 5],
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #     )
    #     @test AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.ListOffsetArray{
    #         AwkwardArray.Index64,
    #         AwkwardArray.PrimitiveArray{Int64},
    #     }()

    #     push!(layout, [1, 2, 3])
    #     @test layout ==
    #           AwkwardArray.ListOffsetArray([0, 3], AwkwardArray.PrimitiveArray([1, 2, 3]))

    #     push!(layout, Vector{Int64}([]))
    #     @test layout == AwkwardArray.ListOffsetArray(
    #         [0, 3, 3],
    #         AwkwardArray.PrimitiveArray([1, 2, 3]),
    #     )

    #     push!(layout, [4, 5])
    #     @test layout == AwkwardArray.ListOffsetArray(
    #         [0, 3, 3, 5],
    #         AwkwardArray.PrimitiveArray([1, 2, 3, 4, 5]),
    #     )

    #     append!(layout, [[], [6, 7, 8, 9]])
    #     @test layout == AwkwardArray.ListOffsetArray(
    #         [0, 3, 3, 5, 5, 9],
    #         AwkwardArray.PrimitiveArray([1, 2, 3, 4, 5, 6, 7, 8, 9]),
    #     )
    # end

    # ### ListArray ######################################################

    # begin
    #     layout = AwkwardArray.ListArray(
    #         [0, 3, 3],
    #         [3, 3, 5],
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #     )
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 3
    #     @test layout[1] == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3])
    #     @test layout[end-1] == AwkwardArray.PrimitiveArray([])
    #     @test layout[end] == AwkwardArray.PrimitiveArray([4.4, 5.5])
    #     @test layout[1:2] == AwkwardArray.ListArray(
    #         [0, 3],
    #         [3, 3],
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3]),
    #     )
    #     tmp = 0
    #     for x in layout
    #         @test length(x) <= 3
    #         tmp += length(x)
    #     end
    #     @test tmp == 5

    #     @inferred layout[1]
    #     @inferred layout[1][1]
    #     @inferred layout[1:2]

    #     @test AwkwardArray.to_vector(layout) == [[1.1, 2.2, 3.3], [], [4.4, 5.5]]
    # end

    # begin
    #     layout = AwkwardArray.ListArray(
    #         [0, 3, 2],
    #         [3, 2, 5],
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #     )
    #     @test !AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.ListArray(
    #         [0, 3, 3],
    #         [3, 3, 6],
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #     )
    #     @test !AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.ListArray(
    #         [-1, 3, 3],
    #         [3, 3, 5],
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #     )
    #     @test !AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.ListArray{
    #         AwkwardArray.Index64,
    #         AwkwardArray.PrimitiveArray{Float64},
    #     }()
    #     sublayout = layout.content
    #     @test length(layout) == 0
    #     push!(sublayout, 1.1)
    #     push!(sublayout, 2.2)
    #     push!(sublayout, 3.3)
    #     AwkwardArray.end_list!(layout)
    #     @test length(layout) == 1
    #     AwkwardArray.end_list!(layout)
    #     @test length(layout) == 2
    #     push!(sublayout, 4.4)
    #     push!(sublayout, 5.5)
    #     AwkwardArray.end_list!(layout)
    #     @test length(layout) == 3
    #     @test layout == AwkwardArray.ListArray(
    #         [0, 3, 3],
    #         [3, 3, 5],
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #     )

    #     AwkwardArray.push_dummy!(layout)
    #     @test length(layout) == 4
    #     @test layout == AwkwardArray.ListArray(
    #         [0, 3, 3, 5],
    #         [3, 3, 5, 5],
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #     )
    #     @test AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout =
    #         AwkwardArray.ListArray{AwkwardArray.Index64,AwkwardArray.PrimitiveArray{Int64}}()

    #     push!(layout, [1, 2, 3])
    #     @test layout ==
    #           AwkwardArray.ListArray([0], [3], AwkwardArray.PrimitiveArray([1, 2, 3]))

    #     push!(layout, Vector{Int64}([]))
    #     @test layout ==
    #           AwkwardArray.ListArray([0, 3], [3, 3], AwkwardArray.PrimitiveArray([1, 2, 3]))

    #     push!(layout, [4, 5])
    #     @test layout == AwkwardArray.ListArray(
    #         [0, 3, 3],
    #         [3, 3, 5],
    #         AwkwardArray.PrimitiveArray([1, 2, 3, 4, 5]),
    #     )

    #     append!(layout, [[], [6, 7, 8, 9]])
    #     @test layout == AwkwardArray.ListArray(
    #         [0, 3, 3, 5, 5],
    #         [3, 3, 5, 5, 9],
    #         AwkwardArray.PrimitiveArray([1, 2, 3, 4, 5, 6, 7, 8, 9]),
    #     )
    # end

    # ### RegularArray #########################################################

    # begin
    #     layout = AwkwardArray.RegularArray(
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5, 6.6]),
    #         3,
    #     )
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 2
    #     @test layout[1] == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3])
    #     @test layout[2] == AwkwardArray.PrimitiveArray([4.4, 5.5, 6.6])
    #     @test layout[end] == AwkwardArray.PrimitiveArray([4.4, 5.5, 6.6])

    #     @inferred layout[1]
    #     @inferred layout[1][1]
    #     @inferred layout[1:2]

    #     @test AwkwardArray.to_vector(layout) == [[1.1, 2.2, 3.3], [4.4, 5.5, 6.6]]
    # end

    # begin
    #     layout = AwkwardArray.RegularArray(AwkwardArray.PrimitiveArray(0:29), 5)
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 6
    #     @test AwkwardArray.to_vector(layout[1]) == [0, 1, 2, 3, 4]
    #     @test AwkwardArray.to_vector(layout[2]) == [5, 6, 7, 8, 9]
    #     @test AwkwardArray.to_vector(layout) == [
    #         [0, 1, 2, 3, 4],
    #         [5, 6, 7, 8, 9],
    #         [10, 11, 12, 13, 14],
    #         [15, 16, 17, 18, 19],
    #         [20, 21, 22, 23, 24],
    #         [25, 26, 27, 28, 29],
    #     ]
    #     @test AwkwardArray.to_vector(layout[1:6]) == [
    #         [0, 1, 2, 3, 4],
    #         [5, 6, 7, 8, 9],
    #         [10, 11, 12, 13, 14],
    #         [15, 16, 17, 18, 19],
    #         [20, 21, 22, 23, 24],
    #         [25, 26, 27, 28, 29],
    #     ]
    #     @test AwkwardArray.to_vector(layout[2:6]) == [
    #         [5, 6, 7, 8, 9],
    #         [10, 11, 12, 13, 14],
    #         [15, 16, 17, 18, 19],
    #         [20, 21, 22, 23, 24],
    #         [25, 26, 27, 28, 29],
    #     ]
    #     @test AwkwardArray.to_vector(layout[2:5]) == [
    #         [5, 6, 7, 8, 9],
    #         [10, 11, 12, 13, 14],
    #         [15, 16, 17, 18, 19],
    #         [20, 21, 22, 23, 24],
    #     ]
    #     @test AwkwardArray.to_vector(layout[3:5]) ==
    #           [[10, 11, 12, 13, 14], [15, 16, 17, 18, 19], [20, 21, 22, 23, 24]]
    # end

    # begin
    #     layout = AwkwardArray.RegularArray(
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5, 6.6]),
    #         2,
    #     )
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 3
    #     @test layout[1] == AwkwardArray.PrimitiveArray([1.1, 2.2])
    #     @test layout[2] == AwkwardArray.PrimitiveArray([3.3, 4.4])
    #     @test layout[3] == AwkwardArray.PrimitiveArray([5.5, 6.6])
    #     @test layout[end] == AwkwardArray.PrimitiveArray([5.5, 6.6])
    #     @test layout[1:2] == AwkwardArray.RegularArray(
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4]),
    #         2,
    #     )
    #     @test layout[2:3] == AwkwardArray.RegularArray(
    #         AwkwardArray.PrimitiveArray([3.3, 4.4, 5.5, 6.6]),
    #         2,
    #     )
    #     @test layout[2:2] ==
    #           AwkwardArray.RegularArray(AwkwardArray.PrimitiveArray([3.3, 4.4]), 2)
    # end

    # begin
    #     layout = AwkwardArray.RegularArray(
    #         AwkwardArray.PrimitiveArray{Float64}(),
    #         0,
    #         zeros_length = 5,
    #     )
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 5
    #     @test layout.size == 0
    # end

    # begin
    #     layout = AwkwardArray.RegularArray{AwkwardArray.PrimitiveArray{Float64}}()
    #     sublayout = layout.content
    #     @test length(layout) == 0
    #     push!(sublayout, 1.1)
    #     push!(sublayout, 2.2)
    #     push!(sublayout, 3.3)
    #     AwkwardArray.end_list!(layout)
    #     @test length(layout) == 1
    #     @test layout.size == 3
    #     push!(sublayout, 4.4)
    #     push!(sublayout, 5.5)
    #     push!(sublayout, 6.6)
    #     AwkwardArray.end_list!(layout)
    #     @test length(layout) == 2
    #     @test layout == AwkwardArray.RegularArray(
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5, 6.6]),
    #         3,
    #     )

    #     AwkwardArray.push_dummy!(layout)
    #     @test length(layout) == 3
    #     @test layout == AwkwardArray.RegularArray(
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 0.0, 0.0, 0.0]),
    #         3,
    #     )
    #     @test AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.RegularArray{AwkwardArray.PrimitiveArray{Float64}}()
    #     sublayout = layout.content
    #     @test length(layout) == 0
    #     push!(sublayout, 1.1)
    #     push!(sublayout, 2.2)
    #     AwkwardArray.end_list!(layout)
    #     @test length(layout) == 1
    #     @test layout.size == 2
    #     push!(sublayout, 3.3)
    #     push!(sublayout, 4.4)
    #     AwkwardArray.end_list!(layout)
    #     @test length(layout) == 2
    #     push!(sublayout, 5.5)
    #     push!(sublayout, 6.6)
    #     AwkwardArray.end_list!(layout)
    #     @test length(layout) == 3
    #     @test layout == AwkwardArray.RegularArray(
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5, 6.6]),
    #         2,
    #     )

    #     AwkwardArray.push_dummy!(layout)
    #     @test length(layout) == 4
    #     @test layout == AwkwardArray.RegularArray(
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 0.0, 0.0]),
    #         2,
    #     )
    #     @test AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.RegularArray{AwkwardArray.PrimitiveArray{Float64}}()
    #     sublayout = layout.content
    #     AwkwardArray.end_list!(layout)
    #     AwkwardArray.end_list!(layout)
    #     AwkwardArray.end_list!(layout)
    #     AwkwardArray.end_list!(layout)
    #     AwkwardArray.end_list!(layout)
    #     @test length(layout) == 5
    #     @test layout == AwkwardArray.RegularArray(
    #         AwkwardArray.PrimitiveArray{Float64}(),
    #         0,
    #         zeros_length = 5,
    #     )
    # end

    # begin
    #     layout = AwkwardArray.RegularArray{AwkwardArray.PrimitiveArray{Int64}}()

    #     push!(layout, [1, 2, 3])
    #     @test layout == AwkwardArray.RegularArray(AwkwardArray.PrimitiveArray([1, 2, 3]), 3)

    #     push!(layout, [4, 5, 6])
    #     @test layout ==
    #           AwkwardArray.RegularArray(AwkwardArray.PrimitiveArray([1, 2, 3, 4, 5, 6]), 3)

    #     append!(layout, [[7, 8, 9], [10, 11, 12]])
    #     @test layout == AwkwardArray.RegularArray(
    #         AwkwardArray.PrimitiveArray([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]),
    #         3,
    #     )
    # end

    # ### ListType with behavior = :string #####################################

    # begin
    #     AwkwardArray.is_valid(AwkwardArray.StringOffsetArray([0, 3, 3, 6], "onetwo"))
    #     AwkwardArray.is_valid(AwkwardArray.StringOffsetArray())

    #     AwkwardArray.is_valid(AwkwardArray.StringArray([0, 3, 3], [3, 3, 6], "onetwo"))
    #     AwkwardArray.is_valid(AwkwardArray.StringArray())

    #     AwkwardArray.is_valid(AwkwardArray.StringRegularArray("onetwo", 3))
    #     AwkwardArray.is_valid(AwkwardArray.StringRegularArray(3))
    #     AwkwardArray.is_valid(AwkwardArray.StringRegularArray())
    # end

    # begin
    #     layout = AwkwardArray.StringOffsetArray([0, 3, 8, 9, 11, 14, 18], "heythere\$¢€💰")
    #     @inferred layout[1]
    #     @inferred layout[1][1]
    #     @inferred layout[1:2]

    #     @test AwkwardArray.to_vector(layout) == ["hey", "there", "\$", "¢", "€", "💰"]
    # end

    # begin
    #     layout = AwkwardArray.StringArray(
    #         [0, 3, 8, 9, 11, 14],
    #         [3, 8, 9, 11, 14, 18],
    #         "heythere\$¢€💰",
    #     )
    #     @inferred layout[1]
    #     @inferred layout[1][1]
    #     @inferred layout[1:2]

    #     @test AwkwardArray.to_vector(layout) == ["hey", "there", "\$", "¢", "€", "💰"]
    # end

    # begin
    #     layout = AwkwardArray.StringRegularArray("heyyou", 3)
    #     @inferred layout[1]
    #     @inferred layout[1][1]
    #     @inferred layout[1:2]

    #     @test AwkwardArray.to_vector(layout) == ["hey", "you"]
    # end

    # begin
    #     layout = AwkwardArray.ListOffsetArray(
    #         [0, 3, 8, 9, 11, 14, 18],
    #         AwkwardArray.PrimitiveArray(
    #             [
    #                 0x68,
    #                 0x65,
    #                 0x79,
    #                 0x74,
    #                 0x68,
    #                 0x65,
    #                 0x72,
    #                 0x65,
    #                 0x24,
    #                 0xc2,
    #                 0xa2,
    #                 0xe2,
    #                 0x82,
    #                 0xac,
    #                 0xf0,
    #                 0x9f,
    #                 0x92,
    #                 0xb0,
    #             ],
    #             behavior = :char,
    #         ),
    #         behavior = :string,
    #     )

    #     @test layout[1] == "hey"
    #     @test layout[2] == "there"
    #     @test layout[3] == "\$"
    #     @test layout[4] == "¢"
    #     @test layout[5] == "€"
    #     @test layout[6] == "💰"

    #     @test Vector(layout) == ["hey", "there", "\$", "¢", "€", "💰"]

    #     AwkwardArray.push_dummy!(layout)
    #     @test Vector(layout) == ["hey", "there", "\$", "¢", "€", "💰", ""]
    #     @test AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.ListArray(
    #         [0, 3, 8, 9, 11, 14],
    #         [3, 8, 9, 11, 14, 18],
    #         AwkwardArray.PrimitiveArray(
    #             [
    #                 0x68,
    #                 0x65,
    #                 0x79,
    #                 0x74,
    #                 0x68,
    #                 0x65,
    #                 0x72,
    #                 0x65,
    #                 0x24,
    #                 0xc2,
    #                 0xa2,
    #                 0xe2,
    #                 0x82,
    #                 0xac,
    #                 0xf0,
    #                 0x9f,
    #                 0x92,
    #                 0xb0,
    #             ],
    #             behavior = :char,
    #         ),
    #         behavior = :string,
    #     )

    #     @test layout[1] == "hey"
    #     @test layout[2] == "there"
    #     @test layout[3] == "\$"
    #     @test layout[4] == "¢"
    #     @test layout[5] == "€"
    #     @test layout[6] == "💰"

    #     @test Vector(layout) == ["hey", "there", "\$", "¢", "€", "💰"]

    #     AwkwardArray.push_dummy!(layout)
    #     @test Vector(layout) == ["hey", "there", "\$", "¢", "€", "💰", ""]
    #     @test AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.RegularArray(
    #         AwkwardArray.PrimitiveArray(
    #             [0x6f, 0x6e, 0x65, 0x74, 0x77, 0x6f],
    #             behavior = :char,
    #         ),
    #         3,
    #         behavior = :string,
    #     )

    #     @test layout[1] == "one"
    #     @test layout[2] == "two"

    #     @test Vector(layout) == ["one", "two"]

    #     AwkwardArray.push_dummy!(layout)
    #     @test Vector(layout) == ["one", "two", "\0\0\0"]
    #     @test AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.StringOffsetArray()

    #     push!(layout, "one")
    #     @test layout == AwkwardArray.StringOffsetArray([0, 3], "one")

    #     append!(layout, ["two", "", "three"])
    #     @test layout == AwkwardArray.StringOffsetArray([0, 3, 6, 6, 11], "onetwothree")
    # end

    # begin
    #     layout = AwkwardArray.StringArray()

    #     push!(layout, "one")
    #     @test layout == AwkwardArray.StringArray([0], [3], "one")

    #     append!(layout, ["two", "", "three"])
    #     @test layout == AwkwardArray.StringArray([0, 3, 6, 6], [3, 6, 6, 11], "onetwothree")
    # end

    # begin
    #     layout = AwkwardArray.StringRegularArray()

    #     push!(layout, "one")
    #     @test layout == AwkwardArray.StringRegularArray("one", 3)

    #     append!(layout, ["two", "333"])
    #     @test layout == AwkwardArray.StringRegularArray("onetwo333", 3)
    # end

    # ### ListType with behavior = :bytestring #################################

    # begin
    #     AwkwardArray.is_valid(
    #         AwkwardArray.ByteStringOffsetArray(
    #             [0, 3, 3, 6],
    #             Vector{UInt8}([0x6f, 0x6e, 0x65, 0x74, 0x77, 0x6f]),
    #         ),
    #     )
    #     AwkwardArray.is_valid(AwkwardArray.ByteStringOffsetArray())

    #     AwkwardArray.is_valid(
    #         AwkwardArray.ByteStringArray(
    #             [0, 3, 3],
    #             [3, 3, 6],
    #             Vector{UInt8}([0x6f, 0x6e, 0x65, 0x74, 0x77, 0x6f]),
    #         ),
    #     )
    #     AwkwardArray.is_valid(AwkwardArray.ByteStringArray())

    #     AwkwardArray.is_valid(
    #         AwkwardArray.ByteStringRegularArray(
    #             Vector{UInt8}([0x6f, 0x6e, 0x65, 0x74, 0x77, 0x6f]),
    #             3,
    #         ),
    #     )
    #     AwkwardArray.is_valid(AwkwardArray.ByteStringRegularArray(3))
    #     AwkwardArray.is_valid(AwkwardArray.ByteStringRegularArray())
    # end

    # begin
    #     layout = AwkwardArray.ListOffsetArray(
    #         [0, 3, 8, 9, 11, 14, 18],
    #         AwkwardArray.PrimitiveArray(
    #             [
    #                 0x68,
    #                 0x65,
    #                 0x79,
    #                 0x74,
    #                 0x68,
    #                 0x65,
    #                 0x72,
    #                 0x65,
    #                 0x24,
    #                 0xc2,
    #                 0xa2,
    #                 0xe2,
    #                 0x82,
    #                 0xac,
    #                 0xf0,
    #                 0x9f,
    #                 0x92,
    #                 0xb0,
    #             ],
    #             behavior = :byte,
    #         ),
    #         behavior = :bytestring,
    #     )

    #     @test layout[1] == [0x68, 0x65, 0x79]
    #     @test layout[2] == [0x74, 0x68, 0x65, 0x72, 0x65]
    #     @test layout[3] == [0x24]
    #     @test layout[4] == [0xc2, 0xa2]
    #     @test layout[5] == [0xe2, 0x82, 0xac]
    #     @test layout[6] == [0xf0, 0x9f, 0x92, 0xb0]

    #     AwkwardArray.push_dummy!(layout)
    #     @test layout[7] == []
    #     @test AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.ListArray(
    #         [0, 3, 8, 9, 11, 14],
    #         [3, 8, 9, 11, 14, 18],
    #         AwkwardArray.PrimitiveArray(
    #             [
    #                 0x68,
    #                 0x65,
    #                 0x79,
    #                 0x74,
    #                 0x68,
    #                 0x65,
    #                 0x72,
    #                 0x65,
    #                 0x24,
    #                 0xc2,
    #                 0xa2,
    #                 0xe2,
    #                 0x82,
    #                 0xac,
    #                 0xf0,
    #                 0x9f,
    #                 0x92,
    #                 0xb0,
    #             ],
    #             behavior = :byte,
    #         ),
    #         behavior = :bytestring,
    #     )

    #     @test layout[1] == [0x68, 0x65, 0x79]
    #     @test layout[2] == [0x74, 0x68, 0x65, 0x72, 0x65]
    #     @test layout[3] == [0x24]
    #     @test layout[4] == [0xc2, 0xa2]
    #     @test layout[5] == [0xe2, 0x82, 0xac]
    #     @test layout[6] == [0xf0, 0x9f, 0x92, 0xb0]

    #     AwkwardArray.push_dummy!(layout)
    #     @test layout[7] == []
    #     @test AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.RegularArray(
    #         AwkwardArray.PrimitiveArray(
    #             [0x6f, 0x6e, 0x65, 0x74, 0x77, 0x6f],
    #             behavior = :byte,
    #         ),
    #         3,
    #         behavior = :bytestring,
    #     )

    #     @test layout[1] == [0x6f, 0x6e, 0x65]
    #     @test layout[2] == [0x74, 0x77, 0x6f]

    #     @test Vector(layout) == [[0x6f, 0x6e, 0x65], [0x74, 0x77, 0x6f]]

    #     AwkwardArray.push_dummy!(layout)
    #     @test Vector(layout) == [[0x6f, 0x6e, 0x65], [0x74, 0x77, 0x6f], [0x00, 0x00, 0x00]]
    #     @test AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.ByteStringOffsetArray()

    #     push!(layout, Vector{UInt8}([0, 1, 2]))
    #     @test layout == AwkwardArray.ByteStringOffsetArray([0, 3], Vector{UInt8}([0, 1, 2]))

    #     append!(layout, [Vector{UInt8}([]), Vector{UInt8}([3, 4])])
    #     @test layout == AwkwardArray.ByteStringOffsetArray(
    #         [0, 3, 3, 5],
    #         Vector{UInt8}([0, 1, 2, 3, 4]),
    #     )
    # end

    # begin
    #     layout = AwkwardArray.ByteStringArray()

    #     push!(layout, Vector{UInt8}([0, 1, 2]))
    #     @test layout == AwkwardArray.ByteStringArray([0], [3], Vector{UInt8}([0, 1, 2]))

    #     append!(layout, [Vector{UInt8}([]), Vector{UInt8}([3, 4])])
    #     @test layout == AwkwardArray.ByteStringArray(
    #         [0, 3, 3],
    #         [3, 3, 5],
    #         Vector{UInt8}([0, 1, 2, 3, 4]),
    #     )
    # end

    # begin
    #     layout = AwkwardArray.ByteStringRegularArray()

    #     push!(layout, Vector{UInt8}([0, 1, 2]))
    #     @test layout == AwkwardArray.ByteStringRegularArray(Vector{UInt8}([0, 1, 2]), 3)

    #     append!(layout, [Vector{UInt8}([3, 4, 5]), Vector{UInt8}([6, 7, 8])])
    #     @test layout == AwkwardArray.ByteStringRegularArray(
    #         Vector{UInt8}([0, 1, 2, 3, 4, 5, 6, 7, 8]),
    #         3,
    #     )
    # end

    # ### ListType with other parameters #######################################

    # begin
    #     layout = AwkwardArray.ListOffsetArray(
    #         [0, 3, 3, 8],
    #         AwkwardArray.PrimitiveArray([0x68, 0x65, 0x79, 0x74, 0x68, 0x65, 0x72, 0x65],),
    #         parameters = AwkwardArray.Parameters("__doc__" => "nice list"),
    #     )

    #     @test AwkwardArray.get_parameter(layout, "__doc__") == "nice list"
    #     @test !AwkwardArray.has_parameter(layout, "__list__")
    # end

    # begin
    #     layout = AwkwardArray.ListArray(
    #         [0, 3, 3],
    #         [3, 3, 8],
    #         AwkwardArray.PrimitiveArray([0x68, 0x65, 0x79, 0x74, 0x68, 0x65, 0x72, 0x65],),
    #         parameters = AwkwardArray.Parameters("__doc__" => "nice list"),
    #     )

    #     @test AwkwardArray.get_parameter(layout, "__doc__") == "nice list"
    #     @test !AwkwardArray.has_parameter(layout, "__list__")
    # end

    # begin
    #     layout = AwkwardArray.RegularArray(
    #         AwkwardArray.PrimitiveArray([0x6f, 0x6e, 0x65, 0x74, 0x77, 0x6f]),
    #         3,
    #         parameters = AwkwardArray.Parameters("__doc__" => "nice list"),
    #     )

    #     @test AwkwardArray.get_parameter(layout, "__doc__") == "nice list"
    #     @test !AwkwardArray.has_parameter(layout, "__list__")
    # end

    # begin
    #     layout = AwkwardArray.ListOffsetArray(
    #         [0, 3, 3, 8],
    #         AwkwardArray.PrimitiveArray(
    #             [0x68, 0x65, 0x79, 0x74, 0x68, 0x65, 0x72, 0x65],
    #             behavior = :char,
    #         ),
    #         parameters = AwkwardArray.Parameters("__doc__" => "nice string"),
    #         behavior = :string,
    #     )

    #     @test AwkwardArray.get_parameter(layout, "__doc__") == "nice string"
    #     @test !AwkwardArray.has_parameter(layout, "__list__")
    # end

    # begin
    #     layout = AwkwardArray.ListArray(
    #         [0, 3, 3],
    #         [3, 3, 8],
    #         AwkwardArray.PrimitiveArray(
    #             [0x68, 0x65, 0x79, 0x74, 0x68, 0x65, 0x72, 0x65],
    #             behavior = :char,
    #         ),
    #         parameters = AwkwardArray.Parameters("__doc__" => "nice string"),
    #         behavior = :string,
    #     )

    #     @test AwkwardArray.get_parameter(layout, "__doc__") == "nice string"
    #     @test !AwkwardArray.has_parameter(layout, "__list__")
    # end

    # begin
    #     layout = AwkwardArray.RegularArray(
    #         AwkwardArray.PrimitiveArray(
    #             [0x6f, 0x6e, 0x65, 0x74, 0x77, 0x6f],
    #             behavior = :char,
    #         ),
    #         3,
    #         parameters = AwkwardArray.Parameters("__doc__" => "nice list"),
    #         behavior = :string,
    #     )

    #     @test AwkwardArray.get_parameter(layout, "__doc__") == "nice list"
    #     @test !AwkwardArray.has_parameter(layout, "__list__")
    # end

    # ### RecordArray ##########################################################

    # begin
    #     layout = AwkwardArray.RecordArray(
    #         NamedTuple{(:a, :b)}((
    #             AwkwardArray.PrimitiveArray([1, 2, 3, 4, 5]),
    #             AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #         )),
    #         5,
    #     )
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 5
    #     @test layout[3][:a] == 3
    #     @test layout[3][:b] == 3.3
    #     @test layout[:a][3] == 3
    #     @test layout[:b][3] == 3.3

    #     @test layout == layout
    #     @test layout[3] == layout[3]

    #     tmp = 0.0
    #     for x in layout
    #         @test x[:b] < 6
    #         tmp += x[:b]
    #     end
    #     @test tmp == 16.5
    # end

    # begin
    #     layout = AwkwardArray.RecordArray(
    #         NamedTuple{(:a, :b)}((
    #             AwkwardArray.PrimitiveArray([1, 2, 3]),
    #             AwkwardArray.ListOffsetArray(
    #                 [0, 3, 3, 5],
    #                 AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #             ),
    #         )),
    #     )
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 3
    #     @test layout[3][:a] == 3
    #     @test layout[3][:b][1] == 4.4
    #     @test layout[:a][3] == 3
    #     @test layout[:b][3][1] == 4.4

    #     @test layout == layout
    #     @test layout[3] == layout[3]
    #     @test layout[1][:b] == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3])
    #     @test layout[2][:b] == AwkwardArray.PrimitiveArray([])
    #     @test layout[3][:b] == AwkwardArray.PrimitiveArray([4.4, 5.5])
    #     @test layout[:b][1] == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3])
    #     @test layout[:b][2] == AwkwardArray.PrimitiveArray([])
    #     @test layout[:b][3] == AwkwardArray.PrimitiveArray([4.4, 5.5])

    #     tmp = 0.0
    #     for x in layout
    #         for y in x[:b]
    #             @test y < 6
    #             tmp += y
    #         end
    #     end
    #     @test tmp == 16.5

    #     @inferred layout[3]
    #     @inferred layout[1:3]
    #     @inferred layout[:a][3]
    #     @inferred layout[:b][3]
    #     @inferred layout[:b][3][1]

    #     @test AwkwardArray.to_vector(layout) == [
    #         NamedTuple{(:a, :b)}((1, [1.1, 2.2, 3.3])),
    #         NamedTuple{(:a, :b)}((2, [])),
    #         NamedTuple{(:a, :b)}((3, [4.4, 5.5])),
    #     ]
    # end

    # begin
    #     layout = AwkwardArray.RecordArray(
    #         NamedTuple{(:a, :b)}((
    #             AwkwardArray.PrimitiveArray{Int64}(),
    #             AwkwardArray.ListOffsetArray{
    #                 AwkwardArray.Index64,
    #                 AwkwardArray.PrimitiveArray{Float64},
    #             }(),
    #         )),
    #     )
    #     a_layout = layout.contents[:a]
    #     b_layout = layout.contents[:b]
    #     b_sublayout = b_layout.content

    #     push!(a_layout, 1)
    #     push!(b_sublayout, 1.1)
    #     push!(b_sublayout, 2.2)
    #     push!(b_sublayout, 3.3)
    #     AwkwardArray.end_list!(b_layout)
    #     AwkwardArray.end_record!(layout)

    #     push!(a_layout, 2)
    #     AwkwardArray.end_list!(b_layout)
    #     AwkwardArray.end_record!(layout)

    #     push!(a_layout, 3)
    #     push!(b_sublayout, 4.4)
    #     push!(b_sublayout, 5.5)
    #     AwkwardArray.end_list!(b_layout)
    #     AwkwardArray.end_record!(layout)

    #     @test layout[:a] == AwkwardArray.PrimitiveArray([1, 2, 3])
    #     @test layout[:b] == AwkwardArray.ListOffsetArray(
    #         [0, 3, 3, 5],
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #     )

    #     @test layout == layout

    #     @test AwkwardArray.RecordArray(
    #         NamedTuple{(:a,)}((AwkwardArray.PrimitiveArray([1, 2, 3]),)),
    #     ) == AwkwardArray.RecordArray(
    #         NamedTuple{(:a,)}((AwkwardArray.PrimitiveArray([1, 2, 3]),)),
    #     )

    #     @test layout == AwkwardArray.RecordArray(
    #         NamedTuple{(:a, :b)}((
    #             AwkwardArray.PrimitiveArray([1, 2, 3]),
    #             AwkwardArray.ListOffsetArray(
    #                 [0, 3, 3, 5],
    #                 AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #             ),
    #         )),
    #     )

    #     @test layout[1] == layout[1]
    #     @test layout[2] == layout[2]
    #     @test layout[3] == layout[3]

    #     @test layout[3] == AwkwardArray.Record(
    #         AwkwardArray.RecordArray(
    #             NamedTuple{(:a, :b)}((
    #                 AwkwardArray.PrimitiveArray([1, 2, 3]),
    #                 AwkwardArray.ListOffsetArray(
    #                     [0, 3, 3, 5],
    #                     AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #                 ),
    #             )),
    #         ),
    #         3,
    #     )

    #     @test layout[3] == AwkwardArray.Record(
    #         AwkwardArray.RecordArray(
    #             NamedTuple{(:a, :b)}((
    #                 AwkwardArray.PrimitiveArray([3]),
    #                 AwkwardArray.ListOffsetArray(
    #                     [0, 2],
    #                     AwkwardArray.PrimitiveArray([4.4, 5.5]),
    #                 ),
    #             )),
    #         ),
    #         1,
    #     )

    #     AwkwardArray.push_dummy!(layout)
    #     @test layout == AwkwardArray.RecordArray(
    #         NamedTuple{(:a, :b)}((
    #             AwkwardArray.PrimitiveArray([1, 2, 3, 0]),
    #             AwkwardArray.ListOffsetArray(
    #                 [0, 3, 3, 5, 5],
    #                 AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #             ),
    #         )),
    #     )
    #     @test layout[4] == AwkwardArray.Record(
    #         AwkwardArray.RecordArray(
    #             NamedTuple{(:a, :b)}((
    #                 AwkwardArray.PrimitiveArray([0]),
    #                 AwkwardArray.ListOffsetArray([0, 0], AwkwardArray.PrimitiveArray([])),
    #             )),
    #         ),
    #         1,
    #     )
    #     @test AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout_2 = AwkwardArray.RecordArray(
    #         NamedTuple{(:a, :b)}((
    #             AwkwardArray.PrimitiveArray([1, 2]),
    #             AwkwardArray.ListOffsetArray(
    #                 [0, 3, 3],
    #                 AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3]),
    #             ),
    #         )),
    #     )

    #     layout_3 = AwkwardArray.RecordArray(
    #         NamedTuple{(:a, :b)}((
    #             AwkwardArray.PrimitiveArray([1, 2, 3]),
    #             AwkwardArray.ListOffsetArray(
    #                 [0, 3, 3, 5],
    #                 AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #             ),
    #         )),
    #     )

    #     @test layout_2 == AwkwardArray.copy(layout_3, length = 2)
    # end

    # begin
    #     layout = AwkwardArray.RecordArray{
    #         (:a, :b),
    #         Tuple{
    #             AwkwardArray.PrimitiveArray{Int64},
    #             AwkwardArray.ListOffsetArray{
    #                 AwkwardArray.Index64,
    #                 AwkwardArray.PrimitiveArray{Float64},
    #             },
    #         },
    #     }()
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 0

    #     a_layout = layout.contents[:a]
    #     b_layout = layout.contents[:b]
    #     b_sublayout = b_layout.content

    #     push!(a_layout, 1)
    #     push!(b_sublayout, 1.1)
    #     push!(b_sublayout, 2.2)
    #     push!(b_sublayout, 3.3)
    #     AwkwardArray.end_list!(b_layout)
    #     AwkwardArray.end_record!(layout)
    #     @test length(layout) == 1

    #     push!(a_layout, 2)
    #     AwkwardArray.end_list!(b_layout)
    #     AwkwardArray.end_record!(layout)
    #     @test length(layout) == 2

    #     push!(a_layout, 3)
    #     push!(b_sublayout, 4.4)
    #     push!(b_sublayout, 5.5)
    #     AwkwardArray.end_list!(b_layout)
    #     AwkwardArray.end_record!(layout)
    #     @test length(layout) == 3

    #     @test layout == AwkwardArray.RecordArray(
    #         NamedTuple{(:a, :b)}((
    #             AwkwardArray.PrimitiveArray([1, 2, 3]),
    #             AwkwardArray.ListOffsetArray(
    #                 [0, 3, 3, 5],
    #                 AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #             ),
    #         )),
    #     )
    # end

    # begin
    #     layout = AwkwardArray.RecordArray{
    #         (:a, :b),
    #         Tuple{
    #             AwkwardArray.PrimitiveArray{Int64},
    #             AwkwardArray.ListOffsetArray{
    #                 AwkwardArray.Index64,
    #                 AwkwardArray.PrimitiveArray{Float64},
    #             },
    #         },
    #     }()

    #     push!(layout, NamedTuple{(:a, :b)}((123, [1.1, 2.2, 3.3])))
    #     @test layout == AwkwardArray.RecordArray(
    #         NamedTuple{(:a, :b)}((
    #             AwkwardArray.PrimitiveArray([123]),
    #             AwkwardArray.ListOffsetArray(
    #                 [0, 3],
    #                 AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3]),
    #             ),
    #         )),
    #     )

    #     append!(
    #         layout,
    #         [
    #             NamedTuple{(:a, :b)}((321, Vector{Float64}([]))),
    #             NamedTuple{(:a, :b)}((999, [4.4, 5.5])),
    #         ],
    #     )
    #     @test layout == AwkwardArray.RecordArray(
    #         NamedTuple{(:a, :b)}((
    #             AwkwardArray.PrimitiveArray([123, 321, 999]),
    #             AwkwardArray.ListOffsetArray(
    #                 [0, 3, 3, 5],
    #                 AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #             ),
    #         )),
    #     )
    # end

    # ### TupleArray ##########################################################

    # begin
    #     layout = AwkwardArray.TupleArray((
    #         AwkwardArray.PrimitiveArray([1, 2, 3, 4, 5]),
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #     ),)
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 5
    #     @test layout[3][1] == 3
    #     @test layout[3][2] == 3.3
    #     @test AwkwardArray.slot(layout, 1)[3] == 3
    #     @test AwkwardArray.slot(layout, 2)[3] == 3.3
    #     @test layout == layout
    #     @test layout[3] == layout[3]

    #     tmp = 0.0
    #     for x in layout
    #         @test x[2] < 6
    #         tmp += x[2]
    #     end
    #     @test tmp == 16.5
    # end

    # begin
    #     layout = AwkwardArray.TupleArray((
    #         AwkwardArray.PrimitiveArray([1, 2, 3]),
    #         AwkwardArray.ListOffsetArray(
    #             [0, 3, 3, 5],
    #             AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #         ),
    #     ),)
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 3
    #     @test layout[3][1] == 3
    #     @test layout[3][2][1] == 4.4
    #     @test AwkwardArray.slot(layout, 1)[3] == 3
    #     @test AwkwardArray.slot(layout, 2)[3][1] == 4.4

    #     @test layout == layout
    #     @test layout[3] == layout[3]
    #     @test layout[1][2] == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3])
    #     @test layout[2][2] == AwkwardArray.PrimitiveArray([])
    #     @test layout[3][2] == AwkwardArray.PrimitiveArray([4.4, 5.5])
    #     @test AwkwardArray.slot(layout, 2)[1] ==
    #           AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3])
    #     @test AwkwardArray.slot(layout, 2)[2] == AwkwardArray.PrimitiveArray([])
    #     @test AwkwardArray.slot(layout, 2)[3] == AwkwardArray.PrimitiveArray([4.4, 5.5])

    #     tmp = 0.0
    #     for x in layout
    #         for y in x[2]
    #             @test y < 6
    #             tmp += y
    #         end
    #     end
    #     @test tmp == 16.5

    #     @inferred layout[3]
    #     @inferred layout[1:3]
    #     @inferred AwkwardArray.slot(layout, 1)[3]
    #     @inferred AwkwardArray.slot(layout, 2)[3]
    #     @inferred AwkwardArray.slot(layout, 2)[3][1]

    #     @test AwkwardArray.to_vector(layout) ==
    #           [(1, [1.1, 2.2, 3.3]), (2, []), (3, [4.4, 5.5])]
    # end

    # begin
    #     layout = AwkwardArray.TupleArray((
    #         AwkwardArray.PrimitiveArray{Int64}(),
    #         AwkwardArray.ListOffsetArray{
    #             AwkwardArray.Index64,
    #             AwkwardArray.PrimitiveArray{Float64},
    #         }(),
    #     ),)
    #     a_layout = layout.contents[1]
    #     b_layout = layout.contents[2]
    #     b_sublayout = b_layout.content

    #     push!(a_layout, 1)
    #     push!(b_sublayout, 1.1)
    #     push!(b_sublayout, 2.2)
    #     push!(b_sublayout, 3.3)
    #     AwkwardArray.end_list!(b_layout)
    #     AwkwardArray.end_tuple!(layout)

    #     push!(a_layout, 2)
    #     AwkwardArray.end_list!(b_layout)
    #     AwkwardArray.end_tuple!(layout)

    #     push!(a_layout, 3)
    #     push!(b_sublayout, 4.4)
    #     push!(b_sublayout, 5.5)
    #     AwkwardArray.end_list!(b_layout)
    #     AwkwardArray.end_tuple!(layout)

    #     @test AwkwardArray.slot(layout, 1) == AwkwardArray.PrimitiveArray([1, 2, 3])
    #     @test AwkwardArray.slot(layout, 2) == AwkwardArray.ListOffsetArray(
    #         [0, 3, 3, 5],
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #     )

    #     @test layout == layout

    #     @test AwkwardArray.TupleArray((AwkwardArray.PrimitiveArray([1, 2, 3]),),) ==
    #           AwkwardArray.TupleArray((AwkwardArray.PrimitiveArray([1, 2, 3]),),)

    #     @test layout == AwkwardArray.TupleArray((
    #         AwkwardArray.PrimitiveArray([1, 2, 3]),
    #         AwkwardArray.ListOffsetArray(
    #             [0, 3, 3, 5],
    #             AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #         ),
    #     ),)

    #     @test layout[1] == layout[1]
    #     @test layout[2] == layout[2]
    #     @test layout[3] == layout[3]

    #     @test layout[3] == AwkwardArray.Tuple(
    #         AwkwardArray.TupleArray((
    #             AwkwardArray.PrimitiveArray([1, 2, 3]),
    #             AwkwardArray.ListOffsetArray(
    #                 [0, 3, 3, 5],
    #                 AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #             ),
    #         ),),
    #         3,
    #     )

    #     @test layout[3] == AwkwardArray.Tuple(
    #         AwkwardArray.TupleArray((
    #             AwkwardArray.PrimitiveArray([3]),
    #             AwkwardArray.ListOffsetArray(
    #                 [0, 2],
    #                 AwkwardArray.PrimitiveArray([4.4, 5.5]),
    #             ),
    #         ),),
    #         1,
    #     )

    #     AwkwardArray.push_dummy!(layout)
    #     @test layout == AwkwardArray.TupleArray((
    #         AwkwardArray.PrimitiveArray([1, 2, 3, 0]),
    #         AwkwardArray.ListOffsetArray(
    #             [0, 3, 3, 5, 5],
    #             AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #         ),
    #     ),)
    #     @test layout[4] == AwkwardArray.Tuple(
    #         AwkwardArray.TupleArray((
    #             AwkwardArray.PrimitiveArray([0]),
    #             AwkwardArray.ListOffsetArray([0, 0], AwkwardArray.PrimitiveArray([])),
    #         ),),
    #         1,
    #     )
    #     @test AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout_2 = AwkwardArray.TupleArray((
    #         AwkwardArray.PrimitiveArray([1, 2]),
    #         AwkwardArray.ListOffsetArray(
    #             [0, 3, 3],
    #             AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3]),
    #         ),
    #     ),)

    #     layout_3 = AwkwardArray.TupleArray((
    #         AwkwardArray.PrimitiveArray([1, 2, 3]),
    #         AwkwardArray.ListOffsetArray(
    #             [0, 3, 3, 5],
    #             AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #         ),
    #     ),)

    #     @test layout_2 == AwkwardArray.copy(layout_3, length = 2)
    # end

    # begin
    #     layout = AwkwardArray.TupleArray{
    #         Tuple{
    #             AwkwardArray.PrimitiveArray{Int64},
    #             AwkwardArray.ListOffsetArray{
    #                 AwkwardArray.Index64,
    #                 AwkwardArray.PrimitiveArray{Float64},
    #             },
    #         },
    #     }()
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 0

    #     a_layout = layout.contents[1]
    #     b_layout = layout.contents[2]
    #     b_sublayout = b_layout.content

    #     push!(a_layout, 1)
    #     push!(b_sublayout, 1.1)
    #     push!(b_sublayout, 2.2)
    #     push!(b_sublayout, 3.3)
    #     AwkwardArray.end_list!(b_layout)
    #     AwkwardArray.end_tuple!(layout)
    #     @test length(layout) == 1

    #     push!(a_layout, 2)
    #     AwkwardArray.end_list!(b_layout)
    #     AwkwardArray.end_tuple!(layout)
    #     @test length(layout) == 2

    #     push!(a_layout, 3)
    #     push!(b_sublayout, 4.4)
    #     push!(b_sublayout, 5.5)
    #     AwkwardArray.end_list!(b_layout)
    #     AwkwardArray.end_tuple!(layout)
    #     @test length(layout) == 3

    #     @test layout == AwkwardArray.TupleArray((
    #         AwkwardArray.PrimitiveArray([1, 2, 3]),
    #         AwkwardArray.ListOffsetArray(
    #             [0, 3, 3, 5],
    #             AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #         ),
    #     ),)
    # end

    # begin
    #     layout = AwkwardArray.TupleArray{
    #         Tuple{
    #             AwkwardArray.PrimitiveArray{Int64},
    #             AwkwardArray.ListOffsetArray{
    #                 AwkwardArray.Index64,
    #                 AwkwardArray.PrimitiveArray{Float64},
    #             },
    #         },
    #     }()

    #     push!(layout, (123, [1.1, 2.2, 3.3]))
    #     @test layout == AwkwardArray.TupleArray((
    #         AwkwardArray.PrimitiveArray([123]),
    #         AwkwardArray.ListOffsetArray(
    #             [0, 3],
    #             AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3]),
    #         ),
    #     ),)

    #     append!(layout, [(321, Vector{Float64}([])), (999, [4.4, 5.5])])
    #     @test layout == AwkwardArray.TupleArray((
    #         AwkwardArray.PrimitiveArray([123, 321, 999]),
    #         AwkwardArray.ListOffsetArray(
    #             [0, 3, 3, 5],
    #             AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #         ),
    #     ),)
    # end

    # ### IndexedArray #########################################################

    # begin
    #     layout = AwkwardArray.IndexedArray(
    #         [4, 3, 3, 0],
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #     )
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 4
    #     @test layout[1] == 5.5
    #     @test layout[2] == 4.4
    #     @test layout[3] == 4.4
    #     @test layout[4] == 1.1
    #     @test layout[2:4] == AwkwardArray.PrimitiveArray([4.4, 4.4, 1.1])
    #     tmp = 0.0
    #     for x in layout
    #         @test x < 6
    #         tmp += x
    #     end
    #     @test tmp == 15.4

    #     push!(layout, 6.6)
    #     @test length(layout) == 5
    #     @test layout[5] == 6.6

    #     push!(layout, 7.7)
    #     @test length(layout) == 6
    #     @test layout[6] == 7.7
    #     @test layout.index == [4, 3, 3, 0, 5, 6]
    #     @test layout == AwkwardArray.PrimitiveArray([5.5, 4.4, 4.4, 1.1, 6.6, 7.7])

    #     AwkwardArray.push_dummy!(layout)
    #     @test layout == AwkwardArray.PrimitiveArray([5.5, 4.4, 4.4, 1.1, 6.6, 7.7, 0.0])
    #     @test layout.index == [4, 3, 3, 0, 5, 6, 7]
    #     @test AwkwardArray.is_valid(layout)

    #     @test AwkwardArray.to_vector(layout) == [5.5, 4.4, 4.4, 1.1, 6.6, 7.7, 0.0]
    # end

    # begin
    #     layout = AwkwardArray.IndexedArray(
    #         [2, 0, 0, 1],
    #         AwkwardArray.ListOffsetArray(
    #             [0, 3, 3, 5],
    #             AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #         ),
    #     )
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 4
    #     @test layout[1] == AwkwardArray.PrimitiveArray([4.4, 5.5])
    #     @test layout[2] == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3])
    #     @test layout[3] == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3])
    #     @test layout[4] == AwkwardArray.PrimitiveArray([])

    #     sublayout = layout.content.content
    #     push!(sublayout, 6.6)
    #     push!(sublayout, 7.7)
    #     AwkwardArray.end_list!(layout)
    #     @test length(layout) == 5
    #     @test layout[5] == AwkwardArray.PrimitiveArray([6.6, 7.7])
    #     @test layout.index == [2, 0, 0, 1, 3]

    #     @test layout == AwkwardArray.ListArray(
    #         [3, 0, 0, 3, 5],
    #         [5, 3, 3, 3, 7],
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7]),
    #     )
    #     AwkwardArray.push_dummy!(layout)
    #     @test layout == AwkwardArray.ListArray(
    #         [3, 0, 0, 3, 5, 7],
    #         [5, 3, 3, 3, 7, 7],
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7]),
    #     )
    #     @test AwkwardArray.is_valid(layout)

    #     @inferred layout[1]
    #     @inferred layout[1][1]
    #     @inferred layout[1:3]

    #     @test AwkwardArray.to_vector(layout) ==
    #           [[4.4, 5.5], [1.1, 2.2, 3.3], [1.1, 2.2, 3.3], [], [6.6, 7.7], []]
    # end

    # begin
    #     layout = AwkwardArray.IndexedArray(
    #         [3, 4, 0, 0, 1, 2],
    #         AwkwardArray.RecordArray(
    #             NamedTuple{(:a, :b)}((
    #                 AwkwardArray.PrimitiveArray([1, 2, 3, 4, 5]),
    #                 AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #             )),
    #         ),
    #     )
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 6
    #     @test layout[1][:a] == 4
    #     @test layout[1][:b] == 4.4
    #     @test layout[end][:a] == 3
    #     @test layout[end][:b] == 3.3
    #     @test layout[:a][1] == 4
    #     @test layout[:b][1] == 4.4
    #     @test layout[:a][end] == 3
    #     @test layout[:b][end] == 3.3

    #     a_layout = layout.content.contents[:a]
    #     b_layout = layout.content.contents[:b]

    #     push!(a_layout, 6)
    #     push!(b_layout, 6.6)
    #     AwkwardArray.end_record!(layout)
    #     @test length(layout) == 7
    #     @test layout[end][:a] == 6
    #     @test layout[end][:b] == 6.6
    #     @test layout.index == [3, 4, 0, 0, 1, 2, 5]

    #     AwkwardArray.push_dummy!(layout)
    #     @test length(layout) == 8
    #     @test layout[end][:a] == 0
    #     @test layout[end][:b] == 0.0
    #     @test layout.index == [3, 4, 0, 0, 1, 2, 5, 6]
    #     @test AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.IndexedArray{
    #         AwkwardArray.Index64,
    #         AwkwardArray.RecordArray{
    #             (:a, :b),
    #             Tuple{
    #                 AwkwardArray.PrimitiveArray{Int64},
    #                 AwkwardArray.ListOffsetArray{
    #                     AwkwardArray.Index64,
    #                     AwkwardArray.PrimitiveArray{Float64},
    #                 },
    #             },
    #         },
    #     }()

    #     push!(layout, NamedTuple{(:a, :b)}((123, [1.1, 2.2, 3.3])))
    #     @test layout == AwkwardArray.RecordArray(
    #         NamedTuple{(:a, :b)}((
    #             AwkwardArray.PrimitiveArray([123]),
    #             AwkwardArray.ListOffsetArray(
    #                 [0, 3],
    #                 AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3]),
    #             ),
    #         )),
    #     )

    #     append!(
    #         layout,
    #         [
    #             NamedTuple{(:a, :b)}((321, Vector{Float64}([]))),
    #             NamedTuple{(:a, :b)}((999, [4.4, 5.5])),
    #         ],
    #     )
    #     @test layout == AwkwardArray.RecordArray(
    #         NamedTuple{(:a, :b)}((
    #             AwkwardArray.PrimitiveArray([123, 321, 999]),
    #             AwkwardArray.ListOffsetArray(
    #                 [0, 3, 3, 5],
    #                 AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #             ),
    #         )),
    #     )
    # end

    # ### IndexedOptionArray ###################################################

    # begin
    #     layout = AwkwardArray.IndexedOptionArray(
    #         [4, 3, 3, -1, -1, 0],
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #     )
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 6
    #     @test layout[1] == 5.5
    #     @test layout[2] == 4.4
    #     @test layout[3] == 4.4
    #     @test ismissing(layout[4])
    #     @test ismissing(layout[5])
    #     @test layout[6] == 1.1
    #     @test layout[2:3] == AwkwardArray.PrimitiveArray([4.4, 4.4])
    #     tmp = 0.0
    #     for x in layout
    #         if !ismissing(x)
    #             @test x < 6
    #             tmp += x
    #         end
    #     end
    #     @test tmp == 15.4

    #     push!(layout, 6.6)
    #     @test length(layout) == 7
    #     @test layout[7] == 6.6

    #     AwkwardArray.push_null!(layout)
    #     @test length(layout) == 8
    #     @test ismissing(layout[8])
    #     AwkwardArray.push_null!(layout)
    #     @test length(layout) == 9
    #     @test ismissing(layout[9])

    #     push!(layout, 7.7)
    #     @test length(layout) == 10
    #     @test layout[10] == 7.7
    #     @test layout.index == [4, 3, 3, -1, -1, 0, 5, -1, -1, 6]

    #     AwkwardArray.push_dummy!(layout)
    #     @test length(layout) == 11
    #     @test ismissing(layout[11])
    #     @test layout.index == [4, 3, 3, -1, -1, 0, 5, -1, -1, 6, -1]
    #     @test AwkwardArray.is_valid(layout)

    #     @inferred layout[1:5]

    #     @test AwkwardArray.to_vector(layout, na = nothing) ==
    #           [5.5, 4.4, 4.4, nothing, nothing, 1.1, 6.6, nothing, nothing, 7.7, nothing]
    # end

    # begin
    #     layout = AwkwardArray.IndexedOptionArray{
    #         AwkwardArray.Index64,
    #         AwkwardArray.RecordArray{
    #             (:a, :b),
    #             Tuple{
    #                 AwkwardArray.PrimitiveArray{Int64},
    #                 AwkwardArray.ListOffsetArray{
    #                     AwkwardArray.Index64,
    #                     AwkwardArray.PrimitiveArray{Float64},
    #                 },
    #             },
    #         },
    #     }()

    #     push!(layout, NamedTuple{(:a, :b)}((123, [1.1, 2.2, 3.3])))
    #     @test layout == AwkwardArray.RecordArray(
    #         NamedTuple{(:a, :b)}((
    #             AwkwardArray.PrimitiveArray([123]),
    #             AwkwardArray.ListOffsetArray(
    #                 [0, 3],
    #                 AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3]),
    #             ),
    #         )),
    #     )

    #     push!(layout, missing)
    #     @test layout == AwkwardArray.IndexedOptionArray(
    #         [0, -1],
    #         AwkwardArray.RecordArray(
    #             NamedTuple{(:a, :b)}((
    #                 AwkwardArray.PrimitiveArray([123]),
    #                 AwkwardArray.ListOffsetArray(
    #                     [0, 3],
    #                     AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3]),
    #                 ),
    #             )),
    #         ),
    #     )

    #     append!(
    #         layout,
    #         [
    #             NamedTuple{(:a, :b)}((321, Vector{Float64}([]))),
    #             missing,
    #             NamedTuple{(:a, :b)}((999, [4.4, 5.5])),
    #         ],
    #     )
    #     @test layout == AwkwardArray.IndexedOptionArray(
    #         [0, -1, 1, -1, 2],
    #         AwkwardArray.RecordArray(
    #             NamedTuple{(:a, :b)}((
    #                 AwkwardArray.PrimitiveArray([123, 321, 999]),
    #                 AwkwardArray.ListOffsetArray(
    #                     [0, 3, 3, 5],
    #                     AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #                 ),
    #             )),
    #         ),
    #     )
    # end

    # ### ByteMaskedArray ######################################################

    # begin
    #     layout = AwkwardArray.ByteMaskedArray(
    #         [false, true, true, false, false],
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #         valid_when = false,
    #     )
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 5
    #     @test layout[1] == 1.1
    #     @test ismissing(layout[2])
    #     @test ismissing(layout[3])
    #     @test layout[4] == 4.4
    #     @test layout[5] == 5.5
    #     @test layout[4:5] == AwkwardArray.PrimitiveArray([4.4, 5.5])
    #     tmp = 0.0
    #     for x in layout
    #         if !ismissing(x)
    #             @test x < 6
    #             tmp += x
    #         end
    #     end
    #     @test tmp == 11.0

    #     push!(layout, 6.6)
    #     @test length(layout) == 6
    #     @test layout[6] == 6.6

    #     AwkwardArray.push_null!(layout)
    #     @test length(layout) == 7
    #     @test ismissing(layout[7])

    #     AwkwardArray.push_dummy!(layout)
    #     @test length(layout) == 8
    #     @test ismissing(layout[8])
    #     @test AwkwardArray.is_valid(layout)

    #     @inferred layout[2:5]

    #     @test AwkwardArray.to_vector(layout, na = nothing) ==
    #           [1.1, nothing, nothing, 4.4, 5.5, 6.6, nothing, nothing]
    # end

    # begin
    #     layout = AwkwardArray.ByteMaskedArray(
    #         [true, true, false],
    #         AwkwardArray.ListOffsetArray(
    #             [0, 3, 3, 5],
    #             AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #         ),
    #         valid_when = true,
    #     )
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 3

    #     sublayout = layout.content.content

    #     push!(sublayout, 6.6)
    #     push!(sublayout, 7.7)
    #     push!(sublayout, 8.8)
    #     push!(sublayout, 9.9)
    #     AwkwardArray.end_list!(layout)

    #     @test length(layout) == 4
    #     @test layout[4] == AwkwardArray.PrimitiveArray([6.6, 7.7, 8.8, 9.9])

    #     AwkwardArray.push_null!(layout)
    #     @test length(layout) == 5
    #     @test ismissing(layout[5])

    #     AwkwardArray.push_dummy!(layout)
    #     @test length(layout) == 6
    #     @test ismissing(layout[6])
    #     @test AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.ByteMaskedArray(
    #         [false, false, true, true, false],
    #         AwkwardArray.RecordArray(
    #             NamedTuple{(:a, :b)}((
    #                 AwkwardArray.PrimitiveArray([1, 2, 3, 4, 5]),
    #                 AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #             )),
    #         ),
    #         valid_when = false,
    #     )
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 5

    #     a_layout = layout.content.contents[:a]
    #     b_layout = layout.content.contents[:b]

    #     push!(a_layout, 6)
    #     push!(b_layout, 6.6)
    #     AwkwardArray.end_record!(layout)
    #     @test length(layout) == 6
    #     @test layout[6][:a] == 6
    #     @test layout[6][:b] == 6.6
    #     @test layout[:a][6] == 6
    #     @test layout[:b][6] == 6.6

    #     AwkwardArray.push_null!(layout)
    #     @test length(layout) == 7
    #     @test ismissing(layout[7])

    #     AwkwardArray.push_dummy!(layout)
    #     @test length(layout) == 8
    #     @test ismissing(layout[8])
    #     @test AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.ByteMaskedArray{
    #         AwkwardArray.Index8,
    #         AwkwardArray.ListOffsetArray{
    #             AwkwardArray.Index64,
    #             AwkwardArray.PrimitiveArray{Float64},
    #         },
    #     }()

    #     push!(layout, [1.1, 2.2, 3.3])
    #     @test layout == AwkwardArray.ByteMaskedArray(
    #         [true],
    #         AwkwardArray.ListOffsetArray(
    #             [0, 3],
    #             AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3]),
    #         ),
    #         valid_when = true,
    #     )

    #     push!(layout, missing)
    #     @test layout == AwkwardArray.ByteMaskedArray(
    #         [true, false],
    #         AwkwardArray.ListOffsetArray(
    #             [0, 3, 3],
    #             AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3]),
    #         ),
    #         valid_when = true,
    #     )

    #     append!(
    #         layout,
    #         Vector{Union{Missing,Vector{Float64}}}([[4.4, 5.5], missing, [6.6]]),
    #     )
    #     @test layout == AwkwardArray.ByteMaskedArray(
    #         [true, false, true, false, true],
    #         AwkwardArray.ListOffsetArray(
    #             [0, 3, 3, 5, 5, 6],
    #             AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5, 6.6]),
    #         ),
    #         valid_when = true,
    #     )
    # end

    # ### BitMaskedArray #######################################################

    # begin
    #     layout = AwkwardArray.BitMaskedArray(
    #         BitVector([false, true, true, false, false]),
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #         valid_when = false,
    #     )
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 5
    #     @test layout[1] == 1.1
    #     @test ismissing(layout[2])
    #     @test ismissing(layout[3])
    #     @test layout[4] == 4.4
    #     @test layout[5] == 5.5
    #     @test layout[4:5] == AwkwardArray.PrimitiveArray([4.4, 5.5])
    #     tmp = 0.0
    #     for x in layout
    #         if !ismissing(x)
    #             @test x < 6
    #             tmp += x
    #         end
    #     end
    #     @test tmp == 11.0

    #     push!(layout, 6.6)
    #     @test length(layout) == 6
    #     @test layout[6] == 6.6

    #     AwkwardArray.push_null!(layout)
    #     @test length(layout) == 7
    #     @test ismissing(layout[7])

    #     AwkwardArray.push_dummy!(layout)
    #     @test length(layout) == 8
    #     @test ismissing(layout[8])
    #     @test AwkwardArray.is_valid(layout)

    #     @inferred layout[2:5]

    #     @test AwkwardArray.to_vector(layout, na = nothing) ==
    #           [1.1, nothing, nothing, 4.4, 5.5, 6.6, nothing, nothing]
    # end

    # begin
    #     layout = AwkwardArray.BitMaskedArray(
    #         BitVector([true, true, false]),
    #         AwkwardArray.ListOffsetArray(
    #             [0, 3, 3, 5],
    #             AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #         ),
    #         valid_when = true,
    #     )
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 3

    #     sublayout = layout.content.content

    #     push!(sublayout, 6.6)
    #     push!(sublayout, 7.7)
    #     push!(sublayout, 8.8)
    #     push!(sublayout, 9.9)
    #     AwkwardArray.end_list!(layout)

    #     @test length(layout) == 4
    #     @test layout[4] == AwkwardArray.PrimitiveArray([6.6, 7.7, 8.8, 9.9])

    #     AwkwardArray.push_null!(layout)
    #     @test length(layout) == 5
    #     @test ismissing(layout[5])

    #     AwkwardArray.push_dummy!(layout)
    #     @test length(layout) == 6
    #     @test ismissing(layout[6])
    #     @test AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.BitMaskedArray(
    #         BitVector([false, false, true, true, false]),
    #         AwkwardArray.RecordArray(
    #             NamedTuple{(:a, :b)}((
    #                 AwkwardArray.PrimitiveArray([1, 2, 3, 4, 5]),
    #                 AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #             )),
    #         ),
    #         valid_when = false,
    #     )
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 5

    #     a_layout = layout.content.contents[:a]
    #     b_layout = layout.content.contents[:b]

    #     push!(a_layout, 6)
    #     push!(b_layout, 6.6)
    #     AwkwardArray.end_record!(layout)
    #     @test length(layout) == 6
    #     @test layout[6][:a] == 6
    #     @test layout[6][:b] == 6.6
    #     @test layout[:a][6] == 6
    #     @test layout[:b][6] == 6.6

    #     AwkwardArray.push_null!(layout)
    #     @test length(layout) == 7
    #     @test ismissing(layout[7])

    #     AwkwardArray.push_dummy!(layout)
    #     @test length(layout) == 8
    #     @test ismissing(layout[8])
    #     @test AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.BitMaskedArray{
    #         AwkwardArray.ListOffsetArray{
    #             AwkwardArray.Index64,
    #             AwkwardArray.PrimitiveArray{Float64},
    #         },
    #     }()

    #     push!(layout, [1.1, 2.2, 3.3])
    #     @test layout == AwkwardArray.ByteMaskedArray(
    #         [true],
    #         AwkwardArray.ListOffsetArray(
    #             [0, 3],
    #             AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3]),
    #         ),
    #         valid_when = true,
    #     )

    #     push!(layout, missing)
    #     @test layout == AwkwardArray.ByteMaskedArray(
    #         [true, false],
    #         AwkwardArray.ListOffsetArray(
    #             [0, 3, 3],
    #             AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3]),
    #         ),
    #         valid_when = true,
    #     )

    #     append!(
    #         layout,
    #         Vector{Union{Missing,Vector{Float64}}}([[4.4, 5.5], missing, [6.6]]),
    #     )
    #     @test layout == AwkwardArray.ByteMaskedArray(
    #         [true, false, true, false, true],
    #         AwkwardArray.ListOffsetArray(
    #             [0, 3, 3, 5, 5, 6],
    #             AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5, 6.6]),
    #         ),
    #         valid_when = true,
    #     )
    # end

    # ### UnmaskedArray ########################################################

    # begin
    #     layout = AwkwardArray.UnmaskedArray(
    #         AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #     )
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 5
    #     @test layout[1] == 1.1
    #     @test layout[2] == 2.2
    #     @test layout[3] == 3.3
    #     @test layout[4] == 4.4
    #     @test layout[5] == 5.5
    #     @test layout[4:5] == AwkwardArray.PrimitiveArray([4.4, 5.5])
    #     tmp = 0.0
    #     for x in layout
    #         if !ismissing(x)
    #             @test x < 6
    #             tmp += x
    #         end
    #     end
    #     @test tmp == 16.5

    #     push!(layout, 6.6)
    #     @test length(layout) == 6
    #     @test layout[6] == 6.6

    #     AwkwardArray.push_dummy!(layout)
    #     @test length(layout) == 7
    #     @test layout[7] == 0.0
    #     @test AwkwardArray.is_valid(layout)

    #     @test AwkwardArray.to_vector(layout) == [1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 0.0]
    # end

    # begin
    #     layout = AwkwardArray.UnmaskedArray(
    #         AwkwardArray.ListOffsetArray(
    #             [0, 3, 3, 5],
    #             AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #         ),
    #     )
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 3

    #     sublayout = layout.content.content

    #     push!(sublayout, 6.6)
    #     push!(sublayout, 7.7)
    #     push!(sublayout, 8.8)
    #     push!(sublayout, 9.9)
    #     AwkwardArray.end_list!(layout)

    #     @test length(layout) == 4
    #     @test layout[4] == AwkwardArray.PrimitiveArray([6.6, 7.7, 8.8, 9.9])

    #     AwkwardArray.push_dummy!(layout)
    #     @test length(layout) == 5
    #     @test layout[5] == AwkwardArray.PrimitiveArray([])
    #     @test AwkwardArray.is_valid(layout)

    #     @inferred layout[1]
    #     @inferred layout[1][1]
    #     @inferred layout[2:3]
    # end

    # begin
    #     layout = AwkwardArray.UnmaskedArray(
    #         AwkwardArray.RecordArray(
    #             NamedTuple{(:a, :b)}((
    #                 AwkwardArray.PrimitiveArray([1, 2, 3, 4, 5]),
    #                 AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
    #             )),
    #         ),
    #     )
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 5

    #     a_layout = layout.content.contents[:a]
    #     b_layout = layout.content.contents[:b]

    #     push!(a_layout, 6)
    #     push!(b_layout, 6.6)
    #     AwkwardArray.end_record!(layout)
    #     @test length(layout) == 6
    #     @test layout[6][:a] == 6
    #     @test layout[6][:b] == 6.6
    #     @test layout[:a][6] == 6
    #     @test layout[:b][6] == 6.6

    #     AwkwardArray.push_dummy!(layout)
    #     @test length(layout) == 7
    #     @test layout[7][:a] == 0
    #     @test layout[7][:b] == 0.0
    #     @test layout[:a][7] == 0
    #     @test layout[:b][7] == 0.0
    #     @test AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.BitMaskedArray{
    #         AwkwardArray.ListOffsetArray{
    #             AwkwardArray.Index64,
    #             AwkwardArray.PrimitiveArray{Float64},
    #         },
    #     }()

    #     push!(layout, [1.1, 2.2, 3.3])
    #     @test layout == AwkwardArray.ByteMaskedArray(
    #         [true],
    #         AwkwardArray.ListOffsetArray(
    #             [0, 3],
    #             AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3]),
    #         ),
    #         valid_when = true,
    #     )

    #     append!(layout, Vector{Vector{Float64}}([[4.4, 5.5], [6.6]]))
    #     @test layout == AwkwardArray.ByteMaskedArray(
    #         [true, true, true],
    #         AwkwardArray.ListOffsetArray(
    #             [0, 3, 5, 6],
    #             AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5, 6.6]),
    #         ),
    #         valid_when = true,
    #     )
    # end

    # ### UnionArray ###########################################################

    # begin
    #     layout = AwkwardArray.UnionArray(
    #         Vector{Int8}([0, 0, 0, 1]),
    #         [0, 1, 2, 0],
    #         (
    #             AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3]),
    #             AwkwardArray.ListOffsetArray(
    #                 [0, 2],
    #                 AwkwardArray.PrimitiveArray([4.4, 5.5]),
    #             ),
    #         ),
    #     )
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 4
    #     @test layout[1] == 1.1
    #     @test layout[2] == 2.2
    #     @test layout[3] == 3.3
    #     @test layout[4] == AwkwardArray.PrimitiveArray([4.4, 5.5])

    #     tmp = 0.0
    #     for x in layout
    #         if isa(x, AwkwardArray.PrimitiveArray)
    #             for y in x
    #                 @test y < 6
    #                 tmp += y
    #             end
    #         else
    #             @test x < 6
    #             tmp += x
    #         end
    #     end
    #     @test tmp == 16.5

    #     @test layout == layout

    #     @test layout[2:4][1] == 2.2
    #     @test layout[2:4][2] == 3.3
    #     @test layout[2:4][3] == AwkwardArray.PrimitiveArray([4.4, 5.5])
    #     @inferred layout[2:4]

    #     @test AwkwardArray.to_vector(layout) == [1.1, 2.2, 3.3, [4.4, 5.5]]
    # end

    # begin
    #     layout = AwkwardArray.UnionArray{
    #         AwkwardArray.Index8,
    #         AwkwardArray.Index64,
    #         Tuple{
    #             AwkwardArray.PrimitiveArray{Float64},
    #             AwkwardArray.ListOffsetArray{
    #                 AwkwardArray.Index64,
    #                 AwkwardArray.PrimitiveArray{Float64},
    #             },
    #         },
    #     }()
    #     @test AwkwardArray.is_valid(layout)
    #     @test length(layout) == 0

    #     special1 = AwkwardArray.Specialization(layout, 1)
    #     special2 = AwkwardArray.Specialization(layout, 2)
    #     subspecial2 = special2.tagged.content

    #     push!(special1, 1.1)
    #     @test length(layout) == 1
    #     @test layout[1] == 1.1

    #     push!(subspecial2, 2.2)
    #     push!(subspecial2, 3.3)
    #     AwkwardArray.end_list!(special2)
    #     @test length(layout) == 2
    #     @test layout[2][1] == 2.2
    #     @test layout[2][2] == 3.3

    #     @test layout == AwkwardArray.UnionArray(
    #         Vector{Int8}([0, 1]),
    #         [0, 0],
    #         (
    #             AwkwardArray.PrimitiveArray([1.1]),
    #             AwkwardArray.ListOffsetArray(
    #                 [0, 2],
    #                 AwkwardArray.PrimitiveArray([2.2, 3.3]),
    #             ),
    #         ),
    #     )

    #     AwkwardArray.push_dummy!(special1)
    #     @test layout == AwkwardArray.UnionArray(
    #         Vector{Int8}([0, 1, 0]),
    #         [0, 0, 1],
    #         (
    #             AwkwardArray.PrimitiveArray([1.1, 0.0]),
    #             AwkwardArray.ListOffsetArray(
    #                 [0, 2],
    #                 AwkwardArray.PrimitiveArray([2.2, 3.3]),
    #             ),
    #         ),
    #     )

    #     AwkwardArray.push_dummy!(special2)
    #     @test layout == AwkwardArray.UnionArray(
    #         Vector{Int8}([0, 1, 0, 1]),
    #         [0, 0, 1, 1],
    #         (
    #             AwkwardArray.PrimitiveArray([1.1, 0.0]),
    #             AwkwardArray.ListOffsetArray(
    #                 [0, 2, 2],
    #                 AwkwardArray.PrimitiveArray([2.2, 3.3]),
    #             ),
    #         ),
    #     )

    #     @test AwkwardArray.is_valid(layout)
    # end

    # begin
    #     layout = AwkwardArray.UnionArray{
    #         AwkwardArray.Index8,
    #         AwkwardArray.Index64,
    #         Tuple{
    #             AwkwardArray.PrimitiveArray{Float64},
    #             AwkwardArray.ListOffsetArray{
    #                 AwkwardArray.Index64,
    #                 AwkwardArray.PrimitiveArray{Int64},
    #             },
    #         },
    #     }()

    #     push!(layout, 3.14)
    #     @test layout == AwkwardArray.UnionArray(
    #         Vector{Int8}([0]),
    #         [0],
    #         (
    #             AwkwardArray.PrimitiveArray([3.14]),
    #             AwkwardArray.ListOffsetArray([0], AwkwardArray.PrimitiveArray([])),
    #         ),
    #     )

    #     push!(layout, [1, 2, 3])
    #     @test layout == AwkwardArray.UnionArray(
    #         Vector{Int8}([0, 1]),
    #         [0, 0],
    #         (
    #             AwkwardArray.PrimitiveArray([3.14]),
    #             AwkwardArray.ListOffsetArray(
    #                 [0, 3],
    #                 AwkwardArray.PrimitiveArray([1, 2, 3]),
    #             ),
    #         ),
    #     )

    #     append!(layout, Vector{Union{Float64,Vector{Int64}}}([2.71, [4, 5]]))
    #     @test layout == AwkwardArray.UnionArray(
    #         Vector{Int8}([0, 1, 0, 1]),
    #         [0, 0, 1, 1],
    #         (
    #             AwkwardArray.PrimitiveArray([3.14, 2.71]),
    #             AwkwardArray.ListOffsetArray(
    #                 [0, 3, 5],
    #                 AwkwardArray.PrimitiveArray([1, 2, 3, 4, 5]),
    #             ),
    #         ),
    #     )
    # end

    # ### from_iter ############################################################

    # begin
    #     @test AwkwardArray.is_valid(AwkwardArray.from_iter([1, 2, 3]))

    #     @test AwkwardArray.is_valid(AwkwardArray.from_iter([[1, 2], [3]]))

    #     @test AwkwardArray.is_valid(AwkwardArray.from_iter(["one", "two", "three"]))

    #     @test AwkwardArray.is_valid(AwkwardArray.from_iter(Array([1 2 3; 4 5 6])))

    #     @test AwkwardArray.is_valid(
    #         AwkwardArray.from_iter([
    #             NamedTuple{(:a, :b)}((1.1, [1, 2])),
    #             NamedTuple{(:a, :b)}((2.2, [3])),
    #         ]),
    #     )

    #     @test AwkwardArray.is_valid(
    #         AwkwardArray.from_iter([(1.1, [1, 2]), (2.2, [3]), (3.3, [0])]),
    #     )

    #     @test AwkwardArray.is_valid(AwkwardArray.from_iter([1, 2, missing, 3]))

    #     @test AwkwardArray.is_valid(AwkwardArray.from_iter([[1, 2], [3, missing]]))

    #     @test AwkwardArray.is_valid(AwkwardArray.from_iter([[1, 2], missing, [3]]))

    #     @test AwkwardArray.is_valid(
    #         AwkwardArray.from_iter(["one", "two", missing, "three"]),
    #     )

    #     @test AwkwardArray.is_valid(AwkwardArray.from_iter(Array([1 2 missing; 4 5 6])))

    #     @test AwkwardArray.is_valid(
    #         AwkwardArray.from_iter([
    #             NamedTuple{(:a, :b)}((1.1, [1, 2])),
    #             missing,
    #             NamedTuple{(:a, :b)}((2.2, [3])),
    #         ]),
    #     )

    #     @test AwkwardArray.is_valid(
    #         AwkwardArray.from_iter([(1.1, [1, 2]), (2.2, [3]), missing, (3.3, [0])]),
    #     )

    #     @test AwkwardArray.is_valid(
    #         AwkwardArray.from_iter(
    #             Vector{Union{Float64,Vector{Int64}}}([1.1, [1, 2], [3]]),
    #         ),
    #     )

    #     @test AwkwardArray.is_valid(
    #         AwkwardArray.from_iter(
    #             Vector{Union{Float64,String,Vector{Int64}}}([1.1, [1, 2], "hello", [3]]),
    #         ),
    #     )

    #     @test AwkwardArray.is_valid(
    #         AwkwardArray.from_iter(
    #             Vector{Union{Missing,Float64,Vector{Int64}}}([1.1, [1, 2], missing, [3]]),
    #         ),
    #     )

    #     @test AwkwardArray.is_valid(
    #         AwkwardArray.from_iter(
    #             Vector{Union{Missing,Float64,String,Vector{Int64}}}([
    #                 1.1,
    #                 [1, 2],
    #                 "hello",
    #                 missing,
    #                 [3],
    #             ]),
    #         ),
    #     )

    # end

    ### from_buffers/to_buffers ##############################################

    begin
        layout = AwkwardArray.from_buffers(
            """{"class": "NumpyArray", "primitive": "float64", "inner_shape": [], "parameters": {}, "form_key": "node0"}""",
            5,
            Dict(
                "node0-data" => Vector{UInt8}(
                    b"\x9a\x99\x99\x99\x99\x99\xf1?\x9a\x99\x99\x99\x99\x99\x01@ffffff\n@\x9a\x99\x99\x99\x99\x99\x11@\x00\x00\x00\x00\x00\x00\x16@",
                ),
            ),
        )
        @test isa(layout, AwkwardArray.PrimitiveArray)
        @test AwkwardArray.is_valid(layout)
        @test AwkwardArray.to_vector(layout) == [1.1, 2.2, 3.3, 4.4, 5.5]
    end

    begin
        layout = AwkwardArray.from_buffers(
            """{"class": "NumpyArray", "primitive": "int64", "inner_shape": [3, 5], "parameters": {}, "form_key": "node0"}""",
            2,
            Dict(
                "node0-data" => Vector{UInt8}(
                    b"\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x05\x00\x00\x00\x00\x00\x00\x00\x06\x00\x00\x00\x00\x00\x00\x00\x07\x00\x00\x00\x00\x00\x00\x00\x08\x00\x00\x00\x00\x00\x00\x00\t\x00\x00\x00\x00\x00\x00\x00\n\x00\x00\x00\x00\x00\x00\x00\x0b\x00\x00\x00\x00\x00\x00\x00\x0c\x00\x00\x00\x00\x00\x00\x00\r\x00\x00\x00\x00\x00\x00\x00\x0e\x00\x00\x00\x00\x00\x00\x00\x0f\x00\x00\x00\x00\x00\x00\x00\x10\x00\x00\x00\x00\x00\x00\x00\x11\x00\x00\x00\x00\x00\x00\x00\x12\x00\x00\x00\x00\x00\x00\x00\x13\x00\x00\x00\x00\x00\x00\x00\x14\x00\x00\x00\x00\x00\x00\x00\x15\x00\x00\x00\x00\x00\x00\x00\x16\x00\x00\x00\x00\x00\x00\x00\x17\x00\x00\x00\x00\x00\x00\x00\x18\x00\x00\x00\x00\x00\x00\x00\x19\x00\x00\x00\x00\x00\x00\x00\x1a\x00\x00\x00\x00\x00\x00\x00\x1b\x00\x00\x00\x00\x00\x00\x00\x1c\x00\x00\x00\x00\x00\x00\x00\x1d\x00\x00\x00\x00\x00\x00\x00",
                ),
            ),
        )
        @test isa(layout, AwkwardArray.RegularArray)
        @test isa(layout.content, AwkwardArray.RegularArray)
        @test isa(layout.content.content, AwkwardArray.PrimitiveArray)
        @test AwkwardArray.is_valid(layout)
        @test AwkwardArray.to_vector(layout) == [
            [[0, 1, 2, 3, 4], [5, 6, 7, 8, 9], [10, 11, 12, 13, 14]],
            [[15, 16, 17, 18, 19], [20, 21, 22, 23, 24], [25, 26, 27, 28, 29]],
        ]
    end




end   # @testset "AwkwardArray.jl"
