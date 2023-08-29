# using JSON

module AwkwardArray

### Index ################################################################

const Index8 = AbstractVector{Int8}
const IndexU8 = AbstractVector{UInt8}
const Index32 = AbstractVector{Int32}
const IndexU32 = AbstractVector{UInt32}
const Index64 = AbstractVector{Int64}
const IndexBig = Union{Index32,IndexU32,Index64}
const IndexBool = Union{Index8,AbstractVector{Bool}}

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

function compatible(parameters1::Parameters, parameters2::Parameters)
    if get(parameters1.string_valued, "__array__", "") !=
       get(parameters2.string_valued, "__array__", "")
        return false
    end
    if get(parameters1.string_valued, "__list__", "") !=
       get(parameters2.string_valued, "__list__", "")
        return false
    end
    if get(parameters1.string_valued, "__record__", "") !=
       get(parameters2.string_valued, "__record__", "")
        return false
    end
    return true
end

Base.length(parameters::Parameters) =
    length(parameters.string_valued) + length(parameters.any_valued)

Base.keys(parameters::Parameters) =
    union(keys(parameters.any_valued), keys(parameters.string_valued))

Base.show(io::IO, parameters::Parameters) = print(
    io,
    "Parameters(" *
    join(
        [
            "$(repr(pair[1])) => $(repr(pair[2]))" for
            pair in merge(parameters.any_valued, parameters.string_valued)
        ],
        ", ",
    ) *
    ")",
)

### Content ##############################################################

struct Unset end

abstract type Content{BEHAVIOR} <: AbstractVector{ITEM where ITEM} end

parameters_of(content::CONTENT) where {CONTENT<:Content} = content.parameters
has_parameter(content::CONTENT, key::String) where {CONTENT<:Content} =
    has_parameter(content.parameters, key)
get_parameter(content::CONTENT, key::String) where {CONTENT<:Content} =
    get_parameter(content.parameters, key)

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

function Base.:(==)(layout1::Content, layout2::Content)
    if length(layout1) != length(layout2)
        return false
    end
    for (x, y) in zip(layout1, layout2)
        if ismissing(x) && ismissing(y)
        elseif x == y
        else
            return false
        end
    end
    return true
end

function Base.append!(layout::Content, input)
    for item in input
        push!(layout, item)
    end
    layout
end

### PrimitiveArray #######################################################
#
# Note: all Python NumpyArrays have to be converted to 1-dimensional
#       (inner_shape == ()) with RegularArrays when converting to Julia.

abstract type LeafType{BEHAVIOR} <: Content{BEHAVIOR} end

struct PrimitiveArray{ITEM,BUFFER<:AbstractVector{ITEM},BEHAVIOR} <: LeafType{BEHAVIOR}
    data::BUFFER
    parameters::Parameters
    PrimitiveArray(
        data::BUFFER;
        parameters::Parameters = Parameters(),
        behavior::Symbol = :default,
    ) where {ITEM,BUFFER<:AbstractVector{ITEM}} =
        new{ITEM,BUFFER,behavior}(data, parameters)
end

PrimitiveArray{ITEM,BUFFER,BEHAVIOR}(;
    parameters::Parameters = Parameters(),
) where {ITEM,BUFFER<:AbstractVector{ITEM},BEHAVIOR} =
    PrimitiveArray(BUFFER([]), parameters = parameters, behavior = BEHAVIOR)

