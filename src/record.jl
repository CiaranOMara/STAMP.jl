mutable struct Record{S<:BioSequence}
    header::Union{Missing, String}
    frequencies::Union{Missing, AbstractMatrix}
    sequence::Union{Missing, S}
end

function Record{S}() where S<:BioSequence
    return Record{S}(missing, missing, missing)
end

function Record()
    return Record{LongDNASeq}()
end

function Record{S}(data::Vector{UInt8}) where S<:BioSequence
    return convert(Record{S}, data)
end

function Record(data::Vector{UInt8})
    return Record{LongDNASeq}(data)
end

function Base.convert(el::Type{R}, data::Vector{UInt8}) where R<:Record
    record = el()
    stream = TranscodingStreams.NoopStream(IOBuffer(data))
    cs, linenum, found = readrecord!(stream, record, (1, 1))
    if !found || !allspace(stream)
        throw(ArgumentError("invalid record"))
    end
    return record
end

function Record(str::AbstractString)
    return Record(Vector{UInt8}(str))
end

function Base.convert(::Type{Record}, str::AbstractString)
    return Record(Vector{UInt8}(str))
end

function Base.copy(record::Record)
    return Record(
        record.header,
        record.frequencies,
        record.sequence
        )
end

function Base.show(io::IO, record::Record)
    print(io, summary(record), ':')
    if isfilled(record)
        println(io)
        println(io, "      header: ", header(record))
        println(io, " frequencies: ", frequencies(record))
        println(io, "    sequence: ", sequence(record))
    else
        println(io, " <not filled>")
    end
end

function empty!(record::Record)
    record.header = missing
    record.frequencies = missing
    record.sequence = missing
    return record
end

function header(record::Record)
    return record.header
end

function frequencies(record::Record)
    return record.frequencies
end

function sequence(record::Record)
    return record.sequence
end

function BioGenerics.isfilled(record::Record)
    return !ismissing(record.header) || !ismissing(record.frequencies) || !ismissing(record.sequence)
end

function hasmissing(record::Record)
    return ismissing(record.header) || ismissing(record.frequencies) || ismissing(record.sequence)
end
