module AwkwardArray

import JSON
import Tables

include("./all_implementations.jl")
include("./tables.jl")

include("./AwkwardPythonCallExt.jl")
using .AwkwardPythonCallExt: convert


end  # module AwkwardArray
