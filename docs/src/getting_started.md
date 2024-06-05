# Getting started

Let's assume that both Python and Julia are installed.

## Installation

It is recommended to use [conda](https://conda.io/projects/conda/en/latest/user-guide/getting-started.html) virtul environment.

!!! note
    If Julia is not install it is recomended to install it from a conda-forge channel:

    ```python
    conda install -c conda-forge julia
    ```

## Using Julia Awkward Arrays from Python

 - To install [Awkward Array](https://github.com/scikit-hep/awkward) Python package:

```python
conda install -c conda-forge awkward
```
 - To install [JuliaCall](https://juliapy.github.io/PythonCall.jl):

```python
conda install pyjuliacall
```
JuliaCall takes care of installing all necessary Julia packages, including this package. 

```python
import awkward as ak
from juliacall import Main as jl

jl.seval("using AwkwardArray")
```

## Using Python Awkward Arrays from Julia

[PythonCall](https://github.com/JuliaPy/PythonCall.jl) is currently configured to use the Julia-specific Python distribution
installed by the [CondaPkg.jl](https://github.com/JuliaPy/CondaPkg.jl) package.

```julia
using CondaPkg
CondaPkg.add("awkward")
```

```julia
using PythonCall

const ak = pyimport("awkward")

println(ak.__version__)
2.6.4
```

See [Examples](@ref).
