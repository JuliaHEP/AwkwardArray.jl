module AwkwardArray

abstract type AwkwardContent end

struct PrimitiveArray{T} <: AwkwardContent
    data::AbstractArray{T, 1}
end

function Base.length(x::PrimitiveArray)
    Base.length(x.data)
end

end
