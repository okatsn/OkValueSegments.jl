using BenchmarkTools
using OkValueSegments

# Test cases
small_vec = rand(1:3, 1000)  # Small range, many repeated values
large_vec = rand(1:1000, 1000)  # Larger range, fewer repetitions
symbols_vec = [Symbol("sym_$(i÷10)") for i in 1:1000]  # Symbols with repetitions
nan_vec = [1.0, NaN, NaN, 2.0, NaN, 3.0, NaN, NaN]  # With NaN values
# Create a large random boolean vector
n = 1_000_000  # One million elements
bool_vec = rand(Bool, n)

# Test starts

open("benchmark_env/log.txt", "w") do file
    redirect_stdout(file) do

        println("Original implementation:")
        @btime OkValueSegments._csegid_old($small_vec)
        @btime OkValueSegments._csegid_old($large_vec)
        @btime OkValueSegments._csegid_old($symbols_vec)
        @btime OkValueSegments._csegid_old($nan_vec)

        println("\nOptimized implementation:")
        @btime csegid($small_vec)
        @btime csegid($large_vec)
        @btime csegid($symbols_vec)
        @btime csegid($nan_vec)

        # Verify correctness
        for test_vec in [small_vec, large_vec, symbols_vec, nan_vec]
            result_orig = OkValueSegments._csegid_old(test_vec)
            result_opt = csegid(test_vec)
            println("Results match: ", result_orig == result_opt)
        end

        # Specific cases
        println("Benchmarking with large Boolean vector (length = $n):")

        println("\nOriginal implementation (_csegid_old):")
        @btime OkValueSegments._csegid_old($bool_vec)

        println("\nCurrent implementation (csegid):")
        @btime csegid($bool_vec)

        # Verify correctness
        result_orig = OkValueSegments._csegid_old(bool_vec)
        result_opt = csegid(bool_vec)
        println("Results match: ", result_orig == result_opt)

        # Count segments to understand workload characteristics
        println("Number of segments: ", result_opt[end])

    end # captures printed information
end
