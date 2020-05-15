# STAMP.jl

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)

> This project follows the [semver](http://semver.org) pro forma and uses the [git-flow branching model](https://nvie.com/posts/a-successful-git-branching-model/ "original blog post").

## Description
Initially written to load [GEM](http://groups.csail.mit.edu/cgs/gem/)'s default PFM output.

Inspired by [FASTX.jl](https://github.com/BioJulia/FASTX.jl).

## Installation
Install STAMP from the Julia REPL:
```julia
] clone https://github.com/CiaranOMara/STAMP.jl
```

## Usage

### Read records

```julia
using STAMP

reader = open(STAMP.Reader, file)
record = read(reader) #TODO: read all records.
```

```julia
using STAMP

reader = open(STAMP.Reader, file)
for record in reader
    # Do something
end
close(reader)

```

```julia
using STAMP

reader = open(STAMP.Reader, file)
record = STAMP.Record()
read!(reader, record))
# Do something
close(reader)
```

```julia
using STAMP

open(STAMP.Reader, file) do reader
    for record in reader
        # Do something
    end
end
```
