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
  out_allocatees="["
  first_iteration=1
  while IFS="," read -r column1_cell column2_cell
  do
    if [ -n "$column1_cell" ] && [ -n "$column2_cell" ]; then
      if [ "$first_iteration" -eq 1 ]; then
        arg_allocatees+="${column1_cell}"
        arg_allocations+="${column2_cell}"
        out_allocatees+="\"${column1_cell}\""
        first_iteration=0
      else
        arg_allocatees+=",${column1_cell}"
        arg_allocations+=",${column2_cell}"
        out_allocatees+=",\"${column1_cell}\""
      fi
    fi
  done
  arg_allocatees+="]"
  arg_allocations+="]"
  out_allocatees+="]"
  echo "$arg_allocatees" >> $temp_file
  echo "$arg_allocations" >> $temp_file
  echo "$out_allocatees" >> $temp_file
}
arg_allocatees=$(cat $temp_file | head -n 1)
arg_allocations=$(cat $temp_file | head -n 2 | tail -n 1)
out_allocatees=$(cat $temp_file | head -n 3 | tail -n 1)
rm $temp_file

# Run the Forge script and extract the Merkle proofs from stdout
output=$(forge script scripts/generate/AllocationMerkleTree.s.sol \
  --sig "run(address[],uint256[])" \
  "$arg_allocatees" \
  "$arg_allocations")

# Reformat the Merkle proofs into JSON format and write to a file
index=0
temp_file=$(mktemp)
first_iteration=1
echo "$output" | awk -F "proofs: string[[]] " '{print $2}' | awk 'NF > 0' | jq -c ".[]" | while read line; do
    allocatee=$(echo $out_allocatees | jq -c ".[${index}]")
    allocation=$(echo $arg_allocations | jq -c ".[${index}]")
    element="{$allocatee:{\"allocation\":$allocation,\"merkleProof\":$line}}"
    if [ "$first_iteration" -eq 1 ]; then
      echo "$element" >> $temp_file
      first_iteration=0
    else
      echo ",$element" >> $temp_file
    fi
    index=$((index+1))
done
mkdir -p "out-json"
echo "[$(cat $temp_file)]" > "out-json/allocation-merkle-tree.json"
rm $temp_file
