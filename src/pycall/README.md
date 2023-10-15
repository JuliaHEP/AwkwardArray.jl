[PyCall](https://github.com/JuliaPy/PyCall.jl) is currently configured to use the Julia-specific Python distribution
installed by the [Conda.jl](https://github.com/JuliaPy/Conda.jl) package.

  conda create --name ak-julia
  conda activate ak-julia
  conda install -c conda-forge awkward

```julia
using Conda
Conda.add("awkward")
```

```julia
using PyCall

@pyimport awkward

py"""
import awkward as ak
  def test():
    print(ak.__version__)
"""

py"test"()
2.4.6
```
