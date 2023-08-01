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

# Run the Forge script and extract the Merkle tree from stdout
temp_file=$(mktemp)
tree_length=$(wc -l <"$file" | awk '{print $1}')
for (( i=0; i<tree_length; i++ ))
do
  output=$(forge script scripts/generate/TransitionMerkleProof.s.sol \
    --sig "run(uint256[],uint256[],uint256)" \
    "$arg_bots_ids" \
    "$arg_sheet_ids" \
    "$i")
  proof=$(echo "$output" | awk -F "proof: string " '{print $2}' | awk 'NF > 0')
  padded_proof="["
  for (( j=0; j<$(echo "$proof" | jq -c '. | length'); j++ )) do
    hex=$(echo "$proof" | jq -c ".[${j}]" | tr -d '"')
    hex=${hex#0x}
    zeroes_to_pad=$((64 - ${#hex}))
    if [ "$zeroes_to_pad" -eq 0 ]; then
      padded_hex="0x$hex"
    else
      padded_hex="0x$(printf "%0${zeroes_to_pad}d" 0)$hex"
    fi
    if [ "$j" -eq 0 ]; then
      padded_proof+="\"$padded_hex\""
    else
      padded_proof+=",\"$padded_hex\""
    fi
  done
  padded_proof+="]"
  bots_id=$(echo $arg_bots_ids | jq -c ".[${i}]")
  sheet_id=$(echo $arg_sheet_ids | jq -c ".[${i}]")
  element="{\"bots_id\":$bots_id,\"sheet_id\":$sheet_id,\"merkleProof\":$padded_proof}"
  if [ "$i" -eq 0 ]; then
    echo "$element" >> $temp_file
  else
    echo ",$element" >> $temp_file
  fi
  echo "$((i+1)) of $tree_length"
done
output=$(forge script scripts/generate/TransitionMerkleRoot.s.sol \
  --sig "run(uint256[],uint256[])" \
  "$arg_bots_ids" \
  "$arg_sheet_ids")
root=$(echo "$output" | awk -F "root: bytes32 " '{print $2}' | awk 'NF > 0')
mkdir -p "out-json"
echo "{\"tree\":[$(cat $temp_file)],\"root\":\"$root\"}" > "out-json/transition-merkle-tree.json"
rm $temp_file
