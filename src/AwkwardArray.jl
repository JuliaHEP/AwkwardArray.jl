# using JSON

module AwkwardArray

### Index ################################################################

Index8 = AbstractVector{Int8}
IndexU8 = AbstractVector{UInt8}
Index32 = AbstractVector{Int32}
IndexU32 = AbstractVector{UInt32}
Index64 = AbstractVector{Int64}
IndexBig = Union{Index32,IndexU32,Index64}

### Content ##############################################################

@enum StandardParameters __array__ __list__ __record__ __categorical__ __sorted_map__ __doc__

abstract type Content <: AbstractVector{T where T} end

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

struct PrimitiveArray{T,BUF<:AbstractVector{T}} <: Content
    data::BUF
    something::Int64
    PrimitiveArray(data::BUF, something::Int64 = 123) where {T,BUF<:AbstractVector{T}} =
        new{T,BUF}(data, something)
end

PrimitiveArray{T}(something::Int64 = 123) where {T} =
    PrimitiveArray(Vector{T}([]), something)

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

### ListOffsetArray ######################################################

struct ListOffsetArray{IND<:IndexBig,CON<:Content} <: Content
    offsets::IND
    content::CON
end

ListOffsetArray{IND,CON}() where {IND<:IndexBig} where {CON<:Content} =
    AwkwardArray.ListOffsetArray(IND([0]), CON())

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
