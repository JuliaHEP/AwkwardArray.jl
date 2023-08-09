module AwkwardArray

### Index ################################################################

Index8 = AbstractArray{Int8,1}
IndexU8 = AbstractArray{UInt8,1}
Index32 = AbstractArray{Int32,1}
IndexU32 = AbstractArray{UInt32,1}
Index64 = AbstractArray{Int64,1}
IndexBig = Union{Index32,IndexU32,Index64}

### Content ##############################################################

abstract type Content <: AbstractArray{T where T,1} end

function Base.iterate(layout::Content)
    start = firstindex(layout)
    stop = lastindex(layout)
    if stop >= start
        layout[start], start + 1
    else
        nothing
    end
end

function Base.iterate(layout::Content, state)
    stop = lastindex(layout)
    if stop >= state
        layout[state], state + 1
    else
        nothing
    end
end

Base.size(layout::Content) = (length(layout),)

### PrimitiveArray #######################################################

struct PrimitiveArray{T,ARRAY<:AbstractArray{T,1}} <: Content
    data::ARRAY
end

PrimitiveArray{T}() where {T} = PrimitiveArray(Vector{T}([]))

is_valid(layout::PrimitiveArray) = true
Base.length(layout::PrimitiveArray) = length(layout.data)
Base.firstindex(layout::PrimitiveArray) = firstindex(layout.data)
Base.lastindex(layout::PrimitiveArray) = lastindex(layout.data)

function Base.getindex(layout::PrimitiveArray, i::Int)
    layout.data[i]
end

function Base.getindex(layout::PrimitiveArray, r::UnitRange{Int})
    PrimitiveArray(layout.data[r])
end

function Base.:(==)(layout1::PrimitiveArray, layout2::PrimitiveArray)
    layout1.data == layout2.data
end

function push!(layout::PrimitiveArray{T}, x::T) where {T}
    Base.push!(layout.data, x)
    layout
end

### PrimitiveMultiArray ##################################################

struct PrimitiveMultiArray{T,ARRAY<:AbstractArray{T,1}} <: Content
    data::ARRAY
    shape_strides::Vector{Tuple{Int64,Int64}}
end

PrimitiveMultiArray{T}(shape_strides::Vector{Tuple{Int64,Int64}}) where {T} =
    PrimitiveMultiArray(Vector{T}([]), shape_strides)

is_valid(layout::PrimitiveMultiArray) =
    length(layout.shape_strides) >= 2 &&
    layout.shape_strides[1][1] >= 0 &&
    layout.shape_strides[1][2] >= 0 &&
    layout.shape_strides[1][1] * layout.shape_strides[1][2] <= length(layout.data)
# TODO: recurse into each lower number of dimensions.

Base.length(layout::PrimitiveMultiArray) = layout.shape_strides[1][1]
Base.firstindex(layout::PrimitiveMultiArray) = 1
Base.lastindex(layout::PrimitiveMultiArray) = length(layout)

function Base.getindex(layout::PrimitiveMultiArray, i::Int)
    start = (i - 1) * layout.shape_strides[1][2] + firstindex(layout.data)
    stop = i * layout.shape_strides[1][2] + firstindex(layout.data)
    if length(layout.shape_strides) == 2
        if layout.shape_strides[2][2] > 0
            PrimitiveArray(layout.data[start:layout.shape_strides[2][2]:stop])
        else
            PrimitiveArray(layout.data[stop:layout.shape_strides[2][2]:start])
        end
    else
        PrimitiveMultiArray(layout.data[start:stop], layout.shape_strides[2:end])
    end
end

function Base.getindex(layout::PrimitiveMultiArray, r::UnitRange{Int})
    start = (r.start - 1) * layout.shape_strides[1][2] + firstindex(layout.data)
    stop = (r.stop - 1) * layout.shape_strides[1][2] + firstindex(layout.data)


# This is getting nasty.



    PrimitiveMultiArray(layout.data[r])
end

# function Base.:(==)(layout1::PrimitiveMultiArray, layout2::PrimitiveMultiArray)
#     layout1.data == layout2.data
# end

# function push!(layout::PrimitiveMultiArray{T}, x::T) where {T}
#     Base.push!(layout.data, x)
#     layout
# end

### ListOffsetArray ######################################################

struct ListOffsetArray{INDEX<:IndexBig,CONTENT<:Content} <: Content
    offsets::INDEX
    content::CONTENT
end

ListOffsetArray{INDEX,CONTENT}() where {INDEX<:IndexBig} where {CONTENT<:Content} =
    AwkwardArray.ListOffsetArray(INDEX([0]), CONTENT())

function is_valid(layout::ListOffsetArray)
    if length(layout.offsets) < 1
        return false
    end
    if layout.offsets[end] + firstindex(layout.content) - 1 > lastindex(layout.content)
        return false
    end
    for i in eachindex(layout)
        if layout.offsets[i] < 0 || layout.offsets[i+1] < layout.offsets[i]
            return false
        end
    end
    return true
end

Base.length(layout::ListOffsetArray) = length(layout.offsets) - 1
Base.firstindex(layout::ListOffsetArray) = firstindex(layout.offsets)
Base.lastindex(layout::ListOffsetArray) = lastindex(layout.offsets) - 1

function Base.getindex(layout::ListOffsetArray, i::Int)
    start = layout.offsets[i] + firstindex(layout.content)
    stop = layout.offsets[i+1] + firstindex(layout.content) - 1
    layout.content[start:stop]
end

function Base.getindex(layout::ListOffsetArray, r::UnitRange{Int})
    ListOffsetArray(layout.offsets[(r.start):(r.stop+1)], layout.content)
end

function Base.:(==)(layout1::ListOffsetArray, layout2::ListOffsetArray)
    if length(layout1) != length(layout2)
        return false
    else
        for (x, y) in zip(layout1, layout2)
            if x != y
                return false
            end
        end
        return true
    end
end

function end_list!(layout::ListOffsetArray)
    Base.push!(layout.offsets, length(layout.content))
    layout
end

end
