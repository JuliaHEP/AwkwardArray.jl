Tables.istable(::Type{RecordArray}) = true

Tables.columnaccess(::Type{RecordArray}) = true
Tables.columns(x::RecordArray) = x.contents
Tables.columnnames(x::RecordArray) = keys(x.contents)

Tables.schema(x::RecordArray) =
    Tables.Schema(Tables.columnnames(x), eltype.(values(Tables.columns(x))))

function from_table(input)
    sch = Tables.schema(input)
    NT = NamedTuple{sch.names,Base.Tuple{sch.types...}}
    AwkwardType = layout_for(NT)
    out = AwkwardType()

    for row in Tables.rows(input)
        push!(out, NT(row))
    end

    return out
end
