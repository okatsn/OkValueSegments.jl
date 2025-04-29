"""
    csegid(v::AbstractVector) -> Vector{Int}

Labels contiguous runs of identical values in a vector `v`.

Each time the value changes compared to the previous element in `v`,
the segment ID increments. The first segment always has ID 1.

This function handles any element type that supports the `!=` comparison.

# Arguments
- `v`: An AbstractVector containing the sequence of values.

# Returns
- `Vector{Int}`: A vector of the same length as `v`, containing the segment IDs.
                 Returns an empty vector if `v` is empty.

# Examples
```jldoctest
julia> using OkValueSegments

julia> csegid([1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0])
14-element Vector{Int64}:
 1
 2
 2
 2
 3
 3
 3
 3
 3
 4
 4
 4
 4
 4

julia> csegid([:a, :a, :b, :b, :a, :c])
6-element Vector{Int64}:
 1
 1
 2
 2
 3
 4
```


Noted that `NaN`s are considered as different values:

```jldoctest
julia> csegid([1.0, NaN, NaN, 2.0]) == [1, 2, 3, 4]
true
```
"""
function csegid(v::AbstractVector)
    n = length(v)
    n == 0 && return Int[]

    # Preallocate result vector directly
    result = Vector{Int}(undef, n)
    result[1] = 1  # First segment is always 1

    # Fill in segment IDs in a single pass
    current_id = 1
    for i in 2:n
        if v[i] != v[i-1]
            current_id += 1
        end
        result[i] = current_id
    end

    return result
end

function csegid(v::Vector{Bool})
    n = length(v)
    n == 0 && return Int[]

    result = Vector{Int}(undef, n)
    result[1] = 1  # First segment is always 1

    current_id = 1
    current_state = v[1]

    @inbounds for i in 2:n
        if v[i] != current_state
            current_id += 1
            current_state = v[i]
        end
        result[i] = current_id
    end

    return result
end


function _csegid_old(v::AbstractVector)
    n = length(v)
    if n == 0
        return Int[]
    end

    # Initialize change indicators (1 if different from previous, 0 otherwise)
    # The first element always starts segment 1, so its "change" indicator is 0.
    # Using Int explicitly for type stability with cumsum.
    changes = Vector{Int}(undef, n)
    changes[1] = 0
    for i in 2:n
        # Check for inequality. Handles most standard types.
        # Use `isequal` if strict NaN/missing handling is needed later.
        changes[i] = (v[i] != v[i-1]) ? 1 : 0
    end

    # Cumulative sum generates the segment index (0-based), add 1 for 1-based ID
    segment_ids = cumsum(changes) .+ 1

    return segment_ids

end

# *Note: The loop-based comparison (`v[i] != v[i-1]`) is more robust than the `diff`-based oneas it works for any type supporting `!=` (like Symbols, Strings) without relying on subtraction semantics.*
