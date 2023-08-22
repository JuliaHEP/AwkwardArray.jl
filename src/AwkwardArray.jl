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
        if x != y
            return false
        end
    end
    return true
end

### PrimitiveArray #######################################################

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
        behavior = typeof(layout).parameters[end]
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

Base.:(==)(layout1::PrimitiveArray, layout2::PrimitiveArray) = layout1.data == layout2.data  # override for performance

function push!(layout::PrimitiveArray{ITEM}, x::ITEM) where {ITEM}
    Base.push!(layout.data, x)
    layout
end

### EmptyArray ###########################################################

struct EmptyArray{BEHAVIOR} <: LeafType{BEHAVIOR}
    EmptyArray(; behavior::Symbol = :default) = new{behavior}()
end

copy(behavior::Union{Unset,Symbol} = Unset()) = EmptyArray(behavior = behavior)

parameters_of(content::EmptyArray) = Parameters()
has_parameter(content::EmptyArray, key::String) where {CONTENT<:Content} = false
get_parameter(content::EmptyArray, key::String) where {CONTENT<:Content} = nothing

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
        behavior = typeof(layout).parameters[end]
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
    Base.push!(layout.offsets, length(layout.content))
    layout
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
        behavior = typeof(layout).parameters[end]
    end
    ListArray(starts, stops, content, parameters = parameters, behavior = behavior)
end

function is_valid(layout::ListArray)
    if length(layout.starts) < length(layout.stops)
        return false
    end
    for i in eachindex(layout)
        start = layout.starts[i]
        stop = layout.stops[i]
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
        Base.push!(layout.starts, 0)
    else
        Base.push!(layout.starts, layout.stops[end])
    end
    Base.push!(layout.stops, length(layout.content))
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

