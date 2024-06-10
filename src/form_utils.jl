using AwkwardArray

is_iterable(obj) = try
    iterate(obj) !== nothing
catch
    false
end

# Function to check if a type is iterable
function is_iterable_type(T::Type)
    try
        iterate(T())
        return true
    catch
        return false
    end
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

function type_to_form(::Type{T}, form_key_id::Int64) where {T}
    # Helper function to generate the form key string
    function generate_form_key!(form_key_id_ref)
        form_key = "node" * string(form_key_id_ref[])
        form_key_id_ref[] += 1
        return form_key
    end

    # Initialize form_key_id reference for mutability
    form_key_id_ref = Ref(form_key_id)

    form_key = generate_form_key!(form_key_id_ref)

    if T <: Union{Int, Float64, Bool}
        parameters = string(T, "\", ")
        if T == Char
            parameters = "uint8\", \"parameters\": { \"__array__\": \"char\" }, "
        end
        return "{\"class\": \"NumpyArray\", \"primitive\": \"" * parameters *
               "\"form_key\": \"" * form_key * "\"}"
    elseif T <: Complex
        return "{\"class\": \"NumpyArray\", \"primitive\": \"" * string(T) *
               "\", \"form_key\": \"" * form_key * "\"}"
    end

    # Check if the type T is iterable
    if is_iterable_type(T)
        parameters = ""
        
        # Get the value type of the iterable T
        value_type = eltype(T)
        
        if value_type == Char
            parameters = " \"parameters\": { \"__array__\": \"string\" }, "
        end
        
        form_key = "node$(form_key_id)"
        
        offsets = "offsets_placeholder" # Replace this with the actual logic to get offsets
        
        content = type_to_form(value_type, form_key_id + 1) # Recursive call for value_type
        
        return "{\"class\": \"ListOffsetArray\", \"offsets\": \"$offsets\", \"content\": $content, $parameters \"form_key\": \"$form_key\"}"
    else
        error("Type not supported")
    end
    
    error("Type not supported")
end

function type_to_form(::Type{T}) where T <: Union{Int, Float64, String, Bool}
    return AwkwardArray.check_primitive_type(T)
end

function type_to_form(::Type{Vector{T}}) where T
    return Vector{type_to_form(T)}
end

function type_to_form(::Type{SubArray{T, N, A, I, L}}) where {T, N, A, I, L}
    return SubArray{type_to_form(T), N, type_to_form(A), I, L}
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