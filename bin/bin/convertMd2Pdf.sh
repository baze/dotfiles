#!/bin/zsh
# Markdown -> PDF converter with optional remote image downloading
# macOS / zsh / pandoc / weasyprint

set -euo pipefail
IFS=$'\n'
setopt null_glob

# ------------------------------------------------------------------------------
# Defaults
# ------------------------------------------------------------------------------
DOWNLOAD_IMAGES=0
DEBUG=0
CONTINUE_ON_ERROR=0
REFERER="https://chat.openai.com"
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36"
COOKIE_HEADER="${COOKIE:-}"

# ------------------------------------------------------------------------------
# Environment
# ------------------------------------------------------------------------------
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

LOG="$HOME/Library/Logs/Shortcuts/convert_md_to_pdf.log"
exec > >(tee -a "$LOG") 2>&1

echo "---- $(date) ----"
echo "Args: $@"

# ------------------------------------------------------------------------------
# Help
# ------------------------------------------------------------------------------
usage() {
  cat <<'EOF'
Usage:
  convert_md_to_pdf.zsh [options] [file1.md file2.md ...]

Behavior:
  - If no files are given, all .md files in the current directory are processed.
  - By default, the script converts Markdown to PDF only.
  - Use --download-images to fetch remote images before conversion.

Options:
  --download-images     Download remote images and rewrite links to local copies
  --debug               Keep temp workdirs and enable verbose curl tracing
  --continue-on-error   Keep processing other files/images after errors
  --help                Show this help text

Environment variables:
  COOKIE='k=v; k2=v2'   Optional Cookie header for curl requests

Examples:
  ./convert_md_to_pdf.zsh
  ./convert_md_to_pdf.zsh notes.md
  ./convert_md_to_pdf.zsh a.md b.md
  ./convert_md_to_pdf.zsh --download-images notes.md
  ./convert_md_to_pdf.zsh --download-images --debug --continue-on-error
EOF
}

# ------------------------------------------------------------------------------
# Parse CLI args
# ------------------------------------------------------------------------------
typeset -a positional
while (( $# > 0 )); do
  case "$1" in
    --download-images)
      DOWNLOAD_IMAGES=1
      ;;
    --debug)
      DEBUG=1
      ;;
    --continue-on-error)
      CONTINUE_ON_ERROR=1
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    --)
      shift
      positional+=("$@")
      break
      ;;
    -*)
      echo "ERROR: Unknown option: $1"
      echo ""
      usage
      exit 2
      ;;
    *)
      positional+=("$1")
      ;;
  esac
  shift
done
set -- "${positional[@]}"

echo "DOWNLOAD_IMAGES=$DOWNLOAD_IMAGES  DEBUG=$DEBUG  CONTINUE_ON_ERROR=$CONTINUE_ON_ERROR"

# ------------------------------------------------------------------------------
# Preconditions
# ------------------------------------------------------------------------------
command -v pandoc >/dev/null || { echo "ERROR: pandoc not found"; exit 127; }
command -v weasyprint >/dev/null || { echo "ERROR: weasyprint not found"; exit 127; }
command -v shasum >/dev/null || { echo "ERROR: shasum not found"; exit 127; }
command -v python3 >/dev/null || { echo "ERROR: python3 not found"; exit 127; }