RegularArray{CONTENT}(;
    parameters::Parameters = Parameters(),
    behavior::Symbol = :default,
) where {CONTENT<:Content} = RegularArray(
    CONTENT(),
    0,
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
        behavior = typeof(layout).parameters[end]
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
    start = (i - firstindex(layout)) * layout.size + firstindex(layout.content)
    stop = (i + 1 - firstindex(layout)) * layout.size + firstindex(layout.content) - 1
    layout.content[start:stop]
end

function Base.getindex(layout::RegularArray, r::UnitRange{Int})
    start = (r.start - firstindex(layout)) * layout.size + firstindex(layout.content)
    stop = (r.stop - 1 - firstindex(layout)) * layout.size + firstindex(layout.content) + 1
    copy(layout, content = layout.content[start:stop], zeros_length = r.stop - r.start + 1)
end

Base.getindex(layout::RegularArray, f::Symbol) = copy(layout, content = layout.content[f])

function end_list!(layout::RegularArray)
    if layout.length == 0
        layout.size = length(layout.content)
        layout.length = 1
    elseif length(layout.content) == (layout.length + 1) * layout.size
        layout.length += 1
    else
        error(
            "RegularArray list lengths changed: from $layout.size to $(div(length(layout.content), (layout.length + 1)))",
        )
    end
end

### ListType with behavior = :string #####################################

function Base.getindex(
    layout::ListOffsetArray{INDEX,PrimitiveArray{UInt8,BUFFER,:char},:string},
    i::Int,
) where {INDEX<:IndexBig,BUFFER<:AbstractVector{UInt8}}
    String(
        getindex(
            copy(
                layout,
                content = copy(layout.content, behavior = :default),
                behavior = :default,
            ),
            i,
        ).data,
    )
end

function Base.getindex(
    layout::ListArray{INDEX,PrimitiveArray{UInt8,BUFFER,:char},:string},
    i::Int,
) where {INDEX<:IndexBig,BUFFER<:AbstractVector{UInt8}}
    String(
        getindex(
            copy(
                layout,
                content = copy(layout.content, behavior = :default),
                behavior = :default,
            ),
            i,
        ).data,
    )
end

function Base.getindex(
    layout::RegularArray{PrimitiveArray{UInt8,BUFFER,:char},:string},
    i::Int,
) where {BUFFER<:AbstractVector{UInt8}}
    String(
        getindex(
            copy(
                layout,
                content = copy(layout.content, behavior = :default),
                behavior = :default,
            ),
            i,
        ).data,
    )
end

### ListType with behavior = :bytestring #################################

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
        behavior = typeof(layout).parameters[end]
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

Base.getindex(layout::RecordArray, r::UnitRange{Int}) = copy(
    layout,
    contents = NamedTuple{keys(layout.contents)}(
        Pair(k, v[r]) for (k, v) in pairs(layout.contents)
    ),
    length = min(r.stop, layout.length) - max(r.start, 1) + 1,   # unnecessary min/max
)

function Base.getindex(layout::RecordArray, f::Symbol)
    content = layout.contents[f]
    content[firstindex(content):firstindex(content)+length(layout)-1]
end

Base.getindex(layout::Record, f::Symbol) = layout.array.contents[f][layout.at]

function Base.:(==)(
    layout1::RecordArray{CONTENTS},
    layout2::RecordArray{CONTENTS},
) where {CONTENTS<:NamedTuple}
    if length(layout1) != length(layout2)
        return false
    end
    for k in keys(layout1.contents)   # same keys because same CONTENTS type
        if layout1[k] != layout2[k]   # compare whole arrays
            return false
        end
    end
    return true
end

function Base.:(==)(
    layout1::Record{ARRAY},
    layout2::Record{ARRAY},
) where {CONTENTS<:NamedTuple,ARRAY<:RecordArray{CONTENTS}}
    for k in keys(layout1.array.contents)   # same keys because same CONTENTS type
        if layout1[k] != layout2[k]         # compare record items
            return false
        end
    end
    return true
end

function end_record!(layout::RecordArray)
    layout.length += 1
    @assert all(length(x) >= layout.length for x in layout.contents)
    layout
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
        behavior = typeof(layout).parameters[end]
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

function push!(
    layout::IndexedArray{INDEX,CONTENT},
    x::ITEM,
) where {INDEX<:IndexBig,ITEM,CONTENT<:PrimitiveArray{ITEM}}
    tmp = length(layout.content)
    push!(layout.content, x)
    Base.push!(layout.index, tmp)
    layout
end

function end_list!(
    layout::IndexedArray{INDEX,CONTENT},
) where {INDEX<:IndexBig,CONTENT<:ListType}
    tmp = length(layout.content)
    end_list!(layout.content)
    Base.push!(layout.index, tmp)
    layout
end

function end_record!(
    layout::IndexedArray{INDEX,CONTENT},
) where {INDEX<:IndexBig,CONTENT<:RecordArray}
    tmp = length(layout.content)
    end_record!(layout.content)
    Base.push!(layout.index, tmp)
    layout
end

### IndexedOptionArray ###################################################

struct IndexedOptionArray{INDEX<:IndexBig,CONTENT<:Content,BEHAVIOR} <: Content{BEHAVIOR}
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
        behavior = typeof(layout).parameters[end]
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
        nothing
    else
        layout.content[layout.index[i]+firstindex(layout.content)]
    end
end

Base.getindex(layout::IndexedOptionArray, r::UnitRange{Int}) =
    copy(layout, index = layout.index[r.start:r.stop])

Base.getindex(layout::IndexedOptionArray, f::Symbol) =
    copy(layout, content = layout.content[f])

function push!(
    layout::IndexedOptionArray{INDEX,CONTENT},
    x::ITEM,
) where {INDEX<:IndexBig,ITEM,CONTENT<:PrimitiveArray{ITEM}}
    tmp = length(layout.content)
    push!(layout.content, x)
    Base.push!(layout.index, tmp)
    layout
end

function push_null!(layout::IndexedOptionArray)
    Base.push!(layout.index, -1)
    layout
end

function end_list!(
    layout::IndexedOptionArray{INDEX,CONTENT},
) where {INDEX<:IndexBig,CONTENT<:ListType}
    tmp = length(layout.content)
    end_list!(layout.content)
    Base.push!(layout.index, tmp)
    layout
end

function end_record!(
    layout::IndexedOptionArray{INDEX,CONTENT},
) where {INDEX<:IndexBig,CONTENT<:RecordArray}
    tmp = length(layout.content)
    end_record!(layout.content)
    Base.push!(layout.index, tmp)
    layout
end





end
