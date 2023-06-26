#!/usr/bin/env sh

# Notes:
# - There is a single input argument for the path to the CSV file.

# Pre-requisites:
# - foundry (https://getfoundry.sh)

# Strict mode: https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -euo pipefail

# Load the arguments while using default values
file=${1:-"in-csv/transition-merkle-data.csv"}

# Reformat the CSV file into a format that can be passed to the Forge script
temp_file=$(mktemp)
{ cat "$file"; echo; } | tail -n +2 | {
  arg_bots_ids="["
  arg_sheet_ids="["
  first_iteration=1
  while IFS="," read -r column1_cell column2_cell
  do
    if [ -n "$column1_cell" ] && [ -n "$column2_cell" ]; then
      if [ "$first_iteration" -eq 1 ]; then
        arg_bots_ids+="${column1_cell}"
        arg_sheet_ids+="${column2_cell}"
        first_iteration=0
      else
        arg_bots_ids+=",${column1_cell}"
        arg_sheet_ids+=",${column2_cell}"
      fi
    fi
  done
  arg_bots_ids+="]"
  arg_sheet_ids+="]"
  echo "$arg_bots_ids" > $temp_file
  echo "$arg_sheet_ids" >> $temp_file
}
arg_bots_ids=$(cat $temp_file | head -n 1)
arg_sheet_ids=$(cat $temp_file | head -n 2 | tail -n 1)
rm $temp_file

# Run the Forge script and extract the Merkle proofs from stdout
output=$(forge script scripts/generate/TransitionMerkleTree.s.sol \
  --sig "run(uint256[],uint256[])" \
  "$arg_bots_ids" \
  "$arg_sheet_ids")

# Extract the Merkle root from stdout
root=$(echo "$output" | awk -F "root: bytes32 " '{print $2}' | awk 'NF > 0')

# Reformat the Merkle proofs into JSON format and write to a file
index=0
temp_file=$(mktemp)
first_iteration=1
echo "$output" | awk -F "proofs: string[[]] " '{print $2}' | awk 'NF > 0' | jq -c ".[]" | while read line; do
    bots_id=$(echo $arg_bots_ids | jq -c ".[${index}]")
    sheet_id=$(echo $arg_sheet_ids | jq -c ".[${index}]")
    element="{\"bots_id\":$bots_id,\"sheet_id\":$sheet_id,\"merkleProof\":$line}"
    if [ "$first_iteration" -eq 1 ]; then
      echo "$element" >> $temp_file
      first_iteration=0
    else
      echo ",$element" >> $temp_file
    fi
    index=$((index+1))
done
mkdir -p "out-json"
echo "{\"tree\":[$(cat $temp_file)],\"root\":\"$root\"}" > "out-json/transition-merkle-tree.json"
rm $temp_file
