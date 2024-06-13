is_iterable(obj) = try
    iterate(obj) !== nothing
catch
    false
end

function object_type_iterable(obj)
    # Get the type of the object
    T = typeof(obj)
    
    # Create an instance of the specified type
    obj_instance = T()
    
    # Attempt to iterate over the object
    iter_result = iterate(obj_instance)
    
    # Return true if iteration succeeds, false otherwise
    return iter_result !== nothing
end

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
function generate_form_key!(form_key_id_ref::Base.RefValue{Int64})
    form_key_id = form_key_id_ref[]
    form_key_id_ref[] += 1
    return "node$form_key_id"
end

function json_numpy_form(parameters::String, form_key::String)
    return "{\"class\": \"NumpyArray\", \"primitive\": \"" * parameters *
    "\"form_key\": \"" * form_key * "\"}"
end

# Method for handling primitive types
function type_to_form(::Type{T}, form_key_id::Int64) where {T <: Integer} 
    form_key = "node$(form_key_id)"
    form_key_id += 1

    parameters = string(julia_to_numpy_type(T), "\", ")

    return json_numpy_form(parameters, form_key)
end

function type_to_form(::Type{T}, form_key_id::Int64) where {T <: AbstractFloat}
    form_key = "node$(form_key_id)"
    form_key_id += 1

    parameters = string(julia_to_numpy_type(T), "\", ")
    return json_numpy_form(parameters, form_key)
end

function type_to_form(::Type{T}, form_key_id::Int64) where {T <: Bool}
    form_key = "node$(form_key_id)"
    form_key_id += 1

    parameters = string(julia_to_numpy_type(T), "\", ")

    return json_numpy_form(parameters, form_key)
end

function type_to_form(::Type{T}, form_key_id::Int64) where {T <: Char}
    form_key = "node$(form_key_id)"
    form_key_id += 1

    parameters = "uint8\", \"parameters\": { \"__array__\": \"char\" }, "

    return json_numpy_form(parameters, form_key)
end

function type_to_form(::Type{T}, form_key_id::Int64) where {T <: String}
    value_type = eltype(T)
    form_key = "node$(form_key_id)"
    form_key_id += 1

    parameters = " \"parameters\": { \"__array__\": \"string\" }, "

    content = type_to_form(value_type, form_key_id)

    return "{\"class\": \"ListOffsetArray\", \"offsets\": \"" * type_to_numpy_like(T) * "\", " *
           "\"content\":" * content * ", " * parameters *
           "\"form_key\": \"" * form_key * "\"}"
end

# Method for handling iterable types
function type_to_form(::Type{T}, form_key_id::Int64) where {T <: Vector}
    value_type = eltype(T)
    form_key = "node$(form_key_id)"
    form_key_id += 1

    parameters = ""
    if value_type == Char
        parameters = " \"parameters\": { \"__array__\": \"string\" }, "
    end

    content = type_to_form(value_type, form_key_id)

    return "{\"class\": \"ListOffsetArray\", \"offsets\": \"" * type_to_numpy_like(T) * "\", " *
           "\"content\":" * content * ", " * parameters *
           "\"form_key\": \"" * form_key * "\"}"
end

# Fallback method for unsupported types
function type_to_form(::Type{T}, form_key_id::Int64) where {T}
    error("Type '$T' is not supported yet.")
end

# Helper function for type_to_numpy_like (placeholder implementation)
function type_to_numpy_like(::Type{T}) where {T}
    return "int64"  # Placeholder implementation
end

function tree_branches_type(tree)
    for name in propertynames(tree)
        branch = getproperty(tree, name)
        branch_type = eltype(branch)
        println("Is it a primitive type? ", AwkwardArray.isprimitive(branch_type))
        if branch_type <: SubArray
            println(name, " ==>>> ", branch_type.parameters[3])
        else
            println(name, " ==> ", branch_type)
        end
    end
end