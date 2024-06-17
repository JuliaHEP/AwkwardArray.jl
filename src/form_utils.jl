
# Define a dictionary mapping Julia types to NumPy types
const julia_to_numpy = Dict(
    Int8 => "int8",
    UInt8 => "uint8",
    Int16 => "int16",
    UInt16 => "uint16",
    Int32 => "int32",
    UInt32 => "uint32",
    Int64 => "int64",
    UInt64 => "uint64",
    Float16 => "float16",
    Float32 => "float32",
    Float64 => "float64",
    Bool => "bool",
    Complex{Float32} => "complex64",
    Complex{Float64} => "complex128",
    String => "str"
)

# Function to get the corresponding NumPy type
function julia_to_numpy_type(julia_type::Type)
    result = get(julia_to_numpy, julia_type, "unknown")
    return String(result)
end

# Function to generate form key
function _generate_form_key!(form_key_id_ref::Base.RefValue{Int64})
    form_key_id = form_key_id_ref[]
    form_key_id_ref[] += 1
    return "node$form_key_id"
end

function json_numpy_form(parameters::String, form_key::String)
    return "{\"class\": \"NumpyArray\", \"primitive\": \"" * parameters *
           "\"form_key\": \"" * form_key * "\"}"
end

# Function for handling primitive types
function type_to_form(::Type{T}, form_key_id::Int64=0) where {T <: Integer} 
    form_key = "node$(form_key_id)"
    form_key_id += 1

    parameters = julia_to_numpy_type(T) * "\", "

    return json_numpy_form(parameters, form_key)
end

function type_to_form(::Type{T}, form_key_id_ref::Base.RefValue{Int64}) where {T <: Integer} 
    form_key = _generate_form_key!(form_key_id_ref)

    parameters = julia_to_numpy_type(T) * "\", "

    return json_numpy_form(parameters, form_key)
end

function type_to_form(::Type{T}, form_key_id::Int64=0) where {T <: AbstractFloat}
    form_key = "node$(form_key_id)"
    form_key_id += 1

    parameters = julia_to_numpy_type(T) * "\", "

    return json_numpy_form(parameters, form_key)
end

function type_to_form(::Type{T}, form_key_id_ref::Base.RefValue{Int64}) where {T <: AbstractFloat}
    form_key = _generate_form_key!(form_key_id_ref)

    parameters = julia_to_numpy_type(T) * "\", "

    return json_numpy_form(parameters, form_key)
end

function type_to_form(::Type{T}, form_key_id::Int64=0) where {T <: Bool}
    form_key = "node$(form_key_id)"
    form_key_id += 1

    parameters = julia_to_numpy_type(T) * "\", "

    return json_numpy_form(parameters, form_key)
end

function type_to_form(::Type{T}, form_key_id_ref::Base.RefValue{Int64}) where {T <: Bool}
    form_key = _generate_form_key!(form_key_id_ref)

    parameters = julia_to_numpy_type(T) * "\", "

    return json_numpy_form(parameters, form_key)
end

function type_to_form(::Type{T}, form_key_id::Int64=0) where {T <: Char}
    form_key = "node$(form_key_id)"
    form_key_id += 1

    parameters = "uint8\", \"parameters\": { \"__array__\": \"char\" }, "

    return json_numpy_form(parameters, form_key)
end

function type_to_form(::Type{T}, form_key_id_ref::Base.RefValue{Int64}) where {T <: Char}
    form_key = _generate_form_key!(form_key_id_ref)

    parameters = "uint8\", \"parameters\": { \"__array__\": \"char\" }, "

    return json_numpy_form(parameters, form_key)
end

function type_to_form(::Type{T}, form_key_id::Int64=0) where {T <: String}
    value_type = eltype(T)
    form_key = "node$(form_key_id)"
    form_key_id += 1

    parameters = " \"parameters\": { \"__array__\": \"string\" }, "

    content = type_to_form(value_type, form_key_id)

    return "{\"class\": \"ListOffsetArray\", \"offsets\": \"" * 
           type_to_numpy_like(T) * "\", " *
           "\"content\": " * content * ", " * parameters *
           "\"form_key\": \"" * form_key * "\"}"
