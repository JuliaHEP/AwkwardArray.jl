### Index ################################################################

const Index8 = AbstractVector{Int8}
const IndexU8 = AbstractVector{UInt8}
const Index32 = AbstractVector{Int32}
const IndexU32 = AbstractVector{UInt32}
const Index64 = AbstractVector{Int64}
const IndexBig = Union{Index32,IndexU32,Index64}
const IndexBigSigned = Union{Index32,Index64}
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

abstract type Content{BEHAVIOR} <: AbstractVector{Any} end

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

### Form helper functions ################################################
#
#

function isprimitive(t::Type)
    return t <: Integer || t <: AbstractFloat || t <: Bool || t <: Char
end

function check_primitive_type(ITEM)
    if ITEM == Bool
        primitive = "bool"
    elseif ITEM == Int8
        primitive = "int8"
    elseif ITEM == UInt8
        primitive = "uint8"
    elseif ITEM == Int16
        primitive = "int16"
    elseif ITEM == UInt16
        primitive = "uint16"
    elseif ITEM == Int32
        primitive = "int32"
    elseif ITEM == UInt32
        primitive = "uint32"
    elseif ITEM == Int64
        primitive = "int64"
    elseif ITEM == UInt64
        primitive = "uint64"
    elseif ITEM == Float16
        primitive = "float16"
    elseif ITEM == Float32
        primitive = "float32"
    elseif ITEM == Float64
        primitive = "float64"
    elseif ITEM == Complex{Float32}
        primitive = "complex64"
    elseif ITEM == Complex{Float64}
        primitive = "complex128"
    # elseif ITEM <: Dates.DateTime     # FIXME
    #     primitive = "datetime64"
    # elseif ITEM <: Dates.TimePeriod   # FIXME
    #     primitive = "timedelta64"
    else
        primitive = "unknown"
    end
    return primitive
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

Base.eltype(layout::PrimitiveArray) = eltype(layout.data)
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

function _to_buffers!(
    layout::PrimitiveArray{ITEM,BUFFER},
    number::Vector{Int64},
    containers::Dict{String,AbstractVector{UInt8}},
) where {ITEM,BUFFER<:AbstractVector{ITEM}}
    form_key = "node$(number[begin])"
    number[begin] += 1

    primitive = check_primitive_type(ITEM)
    if primitive == "unknown"
        error(
            "PrimitiveArray has an ITEM type that can't be serialized in the to_buffers protocol: $ITEM",
        )
    end

    containers["$form_key-data"] = reinterpret(UInt8, layout.data)

    Dict{String,Any}(
        "class" => "NumpyArray",
        "primitive" => primitive,
        "inner_shape" => Vector{Int64}(),
        "parameters" => _to_buffers_parameters(layout),
        "form_key" => form_key,
    )
end

### EmptyArray ###########################################################

struct EmptyArray{BEHAVIOR} <: LeafType{BEHAVIOR}
    behavior::Symbol
    
    function EmptyArray(; behavior::Symbol = :default)
        new{behavior}(behavior)
    end
end

function copy(behavior::Union{Unset,Symbol} = Unset())
    behavior = behavior isa Unset ? :default : behavior
    return EmptyArray(behavior = behavior)
end

parameters_of(content::EmptyArray) = Parameters()
has_parameter(content::EmptyArray, key::String) = false
get_parameter(content::EmptyArray, key::String) = nothing

is_valid(layout::EmptyArray) = true
Base.length(layout::EmptyArray) = 0
Base.firstindex(layout::EmptyArray) = 1
Base.lastindex(layout::EmptyArray) = 0

Base.eltype(layout::EmptyArray) = Union{}
Base.getindex(layout::EmptyArray, i::Int) = throw(BoundsError(layout, i))

function Base.getindex(layout::EmptyArray, r::UnitRange{Int})
    if r.start < r.stop
        throw(BoundsError(layout, r))
    else
        layout
    end
end

function Base.push!(layout::EmptyArray, input)
    error("attempting to fill $(typeof(layout)) with data")
end

function _to_buffers!(
    layout::EmptyArray,
    number::Vector{Int64},
    containers::Dict{String,AbstractVector{UInt8}},
)
    number[begin] += 1

    Dict{String,Any}("class" => "EmptyArray")
end

### ListOffsetArray ######################################################

abstract type ListType{BEHAVIOR} <: Content{BEHAVIOR} end
Base.eltype(layout::ListType) = Vector{eltype(layout.content)}

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

# Define the getindex method for ListOffsetArray
function Base.getindex(layout::ListOffsetArray, f::Symbol)
    @assert typeof(layout.content) <: RecordArray "content must be of type RecordArray"
    copy(layout, content = layout.content[f])
end

function end_list!(layout::ListOffsetArray)
    push!(layout.offsets, length(layout.content))
    layout
end

function push_dummy!(layout::ListOffsetArray)
    end_list!(layout)
end

function _to_buffers!(
    layout::ListOffsetArray{INDEX,CONTENT},
    number::Vector{Int64},
    containers::Dict{String,AbstractVector{UInt8}},
) where {INDEX<:IndexBig,CONTENT<:Content}
    form_key = "node$(number[begin])"
    number[begin] += 1

    containers["$form_key-offsets"] = reinterpret(UInt8, layout.offsets)

    Dict{String,Any}(
        "class" => "ListOffsetArray",
        "offsets" => _to_buffers_index(INDEX),
        "content" => _to_buffers!(layout.content, number, containers),
        "parameters" => _to_buffers_parameters(layout),
        "form_key" => form_key,
    )
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
    stop = layout.stops[i-adjustment] + firstindex(layout.content) - 1
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

# Define the getindex method for ListArray
function Base.getindex(layout::ListArray, f::Symbol)
    @assert typeof(layout.content) <: RecordArray "content must be of type RecordArray"
    copy(layout, content = layout.content[f])
end

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

function _to_buffers!(
    layout::ListArray{INDEX,CONTENT},
    number::Vector{Int64},
    containers::Dict{String,AbstractVector{UInt8}},
) where {INDEX<:IndexBig,CONTENT<:Content}
    form_key = "node$(number[begin])"
    number[begin] += 1

    containers["$form_key-starts"] = reinterpret(UInt8, layout.starts)
    containers["$form_key-stops"] = reinterpret(UInt8, layout.stops)

    Dict{String,Any}(
        "class" => "ListArray",
        "starts" => _to_buffers_index(INDEX),
        "stops" => _to_buffers_index(INDEX),
        "content" => _to_buffers!(layout.content, number, containers),
        "parameters" => _to_buffers_parameters(layout),
        "form_key" => form_key,
    )
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
    stop = (r.stop + 1 - firstindex(layout)) * size + firstindex(layout.content) - 1
    copy(layout, content = layout.content[start:stop], zeros_length = r.stop - r.start + 1)
end

function Base.getindex(layout::RegularArray, f::Symbol)
    @assert typeof(layout.content) <: RecordArray "content must be of type RecordArray"
    copy(layout, content = layout.content[f])
end

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

function _to_buffers!(
    layout::RegularArray{CONTENT},
    number::Vector{Int64},
    containers::Dict{String,AbstractVector{UInt8}},
) where {CONTENT<:Content}
    form_key = "node$(number[begin])"
    number[begin] += 1

    Dict{String,Any}(
        "class" => "RegularArray",
        "size" => layout.size,
        "content" => _to_buffers!(layout.content, number, containers),
        "parameters" => _to_buffers_parameters(layout),
    )
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

mutable struct RecordArray{FIELDS,CONTENTS<:Base.Tuple{Vararg{Content}},BEHAVIOR} <:
               Content{BEHAVIOR}
    const contents::NamedTuple{FIELDS,CONTENTS}
    length::Int64
    const parameters::Parameters
    RecordArray(
        contents::NamedTuple{FIELDS,CONTENTS},
        length::Int64;
        parameters::Parameters = Parameters(),
        behavior::Symbol = :default,
    ) where {FIELDS,CONTENTS<:Base.Tuple{Vararg{Content}}} =
        new{FIELDS,CONTENTS,behavior}(contents, length, parameters)
