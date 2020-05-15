const machine = (function ()

    re = Automa.RegExp

    cat = Automa.RegExp.cat
    rep = Automa.RegExp.rep
    rep1 = Automa.RegExp.rep1
    opt = Automa.RegExp.opt

    newline = let
        lf = re"\n"
        lf.actions[:enter] = [:countline]

        cat(opt('\r'), lf)
    end

    record = let
        space = re"[\t ]+"

        header = let
            h1 = re"[A-Za-z0-9_\-]*"
            # h1 = re"[!-~]*"
            h2 = re"[0-9\.]*"
            h3 = cat(opt("-"),re"[0-9]*")
            h4 = re"[A-Za-z0-9_\-]*"
            # h4 = re"[!-~]*"

            cat(h1, space, h2,space, h3, space, h4)
        end
        header.actions[:enter] = [:mark]
        header.actions[:exit] = [:record_header]

        pfm = let
            position = re"[0-9]*"
            position.actions[:enter] = [:record_pfm_position]

            frequency = re"[0-9]*"
            frequency.actions[:enter] = [:mark]
            frequency.actions[:exit] = [:record_pfm_frequency]

            nucleotide = re"[ACGT]"
            nucleotide.actions[:enter] = [:mark]
            nucleotide.actions[:exit] = [:record_pfm_nucleotide]

            rep1(cat(position, space, frequency, space, frequency, space, frequency, space, frequency, space, nucleotide, newline))
        end

        cat("DE", space, header, newline, pfm, "XX", newline)
    end
    record.actions[:exit] = [:record]

    stamp = rep(cat(record, rep(newline)))

    Automa.compile(stamp)
end)()


const actions = Dict(
    :mark => :(@mark),
    :countline => :(linenum += 1),

    :record_header => quote
            str = String(data[@markpos():p - 1])
            record.header = str
            @debug "header" str
        end,
    :record_pfm_position => quote
            posnum += 1
            @debug posnum
        end,
    :record_pfm_frequency => quote
            str = String(data[@markpos():p - 1])
            push!(frequencies, parse(Int64, str))
            @debug "frequency" str
        end,
    :record_pfm_nucleotide => quote
            str = String(data[@markpos():p - 1])
            sequence = sequence * LongDNASeq(str)
            @debug "nucleotide" str
        end,
    :record => quote
            record.frequencies = reshape(frequencies, 4, :)
            record.sequence = sequence
            found = true
            @escape
        end
    )


initcode = quote

    found = false

    posnum = 0
    frequencies = Int64[]
    sequence = LongDNASeq()

    initialize!(record)

    cs, linenum = state
end

loopcode = quote

    if cs < 0
        throw(ArgumentError("malformed file at line $(linenum)"))
    end
    found && @goto __return__
end

returncode = :(return cs, linenum, found)

context = Automa.CodeGenContext(generator = :goto, checkbounds = false, loopunroll = 8)

Automa.Stream.generate_reader(
    :readrecord!,
    machine,
    arguments = (:(record::Record), :(state::Tuple{Int,Int})),
    actions = actions,
    context = context,
    initcode = initcode,
    loopcode = loopcode,
    returncode = returncode
) |> eval