# ------------------------------------------------------------------------------
# Inputs
# ------------------------------------------------------------------------------
typeset -a files
if (( $# == 0 )); then
  files=( ./*.md )
  (( ${#files[@]} == 0 )) && { echo "No .md files found."; exit 0; }
else
  files=( "$@" )
fi

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------
hash_of() {
  local url="$1"
  local base ext digest
  base="$(echo "$url" | sed 's/[?#].*$//' | awk -F/ '{print $NF}')"
  ext="${base##*.}"
  [[ "$ext" = "$base" || -z "$ext" ]] && ext="bin"
  digest="$(printf "%s" "$url" | shasum -a 256 | awk '{print $1}')"
  echo "${digest}.${ext}"
}

url_decode() {
  python3 - <<'PY' "$1"
import sys, urllib.parse
print(urllib.parse.unquote(sys.argv[1]))
PY
}

sas_info() {
  local url="$1"
  if [[ "$url" == *"sig="* && "$url" == *"se="* ]]; then
    local se_raw="${url##*se=}"
    se_raw="${se_raw%%&*}"
    local se="$(url_decode "$se_raw")"
    echo "Detected Azure SAS URL with expiry (se): $se (UTC)"
    date -j -f "%Y-%m-%dT%H:%M:%SZ" "$se" "+Local expiry: %Y-%m-%d %H:%M:%S %Z" 2>/dev/null || true
  fi
}

typeset -a failures

die_or_collect() {
  local msg="$1"
  local wd="${2:-}"

  echo ""
  echo "✖ ERROR: $msg"
  [[ -n "$wd" ]] && echo "    Debug artifacts: $wd"

  if (( CONTINUE_ON_ERROR > 0 )); then
    failures+=("$msg${wd:+ (artifacts: $wd)}")
    return 1
  else
    exit 1
  fi
}

fetch_with_debug() {
  local url="$1"
  local dest="$2"
  local wd="$3"

  sas_info "$url"

  local hdrs="$wd/headers.$(basename "$dest").txt"
  local trace="$wd/curl_trace.$(basename "$dest").log"
  local info="$wd/fetch_info.$(basename "$dest").txt"

  local -a curl_cmd
  curl_cmd=(
    curl
    -L
    --fail
    --connect-timeout 15
    --max-time 90
    -A "$UA"
    -H "Referer: $REFERER"
    -D "$hdrs"
    --output "$dest"
    --write-out "http_code=%{http_code}\ncontent_type=%{content_type}\nurl_effective=%{url_effective}\nredirect_url=%{redirect_url}\n"
  )

  [[ -n "$COOKIE_HEADER" ]] && curl_cmd+=(-H "Cookie: $COOKIE_HEADER")
  (( DEBUG > 0 )) && curl_cmd+=(--trace-ascii "$trace" --verbose)

  curl_cmd+=("$url")

  echo "Fetching: $url"

  local summary=""
  if ! summary="$("${curl_cmd[@]}" 2>>"$trace")"; then
    echo "$summary" > "$info" || true
    echo "HTTP headers (last hop):"
    tail -n +1 "$hdrs" 2>/dev/null || true
    (( DEBUG == 0 )) && echo "(Tip: use --debug to keep curl traces)"
    die_or_collect "curl failed to fetch image: $url" "$wd" || return 1
    return 1
  fi

  echo "$summary" > "$info"

  local code ctype effective
  code="$(grep -Eo '^http_code=[0-9]+' "$info" | cut -d= -f2)"
  ctype="$(grep -Eo '^content_type=.*' "$info" | cut -d= -f2)"
  effective="$(grep -Eo '^url_effective=.*' "$info" | cut -d= -f2)"

  echo "→ HTTP $code  type=${ctype:-unknown}  effective=${effective:-n/a}"

  if [[ "$code" != "200" && "$code" != "206" ]]; then
    echo "HTTP headers (last hop):"
    tail -n +1 "$hdrs" 2>/dev/null || true
    case "$code" in
      401|403) echo "Auth/permission error. If this is an expiring SAS link, it may be past 'se='." ;;
      404)     echo "Not found. The link may be expired or rotated." ;;
      429)     echo "Rate limited. Retry later." ;;
      5*)      echo "Server error. Might be transient." ;;
    esac
    die_or_collect "Non-OK status ($code) for $url" "$wd" || return 1
    return 1
  fi

  [[ -s "$dest" ]] || {
    die_or_collect "Downloaded file is empty for $url" "$wd" || return 1
    return 1
  }
}

collect_remote_urls() {
  local md_file="$1"
  local -a urls

  urls=($(grep -oE '!\[[^]]*\]\((https?[^)[:space:]]+)' "$md_file" | sed -E 's/^!\[[^]]*\]\(//')) || true
  urls+=($(grep -oE '<img[^>]*src="https?[^"]+"' "$md_file" | sed -E 's/^.*src="([^"]+)".*$/\1/')) || true

  if (( ${#urls[@]} )); then
    printf "%s\n" "${urls[@]}" | awk '!seen[$0]++'
  fi
}

rewrite_url_to_local() {
  local tmp_md="$1"
  local original_url="$2"
  local local_path="$3"

  local esc_u esc_p
  esc_u="$(printf '%s' "$original_url" | sed 's/[\/&]/\\&/g')"
  esc_p="$(printf '%s' "$local_path" | sed 's/[\/&]/\\&/g')"

  sed -i '' -E "s#(!\[[^]]*\]\()$esc_u(\))#\1$esc_p\2#g" "$tmp_md"
  sed -i '' -E "s#(src=\")$esc_u(\")#\1$esc_p\2#g" "$tmp_md"
}

process_one() {
  local f="$1"
  [[ "${f:l}" != *.md ]] && { echo "Skipping non-md: $f"; return 0; }
  [[ -f "$f" ]] || { die_or_collect "File not found: $f" "" || return 1; return 1; }

  echo "Processing: $f"

  local out_pdf="${f%.*}.pdf"
  local workdir tmp_md imgdir
  workdir="$(mktemp -d)"
  tmp_md="$workdir/$(basename "$f")"
  imgdir="$workdir/images"

  mkdir -p "$imgdir"
  cp "$f" "$tmp_md"

  local had_error=0

  if (( DOWNLOAD_IMAGES == 1 )); then
    echo "Image downloading ENABLED"

    local -a urls
    urls=($(collect_remote_urls "$tmp_md")) || true

    if (( ${#urls[@]} )); then
      echo "Found ${#urls[@]} remote image URL(s)"
    else
      echo "No remote images detected."
    fi

    local u fn dest
    for u in "${urls[@]}"; do
      [[ "$u" =~ ^https?:// ]] || { echo "Skipping non-http URL: $u"; continue; }

      fn="$(hash_of "$u")"
      dest="$imgdir/$fn"

      if [[ -f "$dest" ]]; then
        echo "Already downloaded: $u"
      else
        if ! fetch_with_debug "$u" "$dest" "$workdir"; then
          had_error=1
          (( CONTINUE_ON_ERROR == 0 )) && return 1
          continue
        fi
      fi

      rewrite_url_to_local "$tmp_md" "$u" "images/$fn"
    done

    if (( had_error && CONTINUE_ON_ERROR == 1 )); then
      echo "Proceeding to PDF despite image fetch errors…"
    fi
  else
    echo "Image downloading DISABLED"
  fi

  echo "Converting to PDF: $out_pdf"
  if ! pandoc "$tmp_md" --standalone -o "$out_pdf" --pdf-engine=/opt/homebrew/bin/weasyprint; then
    die_or_collect "Pandoc/WeasyPrint failed for $f" "$workdir" || return 1
    return 1
  fi

  /usr/bin/osascript -e \
    'display notification "Created '"${out_pdf##*/}"'" with title "Markdown → PDF"'

  if (( DEBUG > 0 )); then
    echo "DEBUG enabled → keeping workdir: $workdir"
  else
    rm -rf "$workdir"
  fi

  echo "Done: $out_pdf"
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
for f in "${files[@]}"; do
  if ! process_one "$f"; then
    (( CONTINUE_ON_ERROR == 0 )) && exit 1
  fi
done

if (( CONTINUE_ON_ERROR == 1 && ${#failures[@]} > 0 )); then
  echo ""
  echo "Completed with errors on ${#failures[@]} item(s):"
  printf ' - %s\n' "${failures[@]}"
  exit 2
fi

echo "All done."