PrimitiveArray{ITEM,BUFFER}(;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {ITEM,BUFFER<:AbstractVector{ITEM}} =
    PrimitiveArray(BUFFER([]), parameters = parameters, behavior = behavior)

PrimitiveArray{ITEM}(;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {ITEM} =
    PrimitiveArray(Vector{ITEM}([]), parameters = parameters, behavior = behavior)

function copy(
    layout::PrimitiveArray{ITEM,BUFFER1,BEHAVIOR};
    data::Union{Unset,BUFFER2} = Unset(),
    parameters::Union{Unset,Parameters} = Unset(),
    behavior::Union{Unset,Symbol} = Unset(),
) where {ITEM,BUFFER1<:AbstractVector{ITEM},BUFFER2<:AbstractVector,BEHAVIOR}
    if isa(data, Unset)
        data = layout.data
    end
    if isa(parameters, Unset)
        parameters = parameters_of(layout)
    end
    if isa(behavior, Unset)
        behavior = BEHAVIOR
    end
    PrimitiveArray(data, parameters = parameters, behavior = behavior)
end

is_valid(layout::PrimitiveArray) = true
Base.length(layout::PrimitiveArray) = length(layout.data)
Base.firstindex(layout::PrimitiveArray) = firstindex(layout.data)
Base.lastindex(layout::PrimitiveArray) = lastindex(layout.data)

Base.getindex(layout::PrimitiveArray, i::Int) = layout.data[i]

Base.getindex(layout::PrimitiveArray, r::UnitRange{Int}) =
    copy(layout, data = layout.data[r])

function Base.:(==)(layout1::PrimitiveArray, layout2::PrimitiveArray)
    if length(layout1) == 0 && length(layout2) == 0
        true
    else
        layout1.data == layout2.data
    end
end

function Base.push!(layout::PrimitiveArray{ITEM}, input::ITEM) where {ITEM}
    push!(layout.data, input)
    layout
end

function Base.push!(layout::PrimitiveArray{ITEM}, input::Number) where {ITEM}
    push!(layout.data, ITEM(input))
end

function push_dummy!(layout::PrimitiveArray{ITEM}) where {ITEM}
    push!(layout, zero(ITEM))
end

### EmptyArray ###########################################################

struct EmptyArray{BEHAVIOR} <: LeafType{BEHAVIOR}
    EmptyArray(; behavior::Symbol = :default) = new{behavior}()
end

copy(behavior::Union{Unset,Symbol} = Unset()) = EmptyArray(behavior = behavior)

parameters_of(content::EmptyArray) = Parameters()
has_parameter(content::EmptyArray, key::String) = false
get_parameter(content::EmptyArray, key::String) = nothing

is_valid(layout::EmptyArray) = true
Base.length(layout::EmptyArray) = 0
Base.firstindex(layout::EmptyArray) = 1
Base.lastindex(layout::EmptyArray) = 0

Base.getindex(layout::EmptyArray, i::Int) = [][1]  # throw BoundsError

function Base.getindex(layout::EmptyArray, r::UnitRange{Int})
    if r.start < r.stop
        [][1]  # throw BoundsError
    else
        layout
    end
end

function Base.push!(layout::EmptyArray, input)
    error("attempting to fill $(typeof(layout)) with data")
end

### ListOffsetArray ######################################################

abstract type ListType{BEHAVIOR} <: Content{BEHAVIOR} end

struct ListOffsetArray{INDEX<:IndexBig,CONTENT<:Content,BEHAVIOR} <: ListType{BEHAVIOR}
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

ListOffsetArray{INDEX,CONTENT,BEHAVIOR}(;
    parameters::Parameters = Parameters(),
) where {INDEX<:IndexBig} where {CONTENT<:Content} where {BEHAVIOR} =
    ListOffsetArray(INDEX([0]), CONTENT(), parameters = parameters, behavior = BEHAVIOR)

ListOffsetArray{INDEX,CONTENT}(;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {INDEX<:IndexBig} where {CONTENT<:Content} =
    ListOffsetArray(INDEX([0]), CONTENT(), parameters = parameters, behavior = behavior)

function copy(
    layout::ListOffsetArray{INDEX1,CONTENT1,BEHAVIOR};
    offsets::Union{Unset,INDEX2} = Unset(),
    content::Union{Unset,CONTENT2} = Unset(),
    parameters::Union{Unset,Parameters} = Unset(),
    behavior::Union{Unset,Symbol} = Unset(),
) where {INDEX1<:IndexBig,INDEX2<:IndexBig,CONTENT1<:Content,CONTENT2<:Content,BEHAVIOR}
    if isa(offsets, Unset)
        offsets = layout.offsets
    end
    if isa(content, Unset)
        content = layout.content
    end
    if isa(parameters, Unset)
        parameters = parameters_of(layout)
    end
    if isa(behavior, Unset)
        behavior = BEHAVIOR
    end
    ListOffsetArray(offsets, content, parameters = parameters, behavior = behavior)
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
    return is_valid(layout.content)
end

Base.length(layout::ListOffsetArray) = length(layout.offsets) - 1
Base.firstindex(layout::ListOffsetArray) = firstindex(layout.offsets)
Base.lastindex(layout::ListOffsetArray) = lastindex(layout.offsets) - 1

function Base.getindex(layout::ListOffsetArray, i::Int)
    start = layout.offsets[i] + firstindex(layout.content)
    stop = layout.offsets[i+1] + firstindex(layout.content) - 1
    layout.content[start:stop]
end

Base.getindex(layout::ListOffsetArray, r::UnitRange{Int}) =
    copy(layout, offsets = layout.offsets[(r.start):(r.stop+1)])

Base.getindex(layout::ListOffsetArray, f::Symbol) =
    copy(layout, content = layout.content[f])

function end_list!(layout::ListOffsetArray)
    push!(layout.offsets, length(layout.content))
    layout
end

function push_dummy!(layout::ListOffsetArray)
    end_list!(layout)
end

### ListArray ############################################################

struct ListArray{INDEX<:IndexBig,CONTENT<:Content,BEHAVIOR} <: ListType{BEHAVIOR}
    starts::INDEX
    stops::INDEX
    content::CONTENT
    parameters::Parameters
    ListArray(
        starts::INDEX,
        stops::INDEX,
        content::CONTENT;
        parameters::Parameters = Parameters(),
        behavior::Symbol = :default,
    ) where {INDEX<:IndexBig,CONTENT<:Content} =
        new{INDEX,CONTENT,behavior}(starts, stops, content, parameters)
end

ListArray{INDEX,CONTENT,BEHAVIOR}(;
    parameters::Parameters = Parameters(),
) where {INDEX<:IndexBig} where {CONTENT<:Content} where {BEHAVIOR} =
    ListArray(INDEX([]), INDEX([]), CONTENT(), parameters = parameters, behavior = BEHAVIOR)

ListArray{INDEX,CONTENT}(;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {INDEX<:IndexBig} where {CONTENT<:Content} =
    ListArray(INDEX([]), INDEX([]), CONTENT(), parameters = parameters, behavior = behavior)

function copy(
    layout::ListArray{INDEX1,CONTENT1,BEHAVIOR};
    starts::Union{Unset,INDEX2} = Unset(),
    stops::Union{Unset,INDEX2} = Unset(),
    content::Union{Unset,CONTENT2} = Unset(),
    parameters::Union{Unset,Parameters} = Unset(),
    behavior::Union{Unset,Symbol} = Unset(),
) where {INDEX1<:IndexBig,INDEX2<:IndexBig,CONTENT1<:Content,CONTENT2<:Content,BEHAVIOR}
    if isa(starts, Unset)
        starts = layout.starts
    end
    if isa(stops, Unset)
        stops = layout.stops
    end
    if isa(content, Unset)
        content = layout.content
    end
    if isa(parameters, Unset)
        parameters = parameters_of(layout)
    end
    if isa(behavior, Unset)
        behavior = BEHAVIOR
    end
    ListArray(starts, stops, content, parameters = parameters, behavior = behavior)
end

function is_valid(layout::ListArray)
    if length(layout.starts) < length(layout.stops)
        return false
    end
    adjustment = firstindex(layout.starts) - firstindex(layout.stops)
    for i in eachindex(layout.starts)
        start = layout.starts[i]
        stop = layout.stops[i-adjustment]
        if start != stop
            if start < 0 || start > stop || stop > length(layout.content)
                return false
            end
        end
    end
    return is_valid(layout.content)
end

Base.length(layout::ListArray) = length(layout.starts)
Base.firstindex(layout::ListArray) = firstindex(layout.starts)
Base.lastindex(layout::ListArray) = lastindex(layout.starts)

function Base.getindex(layout::ListArray, i::Int)
    adjustment = firstindex(layout.starts) - firstindex(layout.stops)
    start = layout.starts[i] + firstindex(layout.content)
    stop = layout.stops[i-adjustment] - layout.starts[i] + start - 1
    layout.content[start:stop]
end

function Base.getindex(layout::ListArray, r::UnitRange{Int})
    adjustment = firstindex(layout.starts) - firstindex(layout.stops)
    copy(
        layout,
        starts = layout.starts[r.start:r.stop],
        stops = layout.stops[(r.start-adjustment):(r.stop-adjustment)],
    )
end

Base.getindex(layout::ListArray, f::Symbol) = copy(layout, content = layout.content[f])

function end_list!(layout::ListArray)
    if isempty(layout.stops)
        push!(layout.starts, 0)
    else
        push!(layout.starts, layout.stops[end])
    end
    push!(layout.stops, length(layout.content))
end

function push_dummy!(layout::ListArray)
    end_list!(layout)
end

### RegularArray #########################################################

mutable struct RegularArray{CONTENT<:Content,BEHAVIOR} <: ListType{BEHAVIOR}
    const content::CONTENT
    size::Int64
    length::Int64
    const parameters::Parameters
    RegularArray(
        content::CONTENT,
        size::Int;
        zeros_length::Int = 0,
        parameters::Parameters = Parameters(),
        behavior::Symbol = :default,
    ) where {CONTENT<:Content} = new{CONTENT,behavior}(content, size, if size == 0
        zeros_length
    else
        div(length(content), size)
    end, parameters)
end

RegularArray{CONTENT}(
    size::Int;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {CONTENT<:Content} = RegularArray(
    CONTENT(),
    size,
    zeros_length = 0,
    parameters = parameters,
    behavior = behavior,
)

RegularArray{CONTENT,BEHAVIOR}(;
    parameters::Parameters = Parameters(),
) where {CONTENT<:Content,BEHAVIOR} = RegularArray(
    CONTENT(),
    -1,
    zeros_length = 0,
    parameters = parameters,
    behavior = BEHAVIOR,
)

RegularArray{CONTENT}(;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {CONTENT<:Content} = RegularArray(
    CONTENT(),
    -1,
    zeros_length = 0,
    parameters = parameters,
    behavior = behavior,
)

function copy(
    layout::RegularArray{CONTENT1,BEHAVIOR};
    content::Union{Unset,CONTENT2} = Unset(),
    size::Union{Unset,Int} = Unset(),
    zeros_length::Union{Unset,Int} = Unset(),
    parameters::Union{Unset,Parameters} = Unset(),
    behavior::Union{Unset,Symbol} = Unset(),
) where {CONTENT1<:Content,CONTENT2<:Content,BEHAVIOR}
    if isa(content, Unset)
        content = layout.content
    end
    if isa(size, Unset)
        size = layout.size
    end
    if isa(zeros_length, Unset)
        zeros_length = length(layout)
    end
    if isa(parameters, Unset)
        parameters = parameters_of(layout)
    end
    if isa(behavior, Unset)
        behavior = BEHAVIOR
    end
    RegularArray(
        content,
        size,
        zeros_length = zeros_length,
        parameters = parameters,
        behavior = behavior,
    )
end

function is_valid(layout::RegularArray)
    if layout.length < 0
        return false
    end
    return is_valid(layout.content)
end

Base.length(layout::RegularArray) = layout.length
Base.firstindex(layout::RegularArray) = 1
Base.lastindex(layout::RegularArray) = length(layout)

function Base.getindex(layout::RegularArray, i::Int)
    size = max(0, layout.size)
    start = (i - firstindex(layout)) * size + firstindex(layout.content)
    stop = (i + 1 - firstindex(layout)) * size + firstindex(layout.content) - 1
    layout.content[start:stop]
end

function Base.getindex(layout::RegularArray, r::UnitRange{Int})
    size = max(0, layout.size)
    start = (r.start - firstindex(layout)) * size + firstindex(layout.content)
    stop = (r.stop - 1 - firstindex(layout)) * size + firstindex(layout.content) + 1
    copy(layout, content = layout.content[start:stop], zeros_length = r.stop - r.start + 1)
end

Base.getindex(layout::RegularArray, f::Symbol) = copy(layout, content = layout.content[f])

function end_list!(layout::RegularArray)
    if layout.size < 0 && layout.length == 0
        layout.size = length(layout.content)
        layout.length = 1
    elseif length(layout.content) == (layout.length + 1) * layout.size
        layout.length += 1
    else
        error(
            "RegularArray list lengths changed: from $(layout.size) to $(length(layout.content) - (layout.length * layout.size))",
        )
    end
end

function push_dummy!(layout::RegularArray)
    for _ = 1:max(0, layout.size)
        push_dummy!(layout.content)
    end
    end_list!(layout)
end

### ListType with behavior = :string #####################################

StringOffsetArray(
    offsets::INDEX,
    data::AbstractVector{UInt8};
    parameters::Parameters = Parameters(),
    char_parameters::Parameters = Parameters(),
) where {INDEX<:IndexBig} = ListOffsetArray(
    offsets,
    PrimitiveArray(data, parameters = char_parameters, behavior = :char),
    parameters = parameters,
    behavior = :string,
)

StringOffsetArray(
    offsets::INDEX,
    data::String;   # data provided as a String, rather than AbstractVector{UInt8}
    parameters::Parameters = Parameters(),
    char_parameters::Parameters = Parameters(),
) where {INDEX<:IndexBig} = StringOffsetArray(
    offsets,
    Vector{UInt8}(data),
    parameters = parameters,
    char_parameters = char_parameters,
)

StringOffsetArray(; parameters = Parameters(), char_parameters = Parameters()) =
    StringOffsetArray(
        Index64([0]),
        Vector{UInt8}([]),
        parameters = parameters,
        char_parameters = char_parameters,
    )

StringArray(
    starts::INDEX,
    stops::INDEX,
    data::AbstractVector{UInt8};
    parameters::Parameters = Parameters(),
    char_parameters::Parameters = Parameters(),
) where {INDEX<:IndexBig} = ListArray(
    starts,
    stops,
    PrimitiveArray(data, parameters = char_parameters, behavior = :char),
    parameters = parameters,
    behavior = :string,
)

StringArray(
    starts::INDEX,
    stops::INDEX,
    data::String;   # data provided as a String, rather than AbstractVector{UInt8}
    parameters::Parameters = Parameters(),
    char_parameters::Parameters = Parameters(),
) where {INDEX<:IndexBig} = StringArray(
    starts,
    stops,
    Vector{UInt8}(data),
    parameters = parameters,
    char_parameters = char_parameters,
)

StringArray(;
    parameters::Parameters = Parameters(),
    char_parameters::Parameters = Parameters(),
) = StringArray(
    Index64([]),
    Index64([]),
    Vector{UInt8}([]),
    parameters = parameters,
    char_parameters = char_parameters,
)

StringRegularArray(
    data::AbstractVector{UInt8},
    size::Int;
    zeros_length::Int = 0,
    parameters::Parameters = Parameters(),
    char_parameters::Parameters = Parameters(),
) = RegularArray(
    PrimitiveArray(data, parameters = char_parameters, behavior = :char),
    size,
    zeros_length = zeros_length,
    parameters = parameters,
    behavior = :string,
)

StringRegularArray(
    data::String,   # data provided as a String, rather than AbstractVector{UInt8}
    size::Int;
    zeros_length::Int = 0,
    parameters::Parameters = Parameters(),
    char_parameters::Parameters = Parameters(),
) = StringRegularArray(
    Vector{UInt8}(data),
    size,
    zeros_length = zeros_length,
    parameters = parameters,
    char_parameters = char_parameters,
)

StringRegularArray(
    size::Int;
    parameters::Parameters = Parameters(),
    char_parameters::Parameters = Parameters(),
) = StringRegularArray(
    Vector{UInt8}([]),
    size,
    zeros_length = 0,
    parameters = parameters,
    char_parameters = char_parameters,
)

StringRegularArray(;
    parameters::Parameters = Parameters(),
    char_parameters::Parameters = Parameters(),
) = StringRegularArray(
    Vector{UInt8}([]),
    -1,
    zeros_length = 0,
    parameters = parameters,
    char_parameters = char_parameters,
)

function Base.getindex(
    layout::ListOffsetArray{INDEX,PrimitiveArray{UInt8,BUFFER,:char},:string},
    i::Int,
) where {INDEX<:IndexBig,BUFFER<:AbstractVector{UInt8}}
    start = layout.offsets[i] + firstindex(layout.content)
    stop = layout.offsets[i+1] + firstindex(layout.content) - 1
    String(layout.content[start:stop].data)
end

function Base.getindex(
    layout::ListArray{INDEX,PrimitiveArray{UInt8,BUFFER,:char},:string},
    i::Int,
) where {INDEX<:IndexBig,BUFFER<:AbstractVector{UInt8}}
    adjustment = firstindex(layout.starts) - firstindex(layout.stops)
    start = layout.starts[i] + firstindex(layout.content)
    stop = layout.stops[i-adjustment] - layout.starts[i] + start - 1
    String(layout.content[start:stop].data)
end

function Base.getindex(
    layout::RegularArray{PrimitiveArray{UInt8,BUFFER,:char},:string},
    i::Int,
) where {BUFFER<:AbstractVector{UInt8}}
    size = max(0, layout.size)
    start = (i - firstindex(layout)) * size + firstindex(layout.content)
    stop = (i + 1 - firstindex(layout)) * size + firstindex(layout.content) - 1
    String(layout.content[start:stop].data)
end

function Base.push!(layout::ListType{BEHAVIOR}, input::String) where {BEHAVIOR}
    if BEHAVIOR == :string
        append!(layout.content.data, Vector{UInt8}(input))
        end_list!(layout)
    else
        error("attempting to fill a non-string $(typeof(layout)) with a string")
    end
end

function Base.push!(layout::ListType, input::AbstractVector)
    append!(layout.content, input)
    end_list!(layout)
end

### ListType with behavior = :bytestring #################################

ByteStringOffsetArray(
    offsets::INDEX,
    data::AbstractVector{UInt8};
    parameters::Parameters = Parameters(),
    byte_parameters::Parameters = Parameters(),
) where {INDEX<:IndexBig} = ListOffsetArray(
    offsets,
    PrimitiveArray(data, parameters = byte_parameters, behavior = :byte),
    parameters = parameters,
    behavior = :bytestring,
)

ByteStringOffsetArray(;
    parameters::Parameters = Parameters(),
    byte_parameters::Parameters = Parameters(),
) = ByteStringOffsetArray(
    Index64([0]),
    Vector{UInt8}([]),
    parameters = parameters,
    byte_parameters = byte_parameters,
)

ByteStringArray(
    starts::INDEX,
    stops::INDEX,
    data::AbstractVector{UInt8};
    parameters::Parameters = Parameters(),
    byte_parameters::Parameters = Parameters(),
) where {INDEX<:IndexBig} = ListArray(
    starts,
    stops,
    PrimitiveArray(data, parameters = byte_parameters, behavior = :byte),
    parameters = parameters,
    behavior = :bytestring,
)

ByteStringArray(;
    parameters::Parameters = Parameters(),
    byte_parameters::Parameters = Parameters(),
) = ByteStringArray(
    Index64([]),
    Index64([]),
    Vector{UInt8}([]),
    parameters = parameters,
    byte_parameters = byte_parameters,
)

ByteStringRegularArray(
    data::AbstractVector{UInt8},
    size::Int;
    zeros_length::Int = 0,
    parameters::Parameters = Parameters(),
    byte_parameters::Parameters = Parameters(),
) = RegularArray(
    PrimitiveArray(data, parameters = byte_parameters, behavior = :byte),
    size,
    zeros_length = zeros_length,
    parameters = parameters,
    behavior = :bytestring,
)

ByteStringRegularArray(
    size::Int;
    parameters::Parameters = Parameters(),
    byte_parameters::Parameters = Parameters(),
) = ByteStringRegularArray(
    Vector{UInt8}([]),
    size,
    zeros_length = 0,
    parameters = parameters,
    byte_parameters = byte_parameters,
)

ByteStringRegularArray(;
    parameters::Parameters = Parameters(),
    byte_parameters::Parameters = Parameters(),
) = ByteStringRegularArray(
    Vector{UInt8}([]),
    -1,
    zeros_length = 0,
    parameters = parameters,
    byte_parameters = byte_parameters,
)

function Base.getindex(
    layout::ListOffsetArray{INDEX,PrimitiveArray{UInt8,BUFFER,:byte},:bytestring},
    i::Int,
) where {INDEX<:IndexBig,BUFFER<:AbstractVector{UInt8}}
    getindex(
        copy(
            layout,
            content = copy(layout.content, behavior = :default),
            behavior = :default,
        ),
        i,
    ).data
end

function Base.getindex(
    layout::ListArray{INDEX,PrimitiveArray{UInt8,BUFFER,:byte},:bytestring},
    i::Int,
) where {INDEX<:IndexBig,BUFFER<:AbstractVector{UInt8}}
    getindex(
        copy(
            layout,
            content = copy(layout.content, behavior = :default),
            behavior = :default,
        ),
        i,
    ).data
end

function Base.getindex(
    layout::RegularArray{PrimitiveArray{UInt8,BUFFER,:byte},:bytestring},
    i::Int,
) where {BUFFER<:AbstractVector{UInt8}}
    getindex(
        copy(
            layout,
            content = copy(layout.content, behavior = :default),
            behavior = :default,
        ),
        i,
    ).data
end

### RecordArray ##########################################################

mutable struct RecordArray{CONTENTS<:NamedTuple,BEHAVIOR} <: Content{BEHAVIOR}
    const contents::CONTENTS
    length::Int64
    const parameters::Parameters
    RecordArray(
        contents::CONTENTS,
        length::Int64;
        parameters::Parameters = Parameters(),
        behavior::Symbol = :default,
    ) where {CONTENTS<:NamedTuple} = new{CONTENTS,behavior}(contents, length, parameters)
end

RecordArray(
    contents::CONTENTS;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {CONTENTS<:NamedTuple} = RecordArray(
    contents,
    minimum(if length(contents) == 0
        0
    else
        [length(x) for x in contents]
    end),
    parameters = parameters,
    behavior = behavior,
)

RecordArray{CONTENTS}(;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {CONTENTS<:NamedTuple} = RecordArray(
    NamedTuple{CONTENTS.parameters[1]}(
        Base.Tuple(x() for x in CONTENTS.parameters[2].parameters),
    ),
    parameters = parameters,
    behavior = behavior,
)

struct Record{ARRAY<:RecordArray}
    array::ARRAY
    at::Int64
end

function copy(
    layout::RecordArray{CONTENTS1,BEHAVIOR};
    contents::Union{Unset,CONTENTS2} = Unset(),
    length::Union{Unset,Int64} = Unset(),
    parameters::Union{Unset,Parameters} = Unset(),
    behavior::Union{Unset,Symbol} = Unset(),
) where {CONTENTS1<:NamedTuple,CONTENTS2<:NamedTuple,BEHAVIOR}
    if isa(contents, Unset)
        contents = layout.contents
    end
    if isa(length, Unset)
        length = layout.length
    end
    if isa(parameters, Unset)
        parameters = parameters_of(layout)
    end
    if isa(behavior, Unset)
        behavior = BEHAVIOR
    end
    RecordArray(contents, length, parameters = parameters, behavior = behavior)
end

function is_valid(layout::RecordArray)
    for x in values(layout.contents)
        if length(x) < layout.length
            return false
        end
        if !is_valid(x)
            return false
        end
    end
    return true
end

Base.length(layout::RecordArray) = layout.length
Base.firstindex(layout::RecordArray) = 1
Base.lastindex(layout::RecordArray) = layout.length

Base.getindex(layout::RecordArray, i::Int) = Record(layout, i)

Base.getindex(
    layout::RecordArray{CONTENTS,BEHAVIOR},
    r::UnitRange{Int},
) where {KEYS,VALUES,CONTENTS<:NamedTuple{KEYS,VALUES},BEHAVIOR} = copy(
    layout,
    contents = NamedTuple{KEYS,VALUES}(Base.Tuple(x[r] for x in layout.contents)),
    length = min(r.stop, layout.length) - max(r.start, 1) + 1,   # unnecessary min/max
)

function Base.getindex(layout::RecordArray, f::Symbol)
    content = layout.contents[f]
    content[firstindex(content):firstindex(content)+length(layout)-1]
end

slot(layout::RecordArray, f::Symbol) = layout[f]   # synonym; necessary for TupleArray

Base.getindex(layout::Record, f::Symbol) = layout.array.contents[f][layout.at]

function Base.:(==)(
    layout1::RecordArray{CONTENTS1},
    layout2::RecordArray{CONTENTS2},
) where {CONTENTS1<:NamedTuple,CONTENTS2<:NamedTuple}
    if length(layout1) != length(layout2)
        return false
    end
    if keys(layout1) != keys(layout2)
        return false
    end
    for k in keys(layout1.contents)
        if layout1[k] != layout2[k]   # compare whole arrays
            return false
        end
    end
    return true
end

function Base.:(==)(
    layout1::Record{ARRAY1},
    layout2::Record{ARRAY2},
) where {
    CONTENTS1<:NamedTuple,
    CONTENTS2<:NamedTuple,
    ARRAY1<:RecordArray{CONTENTS1},
    ARRAY2<:RecordArray{CONTENTS2},
}
    if keys(layout1.array.contents) != keys(layout2.array.contents)
        return false
    end
    for k in keys(layout1.array.contents)
        if layout1[k] != layout2[k]   # compare record items
            return false
        end
    end
    return true
end

function Base.push!(layout::RecordArray, input::NamedTuple)
    if typeof(layout.contents).parameters[1] == typeof(input).parameters[1]
        for field in eachindex(layout.contents)
            push!(layout.contents[field], input[field])
        end
        end_record!(layout)
    else
        error(
            "cannot fill RecordArray of fields $(typeof(layout.contents).parameters[1]) with a NamedTuple of keys $(INPUT.parameters[1])",
        )
    end
end

function end_record!(layout::RecordArray)
    layout.length += 1
    @assert all(length(x) >= layout.length for x in layout.contents)
    layout
end

function push_dummy!(layout::RecordArray)
    for x in layout.contents
        push_dummy!(x)
    end
    end_record!(layout)
end

### TupleArray ###########################################################

mutable struct TupleArray{CONTENTS<:Base.Tuple,BEHAVIOR} <: Content{BEHAVIOR}
    const contents::CONTENTS
    length::Int64
    const parameters::Parameters
    TupleArray(
        contents::CONTENTS,
        length::Int64;
        parameters::Parameters = Parameters(),
        behavior::Symbol = :default,
    ) where {CONTENTS<:Base.Tuple} = new{CONTENTS,behavior}(contents, length, parameters)
end

TupleArray(
    contents::CONTENTS;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {CONTENTS<:Base.Tuple} = TupleArray(
    contents,
    minimum(if length(contents) == 0
        0
    else
        [length(x) for x in contents]
    end),
    parameters = parameters,
    behavior = behavior,
)

TupleArray{CONTENTS}(;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {CONTENTS<:Base.Tuple} = TupleArray(
    Base.Tuple(x() for x in CONTENTS.parameters),
    parameters = parameters,
    behavior = behavior,
)

struct Tuple{ARRAY<:TupleArray}
    array::ARRAY
    at::Int64
end

function copy(
    layout::TupleArray{CONTENTS1,BEHAVIOR};
    contents::Union{Unset,CONTENTS2} = Unset(),
    length::Union{Unset,Int64} = Unset(),
    parameters::Union{Unset,Parameters} = Unset(),
    behavior::Union{Unset,Symbol} = Unset(),
) where {CONTENTS1<:Base.Tuple,CONTENTS2<:Base.Tuple,BEHAVIOR}
    if isa(contents, Unset)
        contents = layout.contents
    end
    if isa(length, Unset)
        length = layout.length
    end
    if isa(parameters, Unset)
        parameters = parameters_of(layout)
    end
    if isa(behavior, Unset)
        behavior = BEHAVIOR
    end
    TupleArray(contents, length, parameters = parameters, behavior = behavior)
end

function is_valid(layout::TupleArray)
    for x in layout.contents
        if length(x) < layout.length
            return false
        end
        if !is_valid(x)
            return false
        end
    end
    return true
end

Base.length(layout::TupleArray) = layout.length
Base.firstindex(layout::TupleArray) = 1
Base.lastindex(layout::TupleArray) = layout.length

Base.getindex(layout::TupleArray, i::Int) = Tuple(layout, i)

Base.getindex(
    layout::TupleArray{CONTENTS,BEHAVIOR},
    r::UnitRange{Int},
) where {VALUES,CONTENTS<:Base.Tuple{VALUES},BEHAVIOR} = copy(
    layout,
    contents = Base.Tuple{VALUES}(x[r] for x in layout.contents),
    length = min(r.stop, layout.length) - max(r.start, 1) + 1,   # unnecessary min/max
)

function slot(layout::TupleArray, f::Int)
    content = layout.contents[f]
    content[firstindex(content):firstindex(content)+length(layout)-1]
end

Base.getindex(layout::Tuple, f::Int64) = layout.array.contents[f][layout.at]

function Base.:(==)(
    layout1::TupleArray{CONTENTS1},
    layout2::TupleArray{CONTENTS2},
) where {CONTENTS1<:Base.Tuple,CONTENTS2<:Base.Tuple}
    if length(layout1) != length(layout2)
        return false
    end
    if length(layout1.contents) != length(layout2.contents)
        return false
    end
    for i in eachindex(layout1.contents)         # same indexes because same CONTENTS type
        if slot(layout1, i) != slot(layout2, i)  # compare whole arrays
            return false
        end
    end
    return true
end

function Base.:(==)(
    layout1::Tuple{ARRAY1},
    layout2::Tuple{ARRAY2},
) where {
    CONTENTS1<:Base.Tuple,
    CONTENTS2<:Base.Tuple,
    ARRAY1<:TupleArray{CONTENTS1},
    ARRAY2<:TupleArray{CONTENTS2},
}
    if length(layout1.array.contents) != length(layout2.array.contents)
        return false
    end
    for i in eachindex(layout1.array.contents)   # same indexes because same CONTENTS type
        if layout1[i] != layout2[i]              # compare tuple items
            return false
        end
    end
    return true
end

function Base.push!(layout::TupleArray, input::Base.Tuple)
    if length(typeof(layout.contents).parameters) == length(typeof(input).parameters)
        adjustment = firstindex(layout.contents) - firstindex(input)
        for index in eachindex(layout.contents)
            push!(layout.contents[index], input[index-adjustment])
        end
        end_tuple!(layout)
    else
        error(
            "cannot fill TupleArray of $(length(typeof(layout.contents).parameters)) slots with a Tuple of $(length(typeof(input).parameters)) slots",
        )
    end
end

function end_tuple!(layout::TupleArray)
    layout.length += 1
    @assert all(length(x) >= layout.length for x in layout.contents)
    layout
end

function push_dummy!(layout::TupleArray)
    for x in layout.contents
        push_dummy!(x)
    end
    end_tuple!(layout)
end

### IndexedArray #########################################################

struct IndexedArray{INDEX<:IndexBig,CONTENT<:Content,BEHAVIOR} <: Content{BEHAVIOR}
    index::INDEX
    content::CONTENT
    parameters::Parameters
    IndexedArray(
        index::INDEX,
        content::CONTENT;
        parameters::Parameters = Parameters(),
        behavior::Symbol = :default,
    ) where {INDEX<:IndexBig,CONTENT<:Content} =
        new{INDEX,CONTENT,behavior}(index, content, parameters)
end

IndexedArray{INDEX,CONTENT}(;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {INDEX<:IndexBig} where {CONTENT<:Content} =
    IndexedArray(INDEX([]), CONTENT(), parameters = parameters, behavior = behavior)

function copy(
    layout::IndexedArray{INDEX1,CONTENT1,BEHAVIOR};
    index::Union{Unset,INDEX2} = Unset(),
    content::Union{Unset,CONTENT2} = Unset(),
    parameters::Union{Unset,Parameters} = Unset(),
    behavior::Union{Unset,Symbol} = Unset(),
) where {INDEX1<:IndexBig,INDEX2<:IndexBig,CONTENT1<:Content,CONTENT2<:Content,BEHAVIOR}
    if isa(index, Unset)
        index = layout.index
    end
    if isa(content, Unset)
        content = layout.content
    end
    if isa(parameters, Unset)
        parameters = parameters_of(layout)
    end
    if isa(behavior, Unset)
        behavior = BEHAVIOR
    end
    IndexedArray(index, content, parameters = parameters, behavior = behavior)
end

function is_valid(layout::IndexedArray)
    for i in eachindex(layout.index)
        if layout.index[i] < 0 || layout.index[i] >= length(layout.content)
            return false
        end
    end
    return is_valid(layout.content)
end

Base.length(layout::IndexedArray) = length(layout.index)
Base.firstindex(layout::IndexedArray) = firstindex(layout.index)
Base.lastindex(layout::IndexedArray) = lastindex(layout.index)

Base.getindex(layout::IndexedArray, i::Int) =
    layout.content[layout.index[i]+firstindex(layout.content)]

Base.getindex(layout::IndexedArray, r::UnitRange{Int}) =
    copy(layout, index = layout.index[r.start:r.stop])

Base.getindex(layout::IndexedArray, f::Symbol) = copy(layout, content = layout.content[f])

function Base.push!(layout::IndexedArray, input)
    tmp = length(layout.content)
    push!(layout.content, input)
    push!(layout.index, tmp)
    layout
end

function end_list!(layout::IndexedArray)
    tmp = length(layout.content)
    end_list!(layout.content)
    push!(layout.index, tmp)
    layout
end

function end_record!(layout::IndexedArray)
    tmp = length(layout.content)
    end_record!(layout.content)
    push!(layout.index, tmp)
    layout
end

function end_tuple!(layout::IndexedArray)
    tmp = length(layout.content)
    end_tuple!(layout.content)
    push!(layout.index, tmp)
    layout
end

function push_dummy!(layout::IndexedArray)
    tmp = length(layout.content)
    push_dummy!(layout.content)
    push!(layout.index, tmp)
    layout
end

### IndexedOptionArray ###################################################

abstract type OptionType{BEHAVIOR} <: Content{BEHAVIOR} end

function Base.append!(layout::OptionType, input)
    for item in input
        if ismissing(item)
            push_null!(layout)
        else
            push!(layout, item)
        end
    end
    layout
end

struct IndexedOptionArray{INDEX<:IndexBig,CONTENT<:Content,BEHAVIOR} <: OptionType{BEHAVIOR}
    index::INDEX
    content::CONTENT
    parameters::Parameters
    IndexedOptionArray(
        index::INDEX,
        content::CONTENT;
        parameters::Parameters = Parameters(),
        behavior::Symbol = :default,
    ) where {INDEX<:IndexBig,CONTENT<:Content} =
        new{INDEX,CONTENT,behavior}(index, content, parameters)
end

IndexedOptionArray{INDEX,CONTENT}(;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {INDEX<:IndexBig} where {CONTENT<:Content} =
    IndexedOptionArray(INDEX([]), CONTENT(), parameters = parameters, behavior = behavior)

function copy(
    layout::IndexedOptionArray{INDEX1,CONTENT1,BEHAVIOR};
    index::Union{Unset,INDEX2} = Unset(),
    content::Union{Unset,CONTENT2} = Unset(),
    parameters::Union{Unset,Parameters} = Unset(),
    behavior::Union{Unset,Symbol} = Unset(),
) where {INDEX1<:IndexBig,INDEX2<:IndexBig,CONTENT1<:Content,CONTENT2<:Content,BEHAVIOR}
    if isa(index, Unset)
        index = layout.index
    end
    if isa(content, Unset)
        content = layout.content
    end
    if isa(parameters, Unset)
        parameters = parameters_of(layout)
    end
    if isa(behavior, Unset)
        behavior = BEHAVIOR
    end
    IndexedOptionArray(index, content, parameters = parameters, behavior = behavior)
end

function is_valid(layout::IndexedOptionArray)
    for i in eachindex(layout.index)
        if layout.index[i] >= length(layout.content)
            return false
        end
    end
    return is_valid(layout.content)
end

Base.length(layout::IndexedOptionArray) = length(layout.index)
Base.firstindex(layout::IndexedOptionArray) = firstindex(layout.index)
Base.lastindex(layout::IndexedOptionArray) = lastindex(layout.index)

function Base.getindex(layout::IndexedOptionArray, i::Int)
    if layout.index[i] < 0
        missing
    else
        layout.content[layout.index[i]+firstindex(layout.content)]
    end
end

Base.getindex(layout::IndexedOptionArray, r::UnitRange{Int}) =
    copy(layout, index = layout.index[r.start:r.stop])

Base.getindex(layout::IndexedOptionArray, f::Symbol) =
    copy(layout, content = layout.content[f])

function Base.push!(layout::IndexedOptionArray, input)
    if ismissing(input)
        push_null!(layout)
    else
        tmp = length(layout.content)
        push!(layout.content, input)
        push!(layout.index, tmp)
        layout
    end
end

function end_list!(layout::IndexedOptionArray)
    tmp = length(layout.content)
    end_list!(layout.content)
    push!(layout.index, tmp)
    layout
end

function end_record!(layout::IndexedOptionArray)
    tmp = length(layout.content)
    end_record!(layout.content)
    push!(layout.index, tmp)
    layout
end

function end_tuple!(layout::IndexedOptionArray)
    tmp = length(layout.content)
    end_tuple!(layout.content)
    push!(layout.index, tmp)
    layout
end

function push_null!(layout::IndexedOptionArray)
    push!(layout.index, -1)
    layout
end

function push_dummy!(layout::IndexedOptionArray)
    push_null!(layout)
end

### ByteMaskedArray ######################################################

struct ByteMaskedArray{INDEX<:IndexBool,CONTENT<:Content,BEHAVIOR} <: OptionType{BEHAVIOR}
    mask::INDEX
    content::CONTENT
    valid_when::Bool
    parameters::Parameters
    ByteMaskedArray(
        mask::INDEX,
        content::CONTENT;
        valid_when::Bool = false,  # the NumPy MaskedArray convention
        parameters::Parameters = Parameters(),
        behavior::Symbol = :default,
    ) where {INDEX<:IndexBool,CONTENT<:Content} =
        new{INDEX,CONTENT,behavior}(mask, content, valid_when, parameters)
end

ByteMaskedArray{INDEX,CONTENT}(;
    valid_when::Bool = false,  # the NumPy MaskedArray convention
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {INDEX<:IndexBool} where {CONTENT<:Content} = ByteMaskedArray(
    INDEX([]),
    CONTENT(),
    valid_when = valid_when,
    parameters = parameters,
    behavior = behavior,
)

function copy(
    layout::ByteMaskedArray{INDEX1,CONTENT1,BEHAVIOR};
    mask::Union{Unset,INDEX2} = Unset(),
    content::Union{Unset,CONTENT2} = Unset(),
    valid_when::Union{Unset,Bool} = Unset(),
    parameters::Union{Unset,Parameters} = Unset(),
    behavior::Union{Unset,Symbol} = Unset(),
) where {INDEX1<:IndexBool,INDEX2<:IndexBool,CONTENT1<:Content,CONTENT2<:Content,BEHAVIOR}
    if isa(mask, Unset)
        mask = layout.mask
    end
    if isa(content, Unset)
        content = layout.content
    end
    if isa(valid_when, Unset)
        valid_when = layout.valid_when
    end
    if isa(parameters, Unset)
        parameters = parameters_of(layout)
    end
    if isa(behavior, Unset)
        behavior = BEHAVIOR
    end
    ByteMaskedArray(
        mask,
        content,
        valid_when = valid_when,
        parameters = parameters,
        behavior = behavior,
    )
end

function is_valid(layout::ByteMaskedArray)
    if length(layout.mask) > length(layout.content)
        return false
    end
    return is_valid(layout.content)
end

Base.length(layout::ByteMaskedArray) = length(layout.mask)
Base.firstindex(layout::ByteMaskedArray) = firstindex(layout.mask)
Base.lastindex(layout::ByteMaskedArray) = lastindex(layout.mask)

function Base.getindex(layout::ByteMaskedArray, i::Int)
    if (layout.mask[i] != 0) != layout.valid_when
        missing
    else
        adjustment = firstindex(layout.mask) - firstindex(layout.content)
        layout.content[i-adjustment]
    end
end

function Base.getindex(layout::ByteMaskedArray, r::UnitRange{Int})
    adjustment = firstindex(layout.mask) - firstindex(layout.content)
    copy(
        layout,
        mask = layout.mask[r.start:r.stop],
        content = layout.content[(r.start-adjustment):(r.stop-adjustment)],
    )
end

Base.getindex(layout::ByteMaskedArray, f::Symbol) =
    copy(layout, content = layout.content[f])

function Base.push!(layout::ByteMaskedArray, input)
    if ismissing(input)
        push_null!(layout)
    else
        push!(layout.content, input)
        push!(layout.mask, layout.valid_when)
        layout
    end
end

function end_list!(layout::ByteMaskedArray)
    end_list!(layout.content)
    push!(layout.mask, layout.valid_when)
    layout
end

function end_record!(layout::ByteMaskedArray)
    end_record!(layout.content)
    push!(layout.mask, layout.valid_when)
    layout
end

function end_tuple!(layout::ByteMaskedArray)
    end_tuple!(layout.content)
    push!(layout.mask, layout.valid_when)
    layout
end

function push_null!(layout::ByteMaskedArray)
    push_dummy!(layout.content)
    push!(layout.mask, !layout.valid_when)
    layout
end

function push_dummy!(layout::ByteMaskedArray)
    push_null!(layout)
end

### BitMaskedArray #######################################################
#
# Note: all Python BitMaskedArrays must be converted to lsb_order = true.

struct BitMaskedArray{CONTENT<:Content,BEHAVIOR} <: OptionType{BEHAVIOR}
    mask::BitVector
    content::CONTENT
    valid_when::Bool
    parameters::Parameters
    BitMaskedArray(
        mask::BitVector,
        content::CONTENT;
        valid_when::Bool = false,  # NumPy MaskedArray's convention; note that Arrow's is true
        parameters::Parameters = Parameters(),
        behavior::Symbol = :default,
    ) where {CONTENT<:Content} =
        new{CONTENT,behavior}(mask, content, valid_when, parameters)
end

BitMaskedArray{CONTENT}(;
    valid_when::Bool = false,  # NumPy MaskedArray's convention; note that Arrow's is true
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {CONTENT<:Content} = BitMaskedArray(
    BitVector(),
    CONTENT(),
    valid_when = valid_when,
    parameters = parameters,
    behavior = behavior,
)

function copy(
    layout::BitMaskedArray{CONTENT1,BEHAVIOR};
    mask::Union{Unset,BitVector} = Unset(),
    content::Union{Unset,CONTENT2} = Unset(),
    valid_when::Union{Unset,Bool} = Unset(),
    parameters::Union{Unset,Parameters} = Unset(),
    behavior::Union{Unset,Symbol} = Unset(),
) where {CONTENT1<:Content,CONTENT2<:Content,BEHAVIOR}
    if isa(mask, Unset)
        mask = layout.mask
    end
    if isa(content, Unset)
        content = layout.content
    end
    if isa(valid_when, Unset)
        valid_when = layout.valid_when
    end
    if isa(parameters, Unset)
        parameters = parameters_of(layout)
    end
    if isa(behavior, Unset)
        behavior = BEHAVIOR
    end
    BitMaskedArray(
        mask,
        content,
        valid_when = valid_when,
        parameters = parameters,
        behavior = behavior,
    )
end

function is_valid(layout::BitMaskedArray)
    if length(layout.mask) > length(layout.content)
        return false
    end
    return is_valid(layout.content)
end

Base.length(layout::BitMaskedArray) = length(layout.mask)
Base.firstindex(layout::BitMaskedArray) = firstindex(layout.mask)
Base.lastindex(layout::BitMaskedArray) = lastindex(layout.mask)

function Base.getindex(layout::BitMaskedArray, i::Int)
    if (layout.mask[i] != 0) != layout.valid_when
        missing
    else
        adjustment = firstindex(layout.mask) - firstindex(layout.content)
        layout.content[i-adjustment]
    end
end

function Base.getindex(layout::BitMaskedArray, r::UnitRange{Int})
    adjustment = firstindex(layout.mask) - firstindex(layout.content)
    copy(
        layout,
        mask = layout.mask[r.start:r.stop],
        content = layout.content[(r.start-adjustment):(r.stop-adjustment)],
    )
end

Base.getindex(layout::BitMaskedArray, f::Symbol) = copy(layout, content = layout.content[f])

function Base.push!(layout::BitMaskedArray, input)
    if ismissing(input)
        push_null!(layout)
    else
        push!(layout.content, input)
        push!(layout.mask, layout.valid_when)
        layout
    end
end

function end_list!(layout::BitMaskedArray)
    end_list!(layout.content)
    push!(layout.mask, layout.valid_when)
    layout
end

function end_record!(layout::BitMaskedArray)
    end_record!(layout.content)
    push!(layout.mask, layout.valid_when)
    layout
end

function end_tuple!(layout::BitMaskedArray)
    end_tuple!(layout.content)
    push!(layout.mask, layout.valid_when)
    layout
end

function push_null!(layout::BitMaskedArray)
    push_dummy!(layout.content)
    push!(layout.mask, !layout.valid_when)
    layout
end

function push_dummy!(layout::BitMaskedArray)
    push_null!(layout)
end

### UnmaskedArray ########################################################

struct UnmaskedArray{CONTENT<:Content,BEHAVIOR} <: OptionType{BEHAVIOR}
    content::CONTENT
    parameters::Parameters
    UnmaskedArray(
        content::CONTENT;
        parameters::Parameters = Parameters(),
        behavior::Symbol = :default,
    ) where {CONTENT<:Content} = new{CONTENT,behavior}(content, parameters)
end

UnmaskedArray{CONTENT}(;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {CONTENT<:Content} =
    UnmaskedArray(CONTENT(), parameters = parameters, behavior = behavior)

function copy(
    layout::UnmaskedArray{CONTENT1,BEHAVIOR};
    content::Union{Unset,CONTENT2} = Unset(),
    parameters::Union{Unset,Parameters} = Unset(),
    behavior::Union{Unset,Symbol} = Unset(),
) where {CONTENT1<:Content,CONTENT2<:Content,BEHAVIOR}
    if isa(content, Unset)
        content = layout.content
    end
    if isa(parameters, Unset)
        parameters = parameters_of(layout)
    end
    if isa(behavior, Unset)
        behavior = BEHAVIOR
    end
    UnmaskedArray(content, parameters = parameters, behavior = behavior)
end

is_valid(layout::UnmaskedArray) = is_valid(layout.content)

Base.length(layout::UnmaskedArray) = length(layout.content)
Base.firstindex(layout::UnmaskedArray) = firstindex(layout.content)
Base.lastindex(layout::UnmaskedArray) = lastindex(layout.content)

# It would have been nice to get this to say that the return type is
# Union{Missing, return_types(getindex, (typeof(layout.content), typeof(i)))[1]}
# but Julia is smart enough to see through "if false missing else ...".
Base.getindex(layout::UnmaskedArray, i::Int) = layout.content[i]

Base.getindex(layout::UnmaskedArray, r::UnitRange{Int}) =
    copy(layout, content = layout.content[r.start:r.stop])

Base.getindex(layout::UnmaskedArray, f::Symbol) = copy(layout, content = layout.content[f])

function Base.push!(layout::UnmaskedArray, input)
    push!(layout.content, input)
    layout
end

function end_list!(layout::UnmaskedArray)
    end_list!(layout.content)
    layout
end

function end_record!(layout::UnmaskedArray)
    end_record!(layout.content)
    layout
end

function end_tuple!(layout::UnmaskedArray)
    end_tuple!(layout.content)
    layout
end

function push_dummy!(layout::UnmaskedArray)
    push_dummy!(layout.content)
end

### UnionArray ###########################################################

struct UnionArray{TAGS<:Index8,INDEX<:IndexBig,CONTENTS<:Base.Tuple,BEHAVIOR} <:
       Content{BEHAVIOR}
    tags::TAGS
    index::INDEX
    contents::CONTENTS
    parameters::Parameters
    UnionArray(
        tags::TAGS,
        index::INDEX,
        contents::CONTENTS;
        parameters::Parameters = Parameters(),
        behavior::Symbol = :default,
    ) where {TAGS<:Index8,INDEX<:IndexBig,CONTENTS<:Base.Tuple} =
        new{TAGS,INDEX,CONTENTS,behavior}(tags, index, contents, parameters)
end

UnionArray{TAGS,INDEX,CONTENTS}(
    contents::CONTENTS;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {TAGS<:Index8,INDEX<:IndexBig,CONTENTS<:Base.Tuple} =
    UnionArray(TAGS([]), INDEX([]), contents, parameters = parameters, behavior = behavior)

UnionArray{TAGS,INDEX,CONTENTS}(;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {TAGS<:Index8,INDEX<:IndexBig,CONTENTS<:Base.Tuple} = UnionArray(
    TAGS([]),
    INDEX([]),
    Base.Tuple(x() for x in CONTENTS.parameters),
    parameters = parameters,
    behavior = behavior,
)

struct Specialization{ARRAY<:UnionArray,TAGGED<:Content}
    tag::Int8
    array::ARRAY
    tagged::TAGGED
end

Specialization(layout::UnionArray, tag::Int) =
    Specialization(Int8(tag), layout, layout.contents[tag])

function copy(
    layout::UnionArray{TAGS1,INDEX1,CONTENTS1,BEHAVIOR};
    tags::Union{Unset,TAGS2} = Unset(),
    index::Union{Unset,INDEX2} = Unset(),
    contents::Union{Unset,CONTENTS2} = Unset(),
    parameters::Union{Unset,Parameters} = Unset(),
    behavior::Union{Unset,Symbol} = Unset(),
) where {
    TAGS1<:Index8,
    TAGS2<:Index8,
    INDEX1<:IndexBig,
    INDEX2<:IndexBig,
    CONTENTS1<:Base.Tuple,
    CONTENTS2<:Base.Tuple,
    BEHAVIOR,
}
    if isa(tags, Unset)
        tags = layout.tags
    end
    if isa(index, Unset)
        index = layout.index
    end
    if isa(contents, Unset)
        contents = layout.contents
    end
    if isa(parameters, Unset)
        parameters = layout.parameters
    end
    if isa(behavior, Unset)
        behavior = BEHAVIOR
    end
    UnionArray(tags, index, contents, parameters = parameters, behavior = behavior)
end

function is_valid(layout::UnionArray)
    if length(layout.tags) > length(layout.index)
        return false
    end
    adjustment = firstindex(layout.tags) - firstindex(layout.index)
    for i in eachindex(layout.tags)
        tag = layout.tags[i]
        index = layout.index[i-adjustment]
        if tag < 0 || tag >= length(layout.contents)
            return false
        end
        content = layout.contents[tag+firstindex(layout.contents)]
        if index < 0 || index >= length(content)
            return false
        end
    end
    for x in layout.contents
        if !is_valid(x)
            return false
        end
    end
    return true
end

Base.length(layout::UnionArray) = length(layout.tags)
Base.firstindex(layout::UnionArray) = firstindex(layout.tags)
Base.lastindex(layout::UnionArray) = lastindex(layout.tags)

function Base.getindex(layout::UnionArray, i::Int)
    adjustment = firstindex(layout.tags) - firstindex(layout.index)
    tag = layout.tags[i]
    index = layout.index[i-adjustment]
    content = layout.contents[tag+firstindex(layout.contents)]
    content[index+firstindex(content)]
end

function Base.getindex(layout::UnionArray, r::UnitRange{Int})
    adjustment = firstindex(layout.tags) - firstindex(layout.index)
    copy(
        layout,
        tags = layout.tags[r.start:r.stop],
        index = layout.index[(r.start-adjustment):(r.stop-adjustment)],
    )
end

Base.getindex(layout::UnionArray, f::Symbol) =
    copy(layout, contents = Base.Tuple(x[f] for x in layout.contents))

function Base.push!(special::Specialization, input)
    tmp = length(special.tagged)
    push!(special.tagged, input)
    push!(special.array.tags, special.tag - firstindex(special.array.contents))
    push!(special.array.index, tmp)
    special
end

function Base.append!(special::Specialization, input)
    for item in input
        push!(special, item)
    end
    special
end

function end_list!(special::Specialization)
    tmp = length(special.tagged)
    end_list!(special.tagged)
    push!(special.array.tags, special.tag - firstindex(special.array.contents))
    push!(special.array.index, tmp)
    special
end

function end_record!(special::Specialization)
    tmp = length(special.tagged)
    end_record!(special.tagged)
    push!(special.array.tags, special.tag - firstindex(special.array.contents))
    push!(special.array.index, tmp)
    special
end

function end_tuple!(special::Specialization)
    tmp = length(special.tagged)
    end_tuple!(special.tagged)
    push!(special.array.tags, special.tag - firstindex(special.array.contents))
    push!(special.array.index, tmp)
    special
end

function push_null!(
    special::Specialization{ARRAY,TAGGED},
) where {ARRAY<:UnionArray,TAGGED<:OptionType}
    tmp = length(special.tagged)
    push_null!(special.tagged)
    push!(special.array.tags, special.tag - firstindex(special.array.contents))
    push!(special.array.index, tmp)
    special
end

function push_dummy!(special::Specialization)
    tmp = length(special.tagged)
    push_dummy!(special.tagged)
    push!(special.array.tags, special.tag - firstindex(special.array.contents))
    push!(special.array.index, tmp)
    special
end

function Base.push!(layout::UnionArray, input)
    for index in eachindex(layout.contents)
        special = Specialization(layout, index)
        if index == lastindex(layout.contents)
            return push!(special, input)
        else
            try
                return push!(special, input)
            catch
            end
        end
    end
end

### from_iter ############################################################

function layout_for(ItemType)
    if ItemType <: Number   # || ItemType <: Dates.DateTime || ItemType <: Dates.TimePeriod
        PrimitiveArray{ItemType}

    elseif ItemType <: String
        ListOffsetArray{Vector{Int64},PrimitiveArray{UInt8,Vector{UInt8},:char},:string}

    elseif ItemType <: AbstractVector
        ListOffsetArray{Vector{Int64},layout_for(eltype(ItemType))}

    elseif ItemType <: AbstractArray
        out = layout_for(eltype(ItemType))
        for _ = 1:ndims(ItemType)
            out = RegularArray{out}
        end
        out

    elseif ItemType <: NamedTuple
        contents = [layout_for(x) for x in ItemType.parameters[2].parameters]
        RecordArray{NamedTuple{ItemType.parameters[1],Base.Tuple{contents...}}}

    elseif ItemType <: Base.Tuple
        contents = [layout_for(x) for x in ItemType.parameters]
        TupleArray{Base.Tuple{contents...}}

    elseif Missing <: ItemType
        OtherTypes = [x for x in Base.uniontypes(ItemType) if x != Missing]
        if length(OtherTypes) == 0
            IndexedOptionArray{Vector{Int64},EmptyArray}
        else
            if OtherTypes[begin] <: NamedTuple || OtherTypes[begin] <: Base.Tuple
                out = IndexedOptionArray{Vector{Int64},layout_for(OtherTypes[begin])}
            else
                out = ByteMaskedArray{Index8,layout_for(OtherTypes[begin])}
            end

            if length(OtherTypes) == 1
                out
            else
                contents = [out]
                for i = (firstindex(OtherTypes)+1):(lastindex(OtherTypes))
                    push!(contents, UnmaskedArray{layout_for(OtherTypes[i])})
                end
                UnionArray{Index8,Vector{Int64},Base.Tuple{contents...}}
            end
        end

    else
        OtherTypes = Base.uniontypes(ItemType)
        if length(OtherTypes) > 1
            contents = [layout_for(x) for x in OtherTypes]
            UnionArray{Index8,Vector{Int64},Base.Tuple{contents...}}
        else
            error("cannot produce an AwkwardArray layout for $ItemType")
        end
    end
end

function from_iter(input)
    ItemType = eltype(input)
    AwkwardType = layout_for(ItemType)
    out = AwkwardType()
    for item in input
        push!(out, item)
    end
    out
end

end  # module AwkwardArray
