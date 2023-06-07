#!/usr/bin/env sh

# Notes:
# - There is a single input argument for the path to the CSV file.

# Pre-requisites:
# - foundry (https://getfoundry.sh)

# Strict mode: https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -euo pipefail

# Load the arguments while using default values
file=${1:-"in-csv/allocation-merkle-data.csv"}

# Reformat the CSV file into a format that can be passed to the Forge script
temp_file=$(mktemp)
{ cat "$file"; echo; } | tail -n +2 | {
  arg_allocatees="["
  arg_allocations="["
  first_iteration=1
  while IFS="," read -r column1_cell column2_cell
  do
    if [ -n "$column1_cell" ] && [ -n "$column2_cell" ]; then
      if [ "$first_iteration" -eq 1 ]; then
        arg_allocatees+="${column1_cell}"
        arg_allocations+="${column2_cell}"
        first_iteration=0
      else
        arg_allocatees+=",${column1_cell}"
        arg_allocations+=",${column2_cell}"
      fi
    fi
  done
  arg_allocatees+="]"
  arg_allocations+="]"
  echo "$arg_allocatees" > $temp_file
  echo "$arg_allocations" >> $temp_file
}
arg_allocatees=$(cat $temp_file | head -n 1)
arg_allocations=$(cat $temp_file | head -n 2 | tail -n 1)
rm $temp_file

# Run the Forge script and extract the SVG from stdout
forge script script/generate/AllocationMerkleTree.s.sol \
  --sig "run(address[],uint256[])" \
  "$arg_allocatees" \
  "$arg_allocations"