end

function type_to_form(::Type{T}, form_key_id_ref::Base.RefValue{Int64}) where {T <: String}
    value_type = eltype(T)
    form_key = _generate_form_key!(form_key_id_ref)

    parameters = " \"parameters\": { \"__array__\": \"string\" }, "

    content = type_to_form(value_type, form_key_id_ref)

    return "{\"class\": \"ListOffsetArray\", \"offsets\": \"" * 
           type_to_numpy_like(T) * "\", " *
           "\"content\": " * content * ", " * parameters *
           "\"form_key\": \"" * form_key * "\"}"
end

# Function to handle specific Vector types
function type_to_form(::Type{Vector{T}}, form_key_id::Int64=0) where {T}
    element_type = T
    content_form = type_to_form(element_type, form_key_id + 1)
    return "{\"class\": \"ListOffsetArray\", \"offsets\": \"int64\", " *
           "\"content\": " * content_form * ", " *
           "\"form_key\": \"node$(form_key_id)\"}"
end

function type_to_form(::Type{Vector{T}}, form_key_id_ref::Base.RefValue{Int64}) where {T}
    element_type = T
    form_key = _generate_form_key!(form_key_id_ref)

    content_form = type_to_form(element_type, form_key_id_ref)
    return "{\"class\": \"ListOffsetArray\", \"offsets\": \"int64\", " *
           "\"content\": " * content_form * ", " *
           "\"form_key\": \"" * form_key * "\"}"
end

# Function for handling iterable types
function type_to_form(::Type{T}, form_key_id::Int64=0) where {T <: AbstractVector}
    value_type = eltype(T)
    form_key = "node$(form_key_id)"
    form_key_id += 1

    parameters = ""
    if value_type == Char
        parameters = " \"parameters\": { \"__array__\": \"string\" }, "
    end

    content = type_to_form(value_type, form_key_id)

    return "{\"class\": \"ListOffsetArray\", \"offsets\": \"" * 
           type_to_numpy_like(T) * "\", " *
           "\"content\": " * content * ", " * parameters *
           "\"form_key\": \"" * form_key * "\"}"
end

function type_to_form(::Type{T}, form_key_id_ref::Base.RefValue{Int64}) where {T <: AbstractVector}
    value_type = eltype(T)
    form_key = _generate_form_key!(form_key_id_ref)

    parameters = ""
    if value_type == Char
        parameters = " \"parameters\": { \"__array__\": \"string\" }, "
    end

    content = type_to_form(value_type, form_key_id_ref)

    return "{\"class\": \"ListOffsetArray\", \"offsets\": \"" * 
           type_to_numpy_like(T) * "\", " *
           "\"content\": " * content * ", " * parameters *
           "\"form_key\": \"" * form_key * "\"}"
end

# Fallback function for unsupported types
function type_to_form(::Type{T}, ::Int64) where {T}
    error("Type '$T' is not supported yet.")
end

function type_to_form(::Type{T}, ::Base.RefValue{Int64}) where {T}
    error("Type '$T' is not supported yet.")
end

# Helper function for type_to_numpy_like (placeholder implementation)
function type_to_numpy_like(::Type{T}) where {T}
    return "i64"  # Placeholder implementation
end

# A RecordArray form of all tree brunches
function tree_branches_type(tree, form_key_id::Int64=0)
    id = form_key_id
    id_ref = Ref(id)

    form = """{"class": "RecordArray", "fields": ["""
    form_key = _generate_form_key!(id_ref)

    form_fields = ""
    form_contents = ""
    for name in propertynames(tree)
        form_fields = form_fields * """\"$name\", """
        branch = getproperty(tree, name)
        branch_type = eltype(branch)
        form_contents *= type_to_form(branch_type, id_ref) * ", "
    end

    # Removing the trailing comma and space
    form_fields = replace(rstrip(form_fields), r",\s*$" => "")
    form_contents = replace(rstrip(form_contents), r",\s*$" => "")
    
    form *= form_fields * """], "contents": [""" * form_contents 
    form *= """], "parameters": {}, "form_key": \"""" * 
        form_key * "\"}"

    return form
end

