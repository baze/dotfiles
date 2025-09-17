#!/usr/bin/env bash
# merge_descriptions.sh — builds:
#   - description_writing.md (no lighting)
#   - description_images.md  (with lighting)

set -euo pipefail

ORDER=(face body wardrobe hair lighting)

merge_all() {
  local out="$1"; shift
  local parts=("$@")

  : > "$out"
  for part in "${parts[@]}"; do
    local f="description_${part}.md"
    if [[ -f "$f" ]]; then
      header="$(printf '%s' "$part" | tr '[:lower:]' '[:upper:]')"
      printf "<!-- BEGIN %s -->\n\n" "$header" >> "$out"
      cat "$f" >> "$out"
      printf "\n\n" >> "$out"
    fi
  done
  echo "Merged → $out"
}

# 1) Writing: no lighting
merge_all "description_writing.md" face body wardrobe hair

# 2) Images: include lighting
merge_all "description_images.md" "${ORDER[@]}"
