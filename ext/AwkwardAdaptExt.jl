module AwkwardAdaptExt

import Adapt
import AwkwardArray as ak

function Adapt.adapt_structure(to, x::ak.PrimitiveArray{I, T, B}) where {I, T, B}
    ak.PrimitiveArray(Adapt.adapt(to, x.data); x.parameters, behavior = B)
end

function Adapt.adapt_structure(to, x::ak.ListOffsetArray{I, T, B}) where {I, T, B}
    new_offsets = Adapt.adapt(to, x.offsets)
    new_content = Adapt.adapt(to, x.content)
    ak.ListOffsetArray(new_offsets, new_content; x.parameters, behavior = B)
end

end
