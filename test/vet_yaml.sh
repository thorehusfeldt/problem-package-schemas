#!/bin/bash

declare -A schemas=(
    ["problem"]="Problem"
    ["testdata"]="DataConfiguration"
    ["testcase"]="CaseConfiguration"
    ["generators"]="Generators"
)

# Valid cases (should pass)
for filepath in ../yaml/valid/*.yaml; do
    filename=$(basename "$filepath") # Extract filename from path

    # Extract the type (last part before .yaml)
    for key in "${!schemas[@]}"; do
        if [[ "$filename" == *"$key.yaml" ]]; then
	    echo "$filepath"
            cue vet "$filepath" ../cue/*.cue --schema "#${schemas[$key]}" >/dev/null 2>&1
        fi
    done
done

# Invalid cases (should fail)
# Iterate over YAML files in the invalid directory
for filepath in ../yaml/invalid/*.yaml; do
    filename=$(basename "$filepath") # Extract filename from path

    # Extract the type (last part before .yaml)
    for key in "${!schemas[@]}"; do
        if [[ "$filename" == *"$key.yaml" ]]; then
            echo "$filepath"

            # Create a temporary directory for this file
            tmpdir=$(mktemp -d)
            trap 'rm -rf "$tmpdir"' EXIT  # Cleanup on script exit

            # Split YAML using awk (works on macOS)
            count=0
            awk -v tmpdir="$tmpdir" '
                /^---$/ { close(f); count++; next }
                { f = sprintf("%s/snippet_%03d.yaml", tmpdir, count); print > f }
            ' "$filepath"

            # Validate each snippet
            for snippet in "$tmpdir"/*.yaml; do
                if cue vet "$snippet" ../cue/*.cue --schema "#${schemas[$key]}" >/dev/null 2>&1; then
                    echo "❌ Expected failure but got success for $snippet"
                    exit 1
                fi
            done

            # Cleanup before next iteration
            rm -rf "$tmpdir"

            break
        fi
    done
done
