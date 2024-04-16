using GLMakie

function read_pushups()
    drinks::Vector{String} = []
    pushups::Vector{String} = []

    f = open("pushups.txt", "r")
    while !eof(f)
        s = readline(f)
        if (s[1] == "+") push!(drinks, s) end
        if (s[1] == "-") push!(pushups, s) end
    end
    close(f)
end