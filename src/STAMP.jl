module STAMP

import Automa
import Automa.RegExp: @re_str
import Automa.Stream: @mark, @markpos, @relpos, @abspos
import BioGenerics: BioGenerics, isfilled
# import BioGenerics.Exceptions: missingerror
import BioGenerics.Automa: State
using BioSequences
import TranscodingStreams: TranscodingStreams, TranscodingStream

include("record.jl")
include("readrecord.jl")
include("reader.jl")

end # module
