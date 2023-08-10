# using JSON

module AwkwardArray

### Index ################################################################

const Index8 = AbstractVector{Int8}
const IndexU8 = AbstractVector{UInt8}
const Index32 = AbstractVector{Int32}
const IndexU32 = AbstractVector{UInt32}
const Index64 = AbstractVector{Int64}
const IndexBig = Union{Index32,IndexU32,Index64}

### Parameters ###########################################################

default = :default
char = :char
byte = :byte
string = :string
bytestring = :bytestring
categorical = :categorical
sorted_map = :sorted_map

struct Parameters
    string_valued::Base.ImmutableDict{String,String}
    any_valued::Base.ImmutableDict{String,Any}
end

Parameters() =
    Parameters(Base.ImmutableDict{String,String}(), Base.ImmutableDict{String,Any}())

function Parameters(pairs::Vararg{Pair{String,<:Any}})
    out = Parameters()
    for pair in pairs
        out = with_parameter(out, pair)
    end
    out
end

with_parameter(parameters::Parameters, pair::Pair{String,String}) =
    Parameters(Base.ImmutableDict(parameters.string_valued, pair), parameters.any_valued)

with_parameter(parameters::Parameters, pair::Pair{String,<:Any}) =
    Parameters(parameters.string_valued, Base.ImmutableDict(parameters.any_valued, pair))

has_parameter(parameters::Parameters, key::String) =
    if haskey(parameters.string_valued, key)
        true
    elseif haskey(parameters.any_valued, key)
        true
    else
        false
    end

get_parameter(parameters::Parameters, key::String) =
    if haskey(parameters.string_valued, key)
        parameters.string_valued[key]
    elseif haskey(parameters.any_valued, key)
        parameters.any_valued[key]
    else
        nothing
    end

### Content ##############################################################

abstract type Content{BEHAVIOR} <: AbstractVector{ITEM where ITEM} end

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

struct PrimitiveArray{ITEM,BUFFER<:AbstractVector{ITEM},BEHAVIOR} <: Content{BEHAVIOR}
    data::BUFFER
    parameters::Parameters
    PrimitiveArray(
        data::BUFFER;
        parameters::Parameters = Parameters(),
        behavior::Symbol = :default,
    ) where {ITEM,BUFFER<:AbstractVector{ITEM}} =
        new{ITEM,BUFFER,behavior}(data, parameters)
end

PrimitiveArray{ITEM}(;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {ITEM} =
    PrimitiveArray(Vector{ITEM}([]), parameters = parameters, behavior = behavior)

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

function push!(layout::PrimitiveArray{ITEM}, x::ITEM) where {ITEM}
    Base.push!(layout.data, x)
    layout
end

### ListOffsetArray ######################################################

struct ListOffsetArray{INDEX<:IndexBig,CONTENT<:Content,BEHAVIOR} <: Content{BEHAVIOR}
    offsets::INDEX
    content::CONTENT
    parameters::Parameters
    ListOffsetArray(
        offsets::INDEX,
        content::CONTENT;
        parameters::Parameters = Parameters(),
        behavior::Symbol = :default,
    ) where {INDEX<:IndexBig,CONTENT<:Content} =
        new{INDEX,CONTENT,behavior}(offsets, content, parameters)
end

ListOffsetArray{INDEX,CONTENT}(;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {INDEX<:IndexBig} where {CONTENT<:Content} = AwkwardArray.ListOffsetArray(
    INDEX([0]),
    CONTENT(),
    parameters = parameters,
    behavior = behavior,
)

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

### ListOffsetArray with behavior = :string ##############################

function Base.getindex(
    layout::ListOffsetArray{INDEX,PrimitiveArray{UInt8,BUFFER,:char},:string},
    i::Int,
) where {INDEX<:IndexBig,BUFFER<:AbstractVector{UInt8}}
    String(
        getindex(
            ListOffsetArray(layout.offsets, PrimitiveArray(layout.content.data)),
            i,
        ).data,
    )
end

### ListOffsetArray with behavior = :bytestring ##########################

function Base.getindex(
    layout::ListOffsetArray{INDEX,PrimitiveArray{UInt8,BUFFER,:byte},:bytestring},
    i::Int,
) where {INDEX<:IndexBig,BUFFER<:AbstractVector{UInt8}}
    getindex(ListOffsetArray(layout.offsets, PrimitiveArray(layout.content.data)), i).data
end

end
