module AwkwardArray

import JSON
import Tables

include("./all_implementations.jl")
include("./tables.jl")

include("./AwkwardPythonCallExt.jl")
using .AwkwardPythonCallExt: convert

Base.eltype(::RecordArray{FIELDS,CONTENTS,BEHAVIOR}) where {FIELDS,CONTENTS,BEHAVIOR} = Record{FIELDS,CONTENTS,BEHAVIOR}
Base.eltype(::Record{FIELDS,CONTENTS,BEHAVIOR}) where {FIELDS,CONTENTS,BEHAVIOR} = CONTENTS
Base.eltype(::TupleArray{CONTENTS,BEHAVIOR}) where {CONTENTS,BEHAVIOR} = Tuple{CONTENTS}
Base.eltype(::IndexedArray{INDEX,CONTENT,BEHAVIOR}) where {INDEX,CONTENT,BEHAVIOR} = CONTENT
Base.eltype(::IndexedOptionArray{INDEX,CONTENT}) where {INDEX,CONTENT} = CONTENT
Base.eltype(::ByteMaskedArray{INDEX,CONTENT}) where {INDEX,CONTENT} = CONTENT
Base.eltype(::BitMaskedArray{CONTENT}) where {CONTENT} = CONTENT
Base.eltype(::UnmaskedArray{CONTENT}) where {CONTENT} = CONTENT
Base.eltype(::UnionArray{TAGS,INDEX,CONTENTS}) where {TAGS,INDEX,CONTENTS} = CONTENTS

end  # module AwkwardArray
