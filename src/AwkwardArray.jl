module AwkwardArray

abstract type Content end

function Base.iterate(x::Content)
    start = firstindex(x)
    stop = lastindex(x)
    if stop >= start
        x[start], start + 1
    else
        nothing
    end
end

function Base.iterate(x::Content, state)
    stop = lastindex(x)
    if stop >= state
        x[state], state + 1
    else
        nothing
    end
end

### PrimitiveArray #######################################################

struct PrimitiveArray{T} <: Content
    data::AbstractArray{T,1}
end

function is_valid(x::PrimitiveArray)
    true
end

function Base.length(x::PrimitiveArray)
    Base.length(x.data)
end

function Base.firstindex(x::PrimitiveArray)
    Base.firstindex(x.data)
end

function Base.lastindex(x::PrimitiveArray)
    Base.lastindex(x.data)
end

function Base.getindex(x::PrimitiveArray, i::Int)
    x.data[i]
end

function Base.getindex(x::PrimitiveArray, r::UnitRange{Int})
    PrimitiveArray(x.data[(r.start):(r.stop)])
end

function Base.:(==)(x::PrimitiveArray, y::PrimitiveArray)
    x.data == y.data
end

### ListOffsetArray ######################################################

struct ListOffsetArray{T<:Union{Int32,UInt32,Int64}} <: Content
    offsets::AbstractArray{T,1}
    content::Content
end

function is_valid(x::ListOffsetArray)
    true
end

function Base.length(x::ListOffsetArray)
    Base.length(x.offsets) - 1
end

function Base.firstindex(x::ListOffsetArray)
    Base.firstindex(x.offsets)
end

function Base.lastindex(x::ListOffsetArray)
    Base.lastindex(x.offsets) - 1
end

function Base.getindex(x::ListOffsetArray, i::Int)
    start = x.offsets[i] + Base.firstindex(x.content)
    stop = x.offsets[i+1] + Base.firstindex(x.content) - 1
    x.content[start:stop]
end

function Base.getindex(x::ListOffsetArray, r::UnitRange{Int})
    ListOffsetArray(x.offsets[(r.start):(r.stop+1)], x.content)
end

function Base.:(==)(x::ListOffsetArray, y::ListOffsetArray)
    if length(x) != length(y)
        return false
    else
        for (xi, yi) in zip(x, y)
            if xi != yi
                return false
            end
        end
        return true
    end
end

end
