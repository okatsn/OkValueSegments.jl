using Test       # Access @test, @testset

@testset "ValueSegments.jl - csegid" begin

    @testset "Basic Functionality" begin
        # Original example (numeric)
        @test csegid(
            [1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0]) ==
              [1, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4]
        # Boolean example
        @test csegid([true, true, false, false, true, false]) ==
              [1, 1, 2, 2, 3, 4]
        # String example
        @test csegid(["a", "a", "b", "c", "c", "c"]) == [1, 1, 2, 3, 3, 3]
        # Symbol example
        @test csegid([:a, :a, :b, :b, :a, :c]) == [1, 1, 2, 2, 3, 4]
        # Float example
        @test csegid([1.0, 1.0, 2.5, 2.5, 1.0]) == [1, 1, 2, 2, 3]
    end

    @testset "Edge Cases" begin
        # Empty vector
        @test csegid([]) == Int[]
        @test csegid(Float64[]) == Int[]
        @test csegid(String[]) == Int[]

        # Single element vector
        @test csegid([1]) == [1]
        @test csegid(["hello"]) == [1]
        @test csegid([false]) == [1]

        # All identical elements
        @test csegid([5, 5, 5, 5]) == [1, 1, 1, 1]
        @test csegid([true, true, true]) == [1, 1, 1]
        @test csegid(["x", "x"]) == [1, 1]
    end

    @testset "More Complex Patterns" begin
        # Alternating values
        @test csegid([1, 0, 1, 0, 1]) == [1, 2, 3, 4, 5]
        @test csegid([true, false, true, false]) == [1, 2, 3, 4]

        # Mixed run lengths
        @test csegid([1, 2, 2, 3, 3, 3, 4, 5, 5]) == [1, 2, 2, 3, 3, 3, 4, 5, 5]

        # Runs at beginning/end
        @test csegid([1, 1, 1, 2, 3, 3]) == [1, 1, 1, 2, 3, 3]
        @test csegid([1, 2, 2, 3, 3, 3]) == [1, 2, 2, 3, 3, 3]
    end

    # Note: Standard NaN handling: NaN != NaN is true.
    # csegid([1.0, NaN, NaN, 2.0]) would return [1, 2, 3, 4]
    # Note: Standard Missing handling: missing != missing is missing.
    # This function would error if `changes[i]` becomes missing.
    # Handling these cases robustly requires specific logic using isequal() or similar.
    @testset "Special Values (Not Fully Supported By Default)" begin
        # Demonstrating default NaN behavior
        @test csegid([1.0, NaN, NaN, 2.0]) == [1, 2, 3, 4]
        # Demonstrate missing would error
        @test_throws TypeError csegid([1, missing, missing, 2])
        # non-boolean (Missing) used in boolean context
        # Consider adding isequal logic if NaN/missing segments are needed
    end

end
