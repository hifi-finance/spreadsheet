#!/usr/bin/env sh

# Draws a progress bar in the terminal using the given current and total progress.
draw_progress_bar() {
  local current_progress=$1
  local total_progress=$2
  local percentage=$((current_progress * 100 / total_progress))
  local progress_char_width=$((percentage / 2))  # half of 100
  local rest_char_width=$((50 - progress_char_width))
  local filled_part=$(printf "%${progress_char_width}s" "")
  local empty_part=$(printf "%${rest_char_width}s" "")
  filled_part=${filled_part// /#}
  empty_part=${empty_part// /-}
  printf "\rProgress: [%s%s] %d%%" "$filled_part" "$empty_part" "$percentage"
}

# Pads a hex string that starts with 0x with zeroes to make it 64 characters long.
pad_hex() {
  local hex=$1
  hex=${hex#0x}
  local zeroes_to_pad=$((64 - ${#hex}))
  local padded_hex="0x$hex"
  if [ "$zeroes_to_pad" -ne 0 ]; then
    padded_hex="0x$(printf "%0${zeroes_to_pad}d" 0)$hex"
  fi
  echo "$padded_hex"
}

# Pads the hex strings in a Merkle proof to make them 64 characters long.
pad_proof() {
  local proof=$1
  local padded_proof="["
  local proof_length=$(echo "$proof" | jq -c '. | length')
  for (( j=0; j<proof_length; j++ )) do
    local padded_hex=$(pad_hex $(echo "$proof" | jq -c ".[${j}]" | tr -d '"'))
    if [ "$j" -eq 0 ]; then
      padded_proof+="\"$padded_hex\""
    else
      padded_proof+=",\"$padded_hex\""
    fi
  done
  padded_proof+="]"
  echo "$padded_proof"
}
