[PythonCall](https://github.com/JuliaPy/PythonCall.jl) is currently configured to use the Julia-specific Python distribution
installed by the [CondaPkg.jl](https://github.com/JuliaPy/CondaPkg.jl) package.

```julia
using CondaPkg
CondaPkg.add("numpy")
CondaPkg.add("awkward")
```

```julia
using PythonCall

const ak = pyimport("awkward")

println(ak.__version__)
2.5.0
```
