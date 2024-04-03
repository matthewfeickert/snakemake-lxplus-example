#!/usr/bin/env bash

# c.f. https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#bash

output_dir="${snakemake_params[0]:-results}"

if [ ! -d "${output_dir}" ]; then
    mkdir -p "${output_dir}"
fi

sort "${snakemake_input[0]}" > "${snakemake_output[0]}"
