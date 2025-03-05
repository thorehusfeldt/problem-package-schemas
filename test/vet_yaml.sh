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
for filepath in ../yaml/invalid/*.yaml; do
    filename=$(basename "$filepath") # Extract filename from path

    # Extract the type (last part before .yaml)
    for key in "${!schemas[@]}"; do
        if [[ "$filename" == *"$key.yaml" ]]; then
	    echo "$filepath"
            if cue vet "$filepath" ../cue/*.cue --schema "#${schemas[$key]}" >/dev/null 2>&1 ; then
                echo "❌ Expected failure but got success for $filename"
                exit 1
            fi
            break
        fi
    done
done
