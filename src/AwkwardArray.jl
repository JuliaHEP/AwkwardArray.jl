module AwkwardArray

### Index ################################################################

Index8 = AbstractArray{Int8,1}
IndexU8 = AbstractArray{UInt8,1}
Index32 = AbstractArray{Int32,1}
IndexU32 = AbstractArray{UInt32,1}
Index64 = AbstractArray{Int64,1}

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

function Base.size(layout::Content)
    (length(layout),)
end

### PrimitiveArray #######################################################

struct PrimitiveArray{T,ARRAY<:AbstractArray{T,1}} <: Content
    data::ARRAY
end

function PrimitiveArray{T}() where {T}
    PrimitiveArray(Vector{T}([]))
end

function is_valid(layout::PrimitiveArray)
    true
end

function Base.length(layout::PrimitiveArray)
    length(layout.data)
end

function Base.firstindex(layout::PrimitiveArray)
    firstindex(layout.data)
end

function Base.lastindex(layout::PrimitiveArray)
    lastindex(layout.data)
end

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
end

### ListOffsetArray ######################################################

struct ListOffsetArray{INDEX<:Union{Index32,IndexU32,Index64},CONTENT<:Content} <: Content
    offsets::INDEX
    content::CONTENT
end

function ListOffsetArray{
    INDEX,
    CONTENT,
}() where {INDEX<:Union{Index32,IndexU32,Index64}} where {CONTENT<:Content}
    AwkwardArray.ListOffsetArray(INDEX([0]), CONTENT())
end

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

function Base.length(layout::ListOffsetArray)
    length(layout.offsets) - 1
end

function Base.firstindex(layout::ListOffsetArray)
    firstindex(layout.offsets)
end

function Base.lastindex(layout::ListOffsetArray)
    lastindex(layout.offsets) - 1
end

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
    layout.content
end

end
