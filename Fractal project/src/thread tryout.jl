using PyPlot
using BenchmarkTools
using .Threads

function sum_single(a)
    s = 0
    for i in a
        s += i
    end
    s
end

function sum_multi_good(a)
    chunks = Iterators.partition(a, length(a) ÷ Threads.nthreads())
    tasks = map(chunks) do chunk
        Threads.@spawn sum_single(chunk)
    end
    chunk_sums = fetch.(tasks)
    return sum_single(chunk_sums)
end

@btime sum_single(1:1000)

@btime sum_multi_good(1:1000)