end

RecordArray(
    contents::NamedTuple{FIELDS,CONTENTS};
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {FIELDS,CONTENTS<:Base.Tuple{Vararg{Content}}} = RecordArray(
    contents,
    minimum(if length(contents) == 0
        0
    else
        [length(x) for x in contents]
    end),
    parameters = parameters,
    behavior = behavior,
)

RecordArray{FIELDS,CONTENTS}(;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {FIELDS,CONTENTS<:Base.Tuple{Vararg{Content}}} = RecordArray(
    NamedTuple{FIELDS}(Base.Tuple{Vararg{Content}}(x() for x in CONTENTS.parameters)),
    parameters = parameters,
    behavior = behavior,
)

struct Record{FIELDS,CONTENTS<:Base.Tuple{Vararg{Content}},BEHAVIOR}
    array::RecordArray{FIELDS,CONTENTS,BEHAVIOR}
    at::Int64
end

function copy(
    layout::RecordArray{FIELDS1,CONTENTS1,BEHAVIOR};
    contents::Union{Unset,NamedTuple{FIELDS2,CONTENTS2}} = Unset(),
    length::Union{Unset,Int64} = Unset(),
    parameters::Union{Unset,Parameters} = Unset(),
    behavior::Union{Unset,Symbol} = Unset(),
) where {
    FIELDS1,
    FIELDS2,
    CONTENTS1<:Base.Tuple{Vararg{Content}},
    CONTENTS2<:Base.Tuple{Vararg{Content}},
    BEHAVIOR,
}
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

Base.getindex(
    layout::RecordArray{FIELDS,CONTENTS,BEHAVIOR},
    i::Int,
) where {FIELDS,CONTENTS<:Base.Tuple{Vararg{Content}},BEHAVIOR} = Record(layout, i)

Base.getindex(
    layout::RecordArray{FIELDS,CONTENTS,BEHAVIOR},
    r::UnitRange{Int},
) where {FIELDS,CONTENTS<:Base.Tuple{Vararg{Content}},BEHAVIOR} = copy(
    layout,
    contents = NamedTuple{FIELDS,CONTENTS}(CONTENTS(x[r] for x in layout.contents)),
    length = min(r.stop, layout.length) - max(r.start, 1) + 1,   # unnecessary min/max
)

function Base.getindex(
    layout::RecordArray{FIELDS,CONTENTS,BEHAVIOR},
    f::Symbol,
) where {FIELDS,CONTENTS<:Base.Tuple{Vararg{Content}},BEHAVIOR}
    content = layout.contents[f]
    content[firstindex(content):firstindex(content)+length(layout)-1]
end

# synonym; necessary for TupleArray
slot(
    layout::RecordArray{FIELDS,CONTENTS,BEHAVIOR},
    f::Symbol,
) where {FIELDS,CONTENTS<:Base.Tuple{Vararg{Content}},BEHAVIOR} = layout[f]

Base.getindex(
    layout::Record{FIELDS,CONTENTS},
    f::Symbol,
) where {FIELDS,CONTENTS<:Base.Tuple{Vararg{Content}}} = layout.array.contents[f][layout.at]

function Base.:(==)(
    layout1::RecordArray{FIELDS,CONTENTS1},
    layout2::RecordArray{FIELDS,CONTENTS2},
) where {
    FIELDS,
    CONTENTS1<:Base.Tuple{Vararg{Content}},
    CONTENTS2<:Base.Tuple{Vararg{Content}},
}
    if length(layout1) != length(layout2)
        return false
    end
    for f in FIELDS                   # type signature forces same FIELDS
        if layout1[f] != layout2[f]   # compare whole arrays
            return false
        end
    end
    return true
end

function Base.:(==)(
    layout1::Record{FIELDS,CONTENTS1},
    layout2::Record{FIELDS,CONTENTS2},
) where {
    FIELDS,
    CONTENTS1<:Base.Tuple{Vararg{Content}},
    CONTENTS2<:Base.Tuple{Vararg{Content}},
}
    for k in FIELDS                   # type signature forces same FIELDS
        if layout1[k] != layout2[k]   # compare record items
            return false
        end
    end
    return true
end

function Base.push!(
    layout::RecordArray{FIELDS,CONTENTS},
    input::NamedTuple{FIELDS},
) where {FIELDS,CONTENTS<:Base.Tuple{Vararg{Content}}}
    for f in FIELDS
        push!(layout.contents[f], input[f])
    end
    end_record!(layout)
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

function _to_buffers!(
    layout::RecordArray{FIELDS,CONTENTS},
    number::Vector{Int64},
    containers::Dict{String,AbstractVector{UInt8}},
) where {FIELDS,CONTENTS<:Base.Tuple{Vararg{Content}}}
    number[begin] += 1

    Dict{String,Any}(
        "class" => "RecordArray",
        "fields" => [String(x) for x in FIELDS],
        "contents" => [_to_buffers!(x, number, containers) for x in layout.contents],
        "parameters" => _to_buffers_parameters(layout),
    )
end

### TupleArray ###########################################################

mutable struct TupleArray{CONTENTS<:Base.Tuple{Vararg{Content}},BEHAVIOR} <:
               Content{BEHAVIOR}
    const contents::CONTENTS
    length::Int64
    const parameters::Parameters
    TupleArray(
        contents::CONTENTS,
        length::Int64;
        parameters::Parameters = Parameters(),
        behavior::Symbol = :default,
    ) where {CONTENTS<:Base.Tuple{Vararg{Content}}} =
        new{CONTENTS,behavior}(contents, length, parameters)
end

TupleArray(
    contents::CONTENTS;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {CONTENTS<:Base.Tuple{Vararg{Content}}} = TupleArray(
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
) where {CONTENTS<:Base.Tuple{Vararg{Content}}} = TupleArray(
    Base.Tuple{Vararg{Content}}(x() for x in CONTENTS.parameters),
    parameters = parameters,
    behavior = behavior,
)

struct SlotRecord{CONTENTS<:Base.Tuple{Vararg{Content}},BEHAVIOR}
    array::TupleArray{CONTENTS,BEHAVIOR}
    at::Int64
end

function copy(
    layout::TupleArray{CONTENTS1,BEHAVIOR};
    contents::Union{Unset,CONTENTS2} = Unset(),
    length::Union{Unset,Int64} = Unset(),
    parameters::Union{Unset,Parameters} = Unset(),
    behavior::Union{Unset,Symbol} = Unset(),
) where {
    CONTENTS1<:Base.Tuple{Vararg{Content}},
    CONTENTS2<:Base.Tuple{Vararg{Content}},
    BEHAVIOR,
}
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

Base.getindex(
    layout::TupleArray{CONTENTS,BEHAVIOR},
    i::Int,
) where {CONTENTS<:Base.Tuple{Vararg{Content}},BEHAVIOR} = SlotRecord(layout, i)

Base.getindex(
    layout::TupleArray{CONTENTS,BEHAVIOR},
    r::UnitRange{Int},
) where {VALUES<:Content,CONTENTS<:Base.Tuple{VALUES},BEHAVIOR} = 
    copy(
        layout,
        contents = Base.Tuple{VALUES}(x[r] for x in layout.contents),
        length = min(r.stop, layout.length) - max(r.start, 1) + 1,   # unnecessary min/max
    )

function slot(
    layout::TupleArray{CONTENTS,BEHAVIOR},
    f::Int,
) where {CONTENTS<:Base.Tuple{Vararg{Content}},BEHAVIOR}
    content = layout.contents[f]
    content[firstindex(content):firstindex(content)+length(layout)-1]
end

Base.getindex(
    layout::SlotRecord{CONTENTS},
    f::Int64,
) where {CONTENTS<:Base.Tuple{Vararg{Content}}} = 
    layout.array.contents[f][layout.at]

function Base.:(==)(
    layout1::TupleArray{CONTENTS1},
    layout2::TupleArray{CONTENTS2},
) where {
    N,
    CONTENTS1<:Base.Tuple{Vararg{Content,N}},
    CONTENTS2<:Base.Tuple{Vararg{Content,N}},
}
    if length(layout1) != length(layout2)
        return false
    end
    for i in eachindex(layout1.contents)         # same number of indexes by type constraint
        if slot(layout1, i) != slot(layout2, i)  # compare whole arrays
            return false
        end
    end
    return true
end

function Base.:(==)(
    layout1::SlotRecord{CONTENTS1},
    layout2::SlotRecord{CONTENTS2},
) where {
    N,
    CONTENTS1<:Base.Tuple{Vararg{Content,N}},
    CONTENTS2<:Base.Tuple{Vararg{Content,N}},
}
    for i in eachindex(layout1.array.contents)   # same number of indexes by type constraint
        if layout1[i] != layout2[i]              # compare tuple items
            return false
        end
    end
    return true
end

function Base.push!(
    layout::TupleArray{CONTENTS},
    input::INPUT,
) where {N,CONTENTS<:Base.Tuple{Vararg{Content,N}},INPUT<:Base.Tuple{Vararg{Any,N}}}
    adjustment = firstindex(layout.contents) - firstindex(input)
    for index in eachindex(layout.contents)      # same number of indexes by type constraint
        push!(layout.contents[index], input[index-adjustment])
    end
    end_tuple!(layout)
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

function _to_buffers!(
    layout::TupleArray{CONTENTS},
    number::Vector{Int64},
    containers::Dict{String,AbstractVector{UInt8}},
) where {CONTENTS<:Base.Tuple{Vararg{Content}}}
    number[begin] += 1

    Dict{String,Any}(
        "class" => "RecordArray",
        "fields" => nothing,
        "contents" => [_to_buffers!(x, number, containers) for x in layout.contents],
        "parameters" => _to_buffers_parameters(layout),
    )
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

Base.eltype(layout::IndexedArray) = eltype(layout.content)
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

function _to_buffers!(
    layout::IndexedArray{INDEX,CONTENT},
    number::Vector{Int64},
    containers::Dict{String,AbstractVector{UInt8}},
) where {INDEX<:IndexBig,CONTENT<:Content}
    form_key = "node$(number[begin])"
    number[begin] += 1

    containers["$form_key-index"] = reinterpret(UInt8, layout.index)

    Dict{String,Any}(
        "class" => "IndexedArray",
        "index" => _to_buffers_index(INDEX),
        "content" => _to_buffers!(layout.content, number, containers),
        "parameters" => _to_buffers_parameters(layout),
        "form_key" => form_key,
    )
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

struct IndexedOptionArray{INDEX<:IndexBigSigned,CONTENT<:Content,BEHAVIOR} <:
       OptionType{BEHAVIOR}
    index::INDEX
    content::CONTENT
    parameters::Parameters
    IndexedOptionArray(
        index::INDEX,
        content::CONTENT;
        parameters::Parameters = Parameters(),
        behavior::Symbol = :default,
    ) where {INDEX<:IndexBigSigned,CONTENT<:Content} =
        new{INDEX,CONTENT,behavior}(index, content, parameters)
end

IndexedOptionArray{INDEX,CONTENT}(;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {INDEX<:IndexBigSigned} where {CONTENT<:Content} =
    IndexedOptionArray(INDEX([]), CONTENT(), parameters = parameters, behavior = behavior)

function copy(
    layout::IndexedOptionArray{INDEX1,CONTENT1,BEHAVIOR};
    index::Union{Unset,INDEX2} = Unset(),
    content::Union{Unset,CONTENT2} = Unset(),
    parameters::Union{Unset,Parameters} = Unset(),
    behavior::Union{Unset,Symbol} = Unset(),
) where {
    INDEX1<:IndexBigSigned,
    INDEX2<:IndexBigSigned,
    CONTENT1<:Content,
    CONTENT2<:Content,
    BEHAVIOR,
}
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

Base.eltype(layout::IndexedOptionArray) = Union{Missing, eltype(layout.content)}
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

function _to_buffers!(
    layout::IndexedOptionArray{INDEX,CONTENT},
    number::Vector{Int64},
    containers::Dict{String,AbstractVector{UInt8}},
) where {INDEX<:IndexBigSigned,CONTENT<:Content}
    form_key = "node$(number[begin])"
    number[begin] += 1

    containers["$form_key-index"] = reinterpret(UInt8, layout.index)

    Dict{String,Any}(
        "class" => "IndexedOptionArray",
        "index" => _to_buffers_index(INDEX),
        "content" => _to_buffers!(layout.content, number, containers),
        "parameters" => _to_buffers_parameters(layout),
        "form_key" => form_key,
    )
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

Base.eltype(layout::ByteMaskedArray) = Union{Missing, eltype(layout.content)}
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

function _to_buffers!(
    layout::ByteMaskedArray{INDEX,CONTENT},
    number::Vector{Int64},
    containers::Dict{String,AbstractVector{UInt8}},
) where {INDEX<:IndexBool,CONTENT<:Content}
    form_key = "node$(number[begin])"
    number[begin] += 1

    containers["$form_key-mask"] = reinterpret(UInt8, layout.mask)

    Dict{String,Any}(
        "class" => "ByteMaskedArray",
        "mask" => _to_buffers_index(INDEX),
        "content" => _to_buffers!(layout.content, number, containers),
        "valid_when" => layout.valid_when,
        "parameters" => _to_buffers_parameters(layout),
        "form_key" => form_key,
    )
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

Base.eltype(layout::BitMaskedArray) = Union{Missing, eltype(layout.content)}
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

function _to_buffers!(
    layout::BitMaskedArray{CONTENT},
    number::Vector{Int64},
    containers::Dict{String,AbstractVector{UInt8}},
) where {CONTENT<:Content}
    form_key = "node$(number[begin])"
    number[begin] += 1

    cut = 1:Int64(ceil(length(layout.mask) / 8.0))
    containers["$form_key-mask"] = reinterpret(UInt8, layout.mask.chunks)[cut]

    Dict{String,Any}(
        "class" => "BitMaskedArray",
        "mask" => "u8",
        "content" => _to_buffers!(layout.content, number, containers),
        "valid_when" => layout.valid_when,
        "lsb_order" => true,
        "parameters" => _to_buffers_parameters(layout),
        "form_key" => form_key,
    )
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

Base.eltype(layout::UnmaskedArray) = Union{Missing, eltype(layout.content)}
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

function _to_buffers!(
    layout::UnmaskedArray{CONTENT},
    number::Vector{Int64},
    containers::Dict{String,AbstractVector{UInt8}},
) where {CONTENT<:Content}
    number[begin] += 1

    Dict{String,Any}(
        "class" => "UnmaskedArray",
        "content" => _to_buffers!(layout.content, number, containers),
        "parameters" => _to_buffers_parameters(layout),
    )
end

### UnionArray ###########################################################

struct UnionArray{
    TAGS<:Index8,
    INDEX<:IndexBig,
    CONTENTS<:Base.Tuple{Vararg{Content}},
    BEHAVIOR,
} <: Content{BEHAVIOR}
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
    ) where {TAGS<:Index8,INDEX<:IndexBig,CONTENTS<:Base.Tuple{Vararg{Content}}} =
        new{TAGS,INDEX,CONTENTS,behavior}(tags, index, contents, parameters)
end

UnionArray{TAGS,INDEX,CONTENTS}(
    contents::CONTENTS;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {TAGS<:Index8,INDEX<:IndexBig,CONTENTS<:Base.Tuple{Vararg{Content}}} =
    UnionArray(TAGS([]), INDEX([]), contents, parameters = parameters, behavior = behavior)

UnionArray{TAGS,INDEX,CONTENTS}(;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {TAGS<:Index8,INDEX<:IndexBig,CONTENTS<:Base.Tuple{Vararg{Content}}} = UnionArray(
    TAGS([]),
    INDEX([]),
    Base.Tuple{Vararg{Content}}(x() for x in CONTENTS.parameters),
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
    CONTENTS1<:Base.Tuple{Vararg{Content}},
    CONTENTS2<:Base.Tuple{Vararg{Content}},
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

Base.eltype(layout::UnionArray) = Union{typeof(layout.contents).parameters...}
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

function _to_buffers!(
    layout::UnionArray{TAGS,INDEX,CONTENTS},
    number::Vector{Int64},
    containers::Dict{String,AbstractVector{UInt8}},
) where {TAGS<:Index8,INDEX<:IndexBig,CONTENTS<:Base.Tuple{Vararg{Content}}}
    form_key = "node$(number[begin])"
    number[begin] += 1

    containers["$form_key-tags"] = reinterpret(UInt8, layout.tags)
    containers["$form_key-index"] = reinterpret(UInt8, layout.index)

    Dict{String,Any}(
        "class" => "UnionArray",
        "tags" => _to_buffers_index(TAGS),
        "index" => _to_buffers_index(INDEX),
        "contents" => [_to_buffers!(x, number, containers) for x in layout.contents],
        "parameters" => _to_buffers_parameters(layout),
        "form_key" => form_key,
    )
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
        RecordArray{ItemType.parameters[1],Base.Tuple{contents...}}

    elseif ItemType <: Base.Tuple
        contents = [layout_for(x) for x in ItemType.parameters]
        TupleArray{Base.Tuple{contents...}}

    elseif Missing <: ItemType
        if ItemType == Any
            error("cannot produce an AwkwardArray layout for $ItemType (too generic)")
        end
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
                contents = Any[out]
                for i = (firstindex(OtherTypes)+1):(lastindex(OtherTypes))
                    push!(contents, UnmaskedArray{layout_for(OtherTypes[i])})
                end
                UnionArray{Index8,Vector{Int64},Base.Tuple{contents...}}
            end
        end

    else
        OtherTypes = Base.uniontypes(ItemType)
        if length(OtherTypes) > 1
            if length(OtherTypes) > 127
                error(
                    "cannot produce a UnionArray with more than 127 possible types: $(length(OtherTypes)) detected",
                )
            end
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

### to_vector ############################################################

to_vector(layout::Content; view::Bool = false, na::Union{Missing,Nothing} = missing) =
    to_vector(layout, firstindex(layout):lastindex(layout), view = view, na = na)

to_vector_or_scalar(x::Content; view::Bool = false, na::Union{Missing,Nothing} = missing) =
    to_vector(x, view = view, na = na)
to_vector_or_scalar(x; view::Bool = false, na = missing) = x

to_vector(
    record::Record{FIELDS,CONTENTS};
    view::Bool = false,
    na::Union{Missing,Nothing} = missing,
) where {FIELDS,CONTENTS<:Base.Tuple{Vararg{Content}}} = NamedTuple{FIELDS}(
    to_vector_or_scalar(record.array.contents[f][record.at], view = view, na = na) for
    f in FIELDS
)

to_vector(
    tuple::Tuple{CONTENTS};
    view::Bool = false,
    na::Union{Missing,Nothing} = missing,
) where {CONTENTS<:Base.Tuple{Vararg{Content}}} = Base.Tuple(
    to_vector_or_scalar(content[record.at], view = view, na = na) for
    content in tuple.array.contents
)

function to_vector(
    layout::PrimitiveArray{ITEM},
    r::UnitRange{Int};
    view::Bool = false,
    na::Union{Missing,Nothing} = missing,
) where {ITEM}
    if view
        Base.view(layout.data, r)
    else
        layout.data[r]
    end
end

function to_vector(
    layout::EmptyArray,
    r::UnitRange{Int};
    view::Bool = false,
    na::Union{Missing,Nothing} = missing,
)
    Vector{Any}()
end

function to_vector(
    layout::ListOffsetArray{INDEX,CONTENT},
    r::UnitRange{Int};
    view::Bool = false,
    na::Union{Missing,Nothing} = missing,
) where {INDEX<:IndexBig,CONTENT<:Content}
    off = firstindex(layout.content)
    [
        to_vector(
            layout.content,
            (layout.offsets[i]+off):(layout.offsets[i+1]+off-1),
            view = view,
            na = na,
        ) for i in r
    ]
end

function to_vector(
    layout::ListArray{INDEX,CONTENT},
    r::UnitRange{Int};
    view::Bool = false,
    na::Union{Missing,Nothing} = missing,
) where {INDEX<:IndexBig,CONTENT<:Content}
    adj = firstindex(layout.starts) - firstindex(layout.stops)
    off = firstindex(layout.content)
    [
        to_vector(
            layout.content,
            (layout.starts[i]+off):(layout.stops[i-adj]+off-1),
            view = view,
            na = na,
        ) for i in r
    ]
end

function to_vector(
    layout::RegularArray{CONTENT},
    r::UnitRange{Int};
    view::Bool = false,
    na::Union{Missing,Nothing} = missing,
) where {CONTENT<:Content}
    size = max(0, layout.size)
    one = firstindex(layout)
    off = firstindex(layout.content)
    [
        to_vector(
            layout.content,
            ((i-one)*size+off):((i+1-one)*size+off-1),
            view = view,
            na = na,
        ) for i in r
    ]
end

function to_vector(
    layout::ListOffsetArray{INDEX,PrimitiveArray{UInt8,BUFFER,:char},:string},
    r::UnitRange{Int};
    view::Bool = false,
    na::Union{Missing,Nothing} = missing,
) where {INDEX<:IndexBig,BUFFER<:AbstractVector{UInt8}}
    off = firstindex(layout.content)
    [
        String(layout.content.data[(layout.offsets[i]+off):(layout.offsets[i+1]+off-1)]) for
        i in r
    ]
end

function to_vector(
    layout::ListArray{INDEX,PrimitiveArray{UInt8,BUFFER,:char},:string},
    r::UnitRange{Int};
    view::Bool = false,
    na::Union{Missing,Nothing} = missing,
) where {INDEX<:IndexBig,BUFFER<:AbstractVector{UInt8}}
    adj = firstindex(layout.starts) - firstindex(layout.stops)
    off = firstindex(layout.content)
    [
        String(layout.content.data[(layout.starts[i]+off):(layout.stops[i-adj]+off-1)]) for
        i in r
    ]
end

function to_vector(
    layout::RegularArray{PrimitiveArray{UInt8,BUFFER,:char},:string},
    r::UnitRange{Int};
    view::Bool = false,
    na::Union{Missing,Nothing} = missing,
) where {BUFFER<:AbstractVector{UInt8}}
    size = max(0, layout.size)
    one = firstindex(layout)
    off = firstindex(layout.content)
    [String(layout.content.data[((i-one)*size+off):((i+1-one)*size+off-1)]) for i in r]
end

function to_vector(
    layout::RecordArray{FIELDS,CONTENTS},
    r::UnitRange{Int};
    view::Bool = false,
    na::Union{Missing,Nothing} = missing,
) where {FIELDS,CONTENTS<:Base.Tuple{Vararg{Content}}}
    contents = NamedTuple{FIELDS}(
        to_vector(layout.contents[f], r, view = view, na = na) for f in FIELDS
    )
    [NamedTuple{FIELDS}(contents[f][i] for f in FIELDS) for i in eachindex(r)]
end

function to_vector(
    layout::TupleArray{CONTENTS},
    r::UnitRange{Int};
    view::Bool = false,
    na::Union{Missing,Nothing} = missing,
) where {CONTENTS<:Base.Tuple{Vararg{Content}}}
    contents = Base.Tuple(
        to_vector(content, r, view = view, na = na) for content in layout.contents
    )
    [Base.Tuple(content[i] for content in contents) for i in eachindex(r)]
end

function to_vector(
    layout::IndexedArray{INDEX,CONTENT},
    r::UnitRange{Int};
    view::Bool = false,
    na::Union{Missing,Nothing} = missing,
) where {INDEX<:IndexBig,CONTENT<:Content}
    off = firstindex(layout.content)
    content = to_vector(layout.content, view = view, na = na)
    [content[layout.index[i]+off] for i in r]
end

function to_vector(
    layout::IndexedOptionArray{INDEX,CONTENT},
    r::UnitRange{Int};
    view::Bool = false,
    na::Union{Missing,Nothing} = missing,
) where {INDEX<:IndexBig,CONTENT<:Content}
    off = firstindex(layout.content)
    content = to_vector(layout.content, view = view, na = na)
    [
        if layout.index[i] < 0
            na
        else
            content[layout.index[i]+off]
        end for i in r
    ]
end

function to_vector(
    layout::ByteMaskedArray{INDEX,CONTENT},
    r::UnitRange{Int};
    view::Bool = false,
    na::Union{Missing,Nothing} = missing,
) where {INDEX<:IndexBool,CONTENT<:Content}
    adj = firstindex(layout.mask) - firstindex(layout.content)
    off = firstindex(layout.content)
    content = to_vector(layout.content, view = view, na = na)
    [
        if (layout.mask[i] != 0) != layout.valid_when
            na
        else
            content[i-adj]
        end for i in r
    ]
end

function to_vector(
    layout::BitMaskedArray{CONTENT},
    r::UnitRange{Int};
    view::Bool = false,
    na::Union{Missing,Nothing} = missing,
) where {CONTENT<:Content}
    adj = firstindex(layout.mask) - firstindex(layout.content)
    off = firstindex(layout.content)
    content = to_vector(layout.content, view = view, na = na)
    [
        if (layout.mask[i] != 0) != layout.valid_when
            na
        else
            content[i-adj]
        end for i in r
    ]
end

function to_vector(
    layout::UnmaskedArray{CONTENT},
    r::UnitRange{Int};
    view::Bool = false,
    na::Union{Missing,Nothing} = missing,
) where {CONTENT<:Content}
    to_vector(layout.content, r, view = view, na = na)
end

function to_vector(
    layout::UnionArray{TAGS,INDEX,CONTENTS},
    r::UnitRange{Int};
    view::Bool = false,
    na::Union{Missing,Nothing} = missing,
) where {TAGS<:Index8,INDEX<:IndexBig,CONTENTS<:Base.Tuple}
    adj = firstindex(layout.tags) - firstindex(layout.index)
    contents =
        Base.Tuple(to_vector(content, view = view, na = na) for content in layout.contents)
    ones = Base.Tuple(firstindex(content) for content in contents)
    one = firstindex(contents)
    [contents[layout.tags[i]+one][layout.index[i-adj]+ones[layout.tags[i]+one]] for i in r]
end

### show (pretty-print) ##################################################

Base.show(
    io::IO,
    data::Union{Content,Record,Tuple};
    limit_rows::Int = 1,
    limit_cols::Int = 80,
) = print(io, _vertical(data, limit_rows, limit_cols))

Base.show(data::Union{Content,Record,Tuple}; limit_rows::Int = 1, limit_cols::Int = 80) =
    print(stdout, _vertical(data, limit_rows, limit_cols))

function _alternate(range::AbstractRange{Int64})
    function generator(channel::Channel{Base.Tuple{Bool,Int64}})
        now = 0.0
        halfway = length(range) / 2.0
        for (fore, back) in zip(range, reverse(range))
            put!(channel, (true, fore))
            if fore != back
                put!(channel, (false, back))
            end
            now += 1.0
            if now >= halfway
                break
            end
        end
    end
    Channel{Base.Tuple{Bool,Int64}}(generator)
end

function _horizontal(data::Any, limit_cols::Int)
    original_limit_cols = limit_cols

    if isa(data, Content)
        front = ["["]
        back = ["]"]
        limit_cols -= 2

        if isempty(data)
            return (2, vcat(front, back))

        elseif length(data) == 1
            (cols_taken, strs) = _horizontal(data[begin], limit_cols)
            return (2 + cols_taken, vcat(front, strs, back))

        else
            limit_cols -= 5   # anticipate the ", ..."
            which = 0
            for (forward, index) in _alternate(eachindex(data))
                current = data[index]

                if forward
                    if which == 0
                        for_comma = 0
                    else
                        for_comma = 2
                    end
                    (cols_taken, strs) = _horizontal(current, limit_cols - for_comma)

                    if limit_cols - (for_comma + cols_taken) >= 0
                        if which != 0
                            push!(front, ", ")
                            limit_cols -= 2
                        end
                        append!(front, strs)
                        limit_cols -= cols_taken
                    else
                        break
                    end

                else
                    (cols_taken, strs) = _horizontal(current, limit_cols - 2)

                    if limit_cols - (2 + cols_taken) >= 0
                        prepend!(back, strs)
                        pushfirst!(back, ", ")
                        limit_cols -= 2 + cols_taken
                    else
                        break
                    end
                end

                which += 1
            end

            if which == 0
                push!(front, "...")
                limit_cols -= 3
            elseif which != length(data)
                push!(front, ", ...")
                limit_cols -= 5
            end

            limit_cols += 5   # credit the ", ..."
            return (original_limit_cols - limit_cols, vcat(front, back))

        end

    elseif isa(data, Record)
        front = ["{"]
        limit_cols -= 2   # both the opening and closing brackets
        limit_cols -= 5   # anticipate the ", ..."

        which = 0
        fields = keys(data.array.contents)
        for field in fields
            key = Base.string(field)

            if which == 0
                for_comma = 0
            else
                for_comma = 2
            end

            if occursin(r"^[A-Za-z_][A-Za-z_0-9]*$", key)
                key_str = key * ": "
            else
                key_str = repr(key) * ": "
            end

            if limit_cols - (for_comma + length(key_str) + 3) >= 0
                if which != 0
                    push!(front, ", ")
                    limit_cols -= 2
                end
                push!(front, key_str)
                limit_cols -= length(key_str)
                which += 1

                if length(fields) == 1
                    target = limit_cols
                else
                    target = Int64(ceil(limit_cols / 2))   # generously half the fields
                end
                (cols_taken, strs) = _horizontal(data[field], target)
                if limit_cols - cols_taken >= 0
                    append!(front, strs)
                    limit_cols -= cols_taken
                else
                    push!(front, "...")
                    limit_cols -= 3
                    break
                end

            else
                break
            end

            which += 1
        end

        if !isempty(fields)
            if which == 0
                push!(front, "...")
                limit_cols -= 3
            elseif which != 2 * length(fields)
                push!(front, ", ...")
                limit_cols -= 5
            end
        end

        limit_cols += 5   # credit the ", ..."
        push!(front, "}")
        return (original_limit_cols - limit_cols, front)

    elseif isa(data, Tuple)
        front = ["("]
        limit_cols -= 2   # both the opening and closing brackets
        limit_cols -= 5   # anticipate the ", ..."

        which = 0
        fields = eachindex(data.array.contents)
        for field in fields
            if which == 0
                for_comma = 0
            else
                for_comma = 2
            end

            if limit_cols - (for_comma + 3) >= 0
                if which != 0
                    push!(front, ", ")
                    limit_cols -= 2
                end
                which += 1

                if length(fields) == 1
                    target = limit_cols
                else
                    target = Int64(ceil(limit_cols / 2))   # generously half the fields
                end
                (cols_taken, strs) = _horizontal(data[field], target)
                if limit_cols - cols_taken >= 0
                    append!(front, strs)
                    limit_cols -= cols_taken
                else
                    push!(front, "...")
                    limit_cols -= 3
                    break
                end

            else
                break
            end

            which += 1
        end

        if !isempty(fields)
            if which == 0
                push!(front, "...")
                limit_cols -= 3
            elseif which != 2 * length(fields)
                push!(front, ", ...")
                limit_cols -= 5
            end
        end

        limit_cols += 5   # credit the ", ..."
        push!(front, ")")
        return (original_limit_cols - limit_cols, front)

        ### You need a LIBRARY for this?!?

        # elseif isa(data, AbstractFloat)
        #     out = @sprintf "%.3g" data
        #     return (length(out), [out])

        # elseif isa(data, Complex)
        #     out = @sprintf "%.3g + %.3gim" data data
        #     return (length(out), [out])

    else
        out = repr(data)
        return (length(out), [out])
    end

end

function _vertical(data::Union{Content,Record,Tuple}, limit_rows::Int, limit_cols::Int)
    if limit_rows <= 1
        (_, strs) = _horizontal(data, limit_cols)
        return join(strs, "")

    elseif isa(data, Content)
        front = Vector{String}([])  # 1-indexed
        back = Vector{String}([])   # 1-indexed
        which = 0
        for (forward, index) in _alternate(eachindex(data))
            (_, strs) = _horizontal(data[index], limit_cols - 2)
            if forward
                push!(front, join(strs, ""))
            else
                pushfirst!(back, join(strs, ""))
            end

            which += 1
            if which >= limit_rows
                break
            end
        end

        if !isempty(data) && which != length(data)
            back[1] = "..."
        end

        out = vcat(front, back)     # 1-indexed
        for (i, val) in enumerate(out)
            if i > 1
                val = out[i] = " " * val
            else
                val = out[i] = "[" * val
            end
            if i < length(out)
                out[i] = val * ","
            else
                out[i] = val * "]"
            end
        end

        return join(out, "\n")

    elseif isa(data, Record)
        front = Vector{String}([])  # 1-indexed

        which = 0
        fields = keys(data.array.contents)
        for field in fields
            key = Base.string(field)
            if occursin(r"^[A-Za-z_][A-Za-z_0-9]*$", key)
                key_str = key * ": "
            else
                key_str = repr(key) * ": "
            end

            (_, strs) = _horizontal(data[field], limit_cols - 2 - length(key_str))
            push!(front, key_str * join(strs, ""))

            which += 1
            if which >= limit_rows
                break
            end
        end

        if !isempty(fields) && which != length(fields)
            front[end] = "..."
        end

        out = front                 # 1-indexed
        for (i, val) in enumerate(out)
            if i > 1
                val = out[i] = " " * val
            else
                val = out[i] = "{" * val
            end
            if i < length(out)
                out[i] = val * ","
            else
                out[i] = val * "}"
            end
        end
        return join(out, "\n")

    elseif isa(data, Tuple)
        front = Vector{String}([])  # 1-indexed

        which = 0
        fields = eachindex(data.array.contents)
        for field in fields
            (_, strs) = _horizontal(data[field], limit_cols - 2)
            push!(front, join(strs, ""))

            which += 1
            if which >= limit_rows
                break
            end
        end

        if !isempty(fields) && which != length(fields)
            front[end] = "..."
        end

        out = front                 # 1-indexed
        for (i, val) in enumerate(out)
            if i > 1
                val = out[i] = " " * val
            else
                val = out[i] = "(" * val
            end
            if i < length(out)
                out[i] = val * ","
            else
                out[i] = val * ")"
            end
        end
        return join(out, "\n")

    end

end

### from_buffers #########################################################

default_buffer_key(form_key::String, attribute::String) = "$form_key-$attribute"

from_buffers(
    form::String,
    length::Int,
    containers::Dict{String,BUFFER};
    buffer_key::BUFFER_KEY_FUNCTION = default_buffer_key,
) where {BUFFER<:AbstractVector{UInt8},BUFFER_KEY_FUNCTION<:Function} =
    from_buffers(JSON.parse(form), length, containers, buffer_key = buffer_key)

function _get_buffer(
    form_key::Union{Nothing,String},
    attribute::String,
    buffer_key::BUFFER_KEY_FUNCTION,
    containers::Dict{String,BUFFER},
) where {BUFFER<:AbstractVector{UInt8},BUFFER_KEY_FUNCTION<:Function}
    if isa(form_key, String)
        key = buffer_key(form_key, attribute)
        if !haskey(containers, key)
            error("form_key-attribute $(repr(key)) not found in containers")
        end
        containers[key]
    else
        error("\"form_key\" property missing")
    end
end

function _get_index(
    form_snippet::String,
    length::Int64,
    buffer::BUFFER,
) where {BUFFER<:AbstractVector{UInt8}}
    if form_snippet == "i8"
        data = reinterpret(Int8, buffer)
    elseif form_snippet == "u8"
        data = reinterpret(UInt8, buffer)
    elseif form_snippet == "i32"
        data = reinterpret(Int32, buffer)
    elseif form_snippet == "u32"
        data = reinterpret(UInt32, buffer)
    elseif form_snippet == "i64"
        data = reinterpret(Int64, buffer)
    else
        error("unrecognized index type in form: $(repr(form_snippet))")
    end
    view(data, (firstindex(data)):(firstindex(data)+length-1))
end

function from_buffers(
    form::Dict{String,Any},
    length::Int,
    containers::Dict{String,BUFFER};
    buffer_key::BUFFER_KEY_FUNCTION = default_buffer_key,
) where {BUFFER<:AbstractVector{UInt8},BUFFER_KEY_FUNCTION<:Function}
    class = get(form, "class", nothing)
    form_key = get(form, "form_key", nothing)

    raw_parameters = get(form, "parameters", Dict{String,Any}())
    parameters__array__ = get(raw_parameters, "__array__", nothing)
    parameters__list__ = get(raw_parameters, "__list__", nothing)
    parameters__record__ = get(raw_parameters, "__record__", nothing)

    behavior = :default
    if class == "NumpyArray"
        if parameters__array__ == "char"
            behavior = :char
            delete!(raw_parameters, "__array__")
        elseif parameters__array__ == "byte"
            behavior = :byte
            delete!(raw_parameters, "__array__")
        end
    elseif class in [
        "ListOffsetArray",      # ListType
        "ListArray",
        "RegularArray",
        "ListOffsetArray32",    # Awkward 1.x compatibility
        "ListOffsetArrayU32",
        "ListOffsetArray64",
        "ListArray32",
        "ListArrayU32",
        "ListArray64",
    ]
        if parameters__array__ == "string"
            behavior = :string
            delete!(raw_parameters, "__array__")
        elseif parameters__array__ == "bytestring"
            behavior = :bytestring
            delete!(raw_parameters, "__array__")
        end
        if !isnothing(parameters__list__)
            behavior = Symbol(parameters__list__)
            delete!(raw_parameters, "__list__")
        end
    elseif class == "RecordArray"
        if !isnothing(parameters__record__)
            behavior = Symbol(parameters__record__)
            delete!(raw_parameters, "__record__")
        end
    end

    parameters = Parameters(pairs(raw_parameters)...)

    if class == "NumpyArray"
        if !haskey(form, "primitive")
            error("missing \"primitive\" property in \"class\": \"$class\" node")
        end
        buffer = _get_buffer(form_key, "data", buffer_key, containers)

        primitive = form["primitive"]
        if primitive == "bool"
            data = reinterpret(Bool, buffer)
        elseif primitive == "int8"
            data = reinterpret(Int8, buffer)
        elseif primitive == "uint8"
            data = reinterpret(UInt8, buffer)
        elseif primitive == "int16"
            data = reinterpret(Int16, buffer)
        elseif primitive == "uint16"
            data = reinterpret(UInt16, buffer)
        elseif primitive == "int32"
            data = reinterpret(Int32, buffer)
        elseif primitive == "uint32"
            data = reinterpret(UInt16, buffer)
        elseif primitive == "int64"
            data = reinterpret(Int64, buffer)
        elseif primitive == "uint64"
            data = reinterpret(Int64, buffer)
        elseif primitive == "float16"
            data = reinterpret(Float16, buffer)
        elseif primitive == "float32"
            data = reinterpret(Float32, buffer)
        elseif primitive == "float64"
            data = reinterpret(Float64, buffer)
        elseif primitive == "complex64"
            data = reinterpret(Complex{Float32}, buffer)
        elseif primitive == "complex128"
            data = reinterpret(Complex{Float64}, buffer)
            # elseif primitive == "datetime64"
            #     FIXME: Dates.DateTime
            # elseif primitive == "timedelta64"
            #     FIXME: Dates.TimePeriod
        else
            error(
                "unrecognized \"primitive\": $(repr(primitive)) in \"class\": \"$class\" node",
            )
        end

        inner_shape = Vector{Int64}(get(form, "inner_shape", []))
        lengths = [length]
        for size in inner_shape
            push!(lengths, length * size)
            length *= size
        end

        data = view(data, (firstindex(data)):(firstindex(data)+length-1))
        pop!(lengths)

        out::Content = PrimitiveArray(data, parameters = parameters, behavior = behavior)

        for (size, zeros_length) in zip(reverse(inner_shape), reverse(lengths))
            out = RegularArray(out, size, zeros_length = zeros_length)
        end
        out

    elseif class == "EmptyArray"
        if length != 0
            error("length is $length (should be 0) in \"class\": \"$class\" node")
        end

        EmptyArray(behavior = behavior)

    elseif class in [
        "ListOffsetArray",
        "ListOffsetArray32",
        "ListOffsetArrayU32",
        "ListOffsetArray64",
    ]
        if !haskey(form, "offsets")
            error("missing \"offsets\" in \"class\": \"$class\" node")
        end
        form_offsets = form["offsets"]

        offsets_buffer = _get_buffer(form_key, "offsets", buffer_key, containers)
        offsets = _get_index(form_offsets, length + 1, offsets_buffer)

        form_content = get(form, "content", nothing)
        if isa(form_content, Dict{String,Any})
            content = from_buffers(
                form_content,
                if Base.length(offsets) == 1
                    0
                else
                    offsets[end]
                end,
                containers,
                buffer_key = buffer_key,
            )
        else
            error("missing (or not object-typed) \"content\" in \"class\": \"$class\" node")
        end

        ListOffsetArray(offsets, content, parameters = parameters, behavior = behavior)

    elseif class in ["ListArray", "ListArray32", "ListArrayU32", "ListArray64"]
        if !haskey(form, "starts")
            error("missing \"starts\" in \"class\": \"$class\" node")
        end
        if !haskey(form, "stops")
            error("missing \"stops\" in \"class\": \"$class\" node")
        end
        form_starts = form["starts"]
        form_stops = form["stops"]

        starts_buffer = _get_buffer(form_key, "starts", buffer_key, containers)
        starts = _get_index(form_starts, length, starts_buffer)
        stops_buffer = _get_buffer(form_key, "stops", buffer_key, containers)
        stops = _get_index(form_stops, length, stops_buffer)

        max_stop = 0
        for (start, stop) in zip(starts, stops)
            if start != stop
                max_stop = max(max_stop, stop)
            end
        end

        form_content = get(form, "content", nothing)
        if isa(form_content, Dict{String,Any})
            content =
                from_buffers(form_content, max_stop, containers, buffer_key = buffer_key)
        else
            error("missing (or not object-typed) \"content\" in \"class\": \"$class\" node")
        end

        ListArray(starts, stops, content, parameters = parameters, behavior = behavior)

    elseif class == "RegularArray"
        size = get(form, "size", nothing)
        if !isa(size, Int)
            error(
                "missing (or not int-typed) \"size\" in \"class\": \"$class\" node: $(repr(size))",
            )
        end

        next_length = length * size

        form_content = get(form, "content", nothing)
        if isa(form_content, Dict{String,Any})
            content =
                from_buffers(form_content, next_length, containers, buffer_key = buffer_key)
        else
            error("missing (or not object-typed) \"content\" in \"class\": \"$class\" node")
        end

        RegularArray(
            content,
            size,
            zeros_length = length,
            parameters = parameters,
            behavior = behavior,
        )

    elseif class == "RecordArray"
        is_tuple = true
        fields = Vector{Symbol}()
        contents = Vector{Content}()

        if haskey(form, "fields")               # new serialization (Awkward 2.x)
            form_contents = get(form, "contents", nothing)
            if isa(form_contents, Vector)
                for form_content in form_contents
                    if isa(form_content, Dict{String,Any})
                        push!(
                            contents,
                            from_buffers(
                                form_content,
                                length,
                                containers,
                                buffer_key = buffer_key,
                            ),
                        )
                    else
                        error(
                            "non-object found in \"contents\" in \"class\": \"$class\" node",
                        )
                    end
                end
            else
                error(
                    "missing (or not array-typed) \"contents\" in \"class\": \"$class\" node",
                )
            end

            form_fields = form["fields"]
            if !isnothing(form_fields)
                is_tuple = false
                for field in form["fields"]
                    push!(fields, Symbol(field))
                end
                if Base.length(fields) != Base.length(contents)
                    error(
                        "different number of \"fields\" and \"contents\" in \"class\": \"$class\" node",
                    )
                end
            end

        else
            form_contents = get(form, "contents", nothing)
            if isa(form_contents, Dict)         # old Record serialization (Awkward 1.x)
                is_tuple = false
                for (field, form_content) in form_contents
                    if isa(form_content, Dict{String,Any})
                        push!(
                            contents,
                            from_buffers(
                                form_content,
                                length,
                                containers,
                                buffer_key = buffer_key,
                            ),
                        )
                        push!(fields, Symbol(field))
                    else
                        error(
                            "non-object found in \"contents\" in old-style \"class\": \"$class\" node",
                        )
                    end
                end
            elseif isa(form_contents, Vector)   # old or new Tuple serialization
                for form_content in form_contents
                    if isa(form_content, Dict{String,Any})
                        push!(
                            contents,
                            from_buffers(
                                form_content,
                                length,
                                containers,
                                buffer_key = buffer_key,
                            ),
                        )
                    else
                        error(
                            "non-object found in \"contents\" in old-style \"class\": \"$class\" node",
                        )
                    end
                end
            else
                error(
                    "missing (or not array/object-typed) \"contents\" in old-style \"class\": \"$class\" node",
                )
            end
        end

        if is_tuple
            TupleArray(
                Base.Tuple(contents),
                length,
                parameters = parameters,
                behavior = behavior,
            )
        else
            RecordArray(
                NamedTuple{Base.Tuple(fields)}(Base.Tuple(contents)),
                length,
                parameters = parameters,
                behavior = behavior,
            )
        end

    elseif class in ["IndexedArray", "IndexedArray32", "IndexedArrayU32", "IndexedArray64"]
        if !haskey(form, "index")
            error("missing \"index\" in \"class\": \"$class\" node")
        end
        form_index = form["index"]

        index_buffer = _get_buffer(form_key, "index", buffer_key, containers)
        index = _get_index(form_index, length, index_buffer)

        next_length = 0
        for x in index
            next_length = max(next_length, x + 1)
        end

        form_content = get(form, "content", nothing)
        if isa(form_content, Dict{String,Any})
            content =
                from_buffers(form_content, next_length, containers, buffer_key = buffer_key)
        else
            error("missing (or not object-typed) \"content\" in \"class\": \"$class\" node")
        end

        IndexedArray(index, content, parameters = parameters, behavior = behavior)

    elseif class in ["IndexedOptionArray", "IndexedOptionArray32", "IndexedOptionArray64"]
        if !haskey(form, "index")
            error("missing \"index\" in \"class\": \"$class\" node")
        end
        form_index = form["index"]

        index_buffer = _get_buffer(form_key, "index", buffer_key, containers)
        index = _get_index(form_index, length, index_buffer)

        next_length = 0
        for x in index
            if x >= 0
                next_length = max(next_length, x + 1)
            end
        end

        form_content = get(form, "content", nothing)
        if isa(form_content, Dict{String,Any})
            content =
                from_buffers(form_content, next_length, containers, buffer_key = buffer_key)
        else
            error("missing (or not object-typed) \"content\" in \"class\": \"$class\" node")
        end

        IndexedOptionArray(index, content, parameters = parameters, behavior = behavior)

    elseif class == "ByteMaskedArray"
        if !haskey(form, "mask")
            error("missing \"mask\" in \"class\": \"$class\" node")
        end
        form_mask = form["mask"]

        mask_buffer = _get_buffer(form_key, "mask", buffer_key, containers)
        mask = _get_index(form_mask, length, mask_buffer)

        form_content = get(form, "content", nothing)
        if isa(form_content, Dict{String,Any})
            content =
                from_buffers(form_content, length, containers, buffer_key = buffer_key)
        else
            error("missing (or not object-typed) \"content\" in \"class\": \"$class\" node")
        end

        valid_when = get(form, "valid_when", nothing)
        if valid_when != false && valid_when != true
            error(
                "missing (or not boolean-typed) \"valid_when\" in \"class\": \"$class\" node",
            )
        end

        ByteMaskedArray(
            mask,
            content,
            valid_when = valid_when,
            parameters = parameters,
            behavior = behavior,
        )

    elseif class == "BitMaskedArray"
        if !haskey(form, "mask")
            error("missing \"mask\" in \"class\": \"$class\" node")
        end
        form_mask = form["mask"]

        excess_length = Int64(ceil(length / 8.0))

        mask_buffer = _get_buffer(form_key, "mask", buffer_key, containers)
        raw_mask = _get_index(form_mask, excess_length, mask_buffer)

        form_content = get(form, "content", nothing)
        if isa(form_content, Dict{String,Any})
            content =
                from_buffers(form_content, length, containers, buffer_key = buffer_key)
        else
            error("missing (or not object-typed) \"content\" in \"class\": \"$class\" node")
        end

        valid_when = get(form, "valid_when", nothing)
        if valid_when != false && valid_when != true
            error(
                "missing (or not boolean-typed) \"valid_when\" in \"class\": \"$class\" node",
            )
        end

        lsb_order = get(form, "lsb_order", nothing)
        if lsb_order != false && lsb_order != true
            error(
                "missing (or not boolean-typed) \"lsb_order\" in \"class\": \"$class\" node",
            )
        end

        mask = falses(length)
        unsafe_copyto!(
            reinterpret(Ptr{UInt8}, pointer(mask.chunks)),
            pointer(raw_mask),
            excess_length,
        )

        if !lsb_order
            mask.len = excess_length * 8

            off = firstindex(mask)
            for i = 0:8:((excess_length-1)*8)
                mask[(i+off):(i+off+7)] = reverse(mask[(i+off):(i+off+7)])
            end

            mask.len = length
        end

        BitMaskedArray(
            mask,
            content,
            valid_when = valid_when,
            parameters = parameters,
            behavior = behavior,
        )

    elseif class == "UnmaskedArray"
        form_content = get(form, "content", nothing)
        if isa(form_content, Dict{String,Any})
            content =
                from_buffers(form_content, length, containers, buffer_key = buffer_key)
        else
            error("missing (or not object-typed) \"content\" in \"class\": \"$class\" node")
        end

        UnmaskedArray(content, parameters = parameters, behavior = behavior)

    elseif class in ["UnionArray", "UnionArray8_32", "UnionArray8_U32", "UnionArray8_64"]
        if !haskey(form, "tags")
            error("missing \"tags\" in \"class\": \"$class\" node")
        end
        if !haskey(form, "index")
            error("missing \"index\" in \"class\": \"$class\" node")
        end
        form_tags = form["tags"]
        form_index = form["index"]

        tags_buffer = _get_buffer(form_key, "tags", buffer_key, containers)
        tags = _get_index(form_tags, length, tags_buffer)
        index_buffer = _get_buffer(form_key, "index", buffer_key, containers)
        index = _get_index(form_index, length, index_buffer)

        contents = Vector{Content}()
        form_contents = get(form, "contents", nothing)
        if isa(form_contents, Vector)
            lengths = zeros(Int64, Base.length(form_contents))
            off = firstindex(tags)
            adj = firstindex(tags) - firstindex(index)
            for i in eachindex(tags)
                tag = tags[i]
                lengths[tag+off] = max(lengths[tag+off], index[i-adj] + 1)
            end

            adj2 = firstindex(form_contents) - firstindex(lengths)
            for (tag, form_content) in enumerate(form_contents)
                if isa(form_content, Dict{String,Any})
                    push!(
                        contents,
                        from_buffers(
                            form_content,
                            lengths[tag-adj2],
                            containers,
                            buffer_key = buffer_key,
                        ),
                    )
                else
                    error("non-object found in \"contents\" in \"class\": \"$class\" node")
                end
            end
        else
            error("missing (or not array-typed) \"contents\" in \"class\": \"$class\" node")
        end

        UnionArray(
            tags,
            index,
            Base.Tuple(contents);
            parameters = parameters,
            behavior = behavior,
        )

    else
        error("missing or unrecognized \"class\" property: $(repr(class))")
    end
end  # function from_buffers

### to_buffers ###########################################################

function to_buffers(layout::Content)
    containers = Dict{String,AbstractVector{UInt8}}()
    number = Vector{Int64}([0])
    form = _to_buffers!(layout, number, containers)
    (JSON.json(form), length(layout), containers)
end

function _to_buffers_parameters(layout::CONTENT) where {BEHAVIOR,CONTENT<:Content{BEHAVIOR}}
    out = Dict{String,Any}()
    for k in keys(layout.parameters)
        out[k] = get_parameter(layout.parameters, k)
    end
    if isa(layout, PrimitiveArray)
        if BEHAVIOR == :char
            out["__array__"] = "char"
        elseif BEHAVIOR == :byte
            out["__array__"] = "byte"
        end
    elseif isa(layout, ListType)
        if BEHAVIOR == :string
            out["__array__"] = "string"
        elseif BEHAVIOR == :bytestring
            out["__array__"] = "bytestring"
        elseif BEHAVIOR != :default
            out["__list__"] = String(BEHAVIOR)
        end
    elseif isa(layout, RecordArray)
        if BEHAVIOR != :default
            out["__record__"] = String(BEHAVIOR)
        end
    end
    out
end

function _to_buffers_index(IndexType::DataType)
    if IndexType <: Index8
        "i8"
    elseif IndexType <: AbstractVector{Bool}
        "i8"
    elseif IndexType <: IndexU8
        "u8"
    elseif IndexType <: Index32
        "i32"
    elseif IndexType <: IndexU32
        "u32"
    elseif IndexType <: Index64
        "i64"
    else
        error("unexpected INDEX type in to_buffers: $IndexType")
    end
end
