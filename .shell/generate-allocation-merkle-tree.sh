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

# Run the Forge script and extract the Merkle tree from stdout
temp_file=$(mktemp)
for (( i=0; i<$(wc -l <"$file"); i++ ))
do
  output=$(forge script scripts/generate/AllocationMerkleProof.s.sol \
    --sig "run(address[],uint256[],uint256)" \
    "$arg_allocatees" \
    "$arg_allocations" \
    "$i")
  proof=$(echo "$output" | awk -F "proof: string " '{print $2}' | awk 'NF > 0')
  allocatee=$(echo $out_allocatees | jq -c ".[${i}]")
  allocation=$(echo $arg_allocations | jq -c ".[${i}]")
  element="{\"allocatee\":$allocatee,\"allocation\":$allocation,\"merkleProof\":$proof}"
  if [ "$i" -eq 0 ]; then
    echo "$element" >> $temp_file
  else
    echo ",$element" >> $temp_file
  fi
done
output=$(forge script scripts/generate/AllocationMerkleRoot.s.sol \
  --sig "run(address[],uint256[])" \
  "$arg_allocatees" \
  "$arg_allocations")
root=$(echo "$output" | awk -F "root: bytes32 " '{print $2}' | awk 'NF > 0')
mkdir -p "out-json"
echo "{\"tree\":[$(cat $temp_file)],\"root\":\"$root\"}" > "out-json/allocation-merkle-tree.json"
rm $temp_file
