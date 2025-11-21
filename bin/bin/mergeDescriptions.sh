#!/usr/bin/env bash
# merge_descriptions.sh — builds:
#   - description_writing.md (no lighting)
#   - description_images.md  (with lighting)
#   and minified variants:
#   - description_writing.min.md
#   - description_images.min.md
#
# macOS/Bash 3.2 compatible:
# - No associative arrays
# - No ${var^^} capitalization
# - Guard all expansions for set -u safety

set -euo pipefail

# Canonical order for the full (images) build
# ADDED: "camera" as the final section
ORDER=(basic_info morphology face accessories hair body wardrobe lighting camera)

# Derive the writing order by dropping "lighting" (and now "camera") to avoid drift
ORDER_WRITING=()
for x in "${ORDER[@]}"; do
	# MODIFIED: also skip "camera" for writing
	if [[ "$x" != "lighting" && "$x" != "camera" ]]; then
		ORDER_WRITING+=("$x")
	fi
done

# ---------- Helpers -----------------------------------------------------------

label_for() {
	case "${1:-}" in
	basic_info) echo "Basic Information" ;;
	morphology) echo "morphology" ;;
	face) echo "Face" ;;
	accessories) echo "Accessories & Makeup" ;;
	hair) echo "Hair" ;;
	body) echo "Body" ;;
	wardrobe) echo "Wardrobe" ;;
	lighting) echo "Lighting" ;;
	# ADDED: label for camera section
	camera) echo "Camera" ;;
	*) echo "${1:-Section}" ;;
	esac
}

toupper() {
	printf '%s' "${1:-}" | tr '[:lower:]' '[:upper:]'
}

extract_version() {
	local file="${1:-}"
	[[ -f "$file" ]] || {
		echo ""
		return 0
	}
	grep -oE 'v[0-9]+([.][0-9]+)*' "$file" | head -n 1 || true
}

src_for_part() {
	local part="${1:-}"
	if [[ "$part" = "basic_info" ]]; then
		printf '%s' "basic_info.md"
	# ADDED: camera resolution (local override > shared > default)
	elif [[ "$part" = "camera" ]]; then
		if [[ -f "description_camera.md" ]]; then
			printf '%s' "description_camera.md"
		elif [[ -f "../_shared/description_camera.md" ]]; then
			printf '%s' "../_shared/description_camera.md"
		else
			# Fallback path; render_section will skip if it doesn't exist
			printf '%s' "description_camera.md"
		fi
	else
		printf 'description_%s.md' "$part"
	fi
}

build_use_line() {
	local current="${1:-}"
	shift || true
	local out_kind="${1:-}"
	shift || true

	local items=()
	local pv part ver lbl
	for pv in "$@"; do
		[[ -n "${pv:-}" ]] || continue
		part="${pv%%:*}"
		ver="${pv#*:}"

		[[ "$part" = "$current" ]] && continue
		if [[ "$out_kind" = "writing" && "$part" = "lighting" ]]; then
			continue
		fi

		lbl="$(label_for "$part")"
		if [[ -n "${ver:-}" ]]; then
			items+=("${lbl} (${ver})")
		else
			items+=("${lbl} (v11.17+)")
		fi
	done

	((${#items[@]} > 0)) || {
		echo ""
		return 0
	}

	local use_text=""
	if ((${#items[@]} == 1)); then
		use_text="${items[0]}"
	else
		local last="${items[${#items[@]} - 1]}"
		# shellcheck disable=SC2206
		local lead=("${items[@]:0:${#items[@]}-1}")
		use_text="$(printf "%s, " "${lead[@]}")and ${last}"
	fi

	# echo "**Use:** Pair with the ${use_text} sections from this file."
}

render_section() {
	local out_file="${1:-}"
	shift || true
	local part="${1:-}"
	shift || true
	local out_kind="${1:-}"
	shift || true
	local src
	src="$(src_for_part "$part")"

	[[ -f "$src" ]] || return 0

	local use_line
	use_line="$(build_use_line "$part" "$out_kind" "$@")"

	local header
	header="$(toupper "$(label_for "$part")")"

	{
		printf "<!-- BEGIN %s -->\n\n" "$header"
		if [[ -n "${use_line:-}" ]]; then
			awk -v UL="$use_line" '
        BEGIN { replaced=0 }
        {
          if (!replaced && $0 ~ /^\*\*Use:\*\*/) {
            print UL
            replaced=1
          } else {
            print $0
          }
        }
        END {
          if (!replaced) {
            print ""
            print UL
          }
        }
      ' "$src"
		else
			cat "$src"
		fi
		printf "\n<!-- END %s -->\n\n" "$header"
	} >>"$out_file"

	echo "✓ Included $src"
}

merge_all() {
	local out_file="${1:-}"
	shift || true
	local out_kind="${1:-}"
	shift || true

	: >"$out_file"

	local p f v
	local part_versions=()
	for p in "$@"; do
		f="$(src_for_part "$p")"
		if [[ -f "$f" ]]; then
			v="$(extract_version "$f")"
			part_versions+=("${p}:${v}")
		fi
	done

	for p in "$@"; do
		render_section "$out_file" "$p" "$out_kind" "${part_versions[@]}"
	done

	echo "Merged → $out_file"
}

# ---------- Minifier ----------------------------------------------------------

# Minify Markdown into a compact prompt-safe form:
# - Remove HTML comments <!-- ... -->
# - Trim leading/trailing whitespace
# - Collapse internal runs of spaces/tabs to a single space
# - Drop empty lines
# - Preserve code blocks (``` ... ```)
minify_file() {
	local in="${1:-}"
	local out="${2:-}"
	awk '
BEGIN { in_code=0 }
/^```/ { print; in_code = !in_code; next }
{
  if (in_code) { print; next }

  # strip HTML comments (single-line)
  gsub(/<!--[^>]*-->/, "", $0)

  # capture leading indentation
  match($0, /^[ \t]*/)
  indent = substr($0, RSTART, RLENGTH)

  # work on the rest of the line as "line"
  line = $0
  sub(/^[ \t]*/, "", line)      # remove leading spaces from content
  sub(/[ \t]+$/, "", line)      # trim trailing spaces

  if (line == "") next          # drop empty lines after trimming

  gsub(/[ \t]+/, " ", line)     # collapse internal runs of spaces

  print indent line             # re-attach original indentation
}' "$in" >"$out"

	# report size savings
	if command -v wc >/dev/null 2>&1; then
		local a b
		a=$(wc -c <"$in" | tr -d '[:space:]')
		b=$(wc -c <"$out" | tr -d '[:space:]')
		printf "Minified %s → %s (bytes: %s → %s, saved: %s)\n" "$in" "$out" "$a" "$b" "$((a - b))"
	fi
}

# ---------- Builds ------------------------------------------------------------

echo "=== Building description_writing.md ==="
merge_all "description_writing.md" "writing" "${ORDER_WRITING[@]}"

echo "=== Building description_images.md ==="
merge_all "description_images.md" "images" "${ORDER[@]}"

echo "=== Minifying outputs ==="
minify_file "description_writing.md" "description_writing.min.md"
minify_file "description_images.md" "description_images.min.md"

echo "Done."
