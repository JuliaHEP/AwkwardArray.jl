module AwkwardArray

import JSON
import Tables

include("./all_implementations.jl")
include("./tables.jl")

include("./AwkwardPythonCallExt.jl")
using .AwkwardPythonCallExt: convert

Base.eltype(::RecordArray{FIELDS,CONTENTS,BEHAVIOR}) where {FIELDS,CONTENTS,BEHAVIOR} = Record{FIELDS,CONTENTS,BEHAVIOR}
Base.eltype(::Record{FIELDS,CONTENTS,BEHAVIOR}) where {FIELDS,CONTENTS,BEHAVIOR} = CONTENTS
Base.eltype(::TupleArray{CONTENTS,BEHAVIOR}) where {CONTENTS,BEHAVIOR} = SlotRecord{CONTENTS,BEHAVIOR}

end  # module AwkwardArray
