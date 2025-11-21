#!/bin/zsh
# Fail fast + safe IFS for filenames with spaces
set -euo pipefail
IFS=$'\n'
setopt null_glob

# === Config toggles ===
: ${DEBUG:=0}                         # DEBUG=1 for curl trace/verbose
: ${REFERER:="https://chat.openai.com"}
: ${UA:="Mozilla/5.0 (Macintosh; Intel Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36"}
: ${COOKIE_HEADER:="${COOKIE:-}"}     # optionally: COOKIE='k=v; k2=v2'
: ${CONTINUE_ON_ERROR:=0}             # 1 = don't exit on image errors; report at end

# Tools
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Log
LOG="$HOME/Library/Logs/Shortcuts/convert_md_to_pdf.log"
exec > >(tee -a "$LOG") 2>&1
echo "---- $(date) ----"
echo "Args: $@"
echo "DEBUG=$DEBUG  CONTINUE_ON_ERROR=$CONTINUE_ON_ERROR"

command -v pandoc >/dev/null || { echo "ERROR: pandoc not found"; exit 127; }
command -v weasyprint >/dev/null || { echo "ERROR: weasyprint not found"; exit 127; }
command -v shasum >/dev/null || { echo "ERROR: shasum not found"; exit 127; }

# Inputs
typeset -a inputs
if (( $# == 0 )); then
  inputs=( ./*.md )
  (( ${#inputs[@]} == 0 )) && { echo "No .md files found."; exit 0; }
else
  inputs=( "$@" )
fi

hash_of() {
  local url="$1"
  local base ext digest
  base="$(echo "$url" | sed 's/[?#].*$//' | awk -F/ '{print $NF}')"
  ext="${base##*.}"
  [[ "$ext" = "$base" || -z "$ext" ]] && ext="bin"
  digest="$(printf "%s" "$url" | shasum -a 256 | awk '{print $1}')"
  echo "${digest}.${ext}"
}

url_decode() { python3 - <<'PY' "$1"
import sys, urllib.parse
print(urllib.parse.unquote(sys.argv[1]))
PY
}

sas_info() {
  # If URL looks like Azure SAS (has sig= and se=), print decoded expiry
  local url="$1"
  if [[ "$url" == *"sig="* && "$url" == *"se="* ]]; then
    local se_raw="${url##*se=}"
    se_raw="${se_raw%%&*}"
    local se="$(url_decode "$se_raw")"
    echo "Detected Azure SAS URL with expiry (se): $se (UTC)"
    # Optional: show local time equivalent (macOS date)
    if date -j -f "%Y-%m-%dT%H:%M:%SZ" "$se" "+Local expiry: %Y-%m-%d %H:%M:%S %Z" 2>/dev/null; then :; fi
  fi
}

# Collect failures if CONTINUE_ON_ERROR=1
typeset -a failures

die_or_collect() {
  local msg="$1"; local wd="$2"
  echo ""
  echo "✖ ERROR: $msg"
  [[ -n "$wd" ]] && echo "    Debug artifacts: $wd"
  if (( CONTINUE_ON_ERROR > 0 )); then
    failures+="$msg (artifacts: $wd)"
    return 1
  else
    exit 1
  fi
}

fetch_with_debug() {
  # $1 url, $2 dest, $3 workdir
  local url="$1" dest="$2" wd="$3"
  sas_info "$url"

  local hdrs="$wd/headers.$(basename "$dest").txt"
  local trace="$wd/curl_trace.$(basename "$dest").log"
  local info="$wd/fetch_info.$(basename "$dest").txt"

  local curl_cmd=(curl -L --fail --connect-timeout 15 --max-time 90
    -A "$UA" -H "Referer: $REFERER"
    -D "$hdrs" --output "$dest"
    --write-out "http_code=%{http_code}\ncontent_type=%{content_type}\nurl_effective=%{url_effective}\nredirect_url=%{redirect_url}\n"
    "$url"
  )
  [[ -n "$COOKIE_HEADER" ]] && curl_cmd=(curl "${curl_cmd[@]:1}" -H "Cookie: $COOKIE_HEADER")
  (( DEBUG > 0 )) && curl_cmd=(curl "${curl_cmd[@]:1}" --trace-ascii "$trace" --verbose)

  echo "Fetching: $url"
  local summary
  if ! summary="$("${curl_cmd[@]}" 2>>"$trace")"; then
    echo "$summary" > "$info" || true
    echo "HTTP headers (last hop):"; tail -n +1 "$hdrs" || true
    (( DEBUG == 0 )) && [[ -f "$trace" ]] && echo "(Tip: set DEBUG=1 to capture curl trace → $trace)"
    die_or_collect "curl failed to fetch image: $url" "$wd" || return 1
    return 1
  fi
  echo "$summary" > "$info"

  local code="$(grep -Eo '^http_code=[0-9]+' "$info" | cut -d= -f2)"
  local ctype="$(grep -Eo '^content_type=.*' "$info" | cut -d= -f2)"
  local effective="$(grep -Eo '^url_effective=.*' "$info" | cut -d= -f2)"
  echo "→ HTTP $code  type=${ctype:-unknown}  effective=${effective:-n/a}"

  if [[ "$code" != "200" && "$code" != "206" ]]; then
    echo "HTTP headers (last hop):"; tail -n +1 "$hdrs" || true
    case "$code" in
      401|403) echo "Auth/permission error. If this is an expiring SAS link, it may be past 'se='."; ;;
      404)     echo "Not found. The link may be expired/rotated."; ;;
      429)     echo "Rate limited. Retry later."; ;;
      5*)      echo "Server error. Might be transient."; ;;
    esac
    die_or_collect "Non-OK status ($code) for $url" "$wd" || return 1
  fi

  [[ -s "$dest" ]] || { die_or_collect "Downloaded file is empty for $url" "$wd" || return 1; }
}

process_one() {
  local f="$1"
  [[ "${f:l}" != *.md ]] && { echo "Skipping non-md: $f"; return 0; }

  echo "Processing: $f"
  local out_pdf="${f%.*}.pdf"
  local workdir; workdir="$(mktemp -d)"
  local tmp_md="$workdir/$(basename "$f")"
  local imgdir="$workdir/images"
  mkdir -p "$imgdir"
  cp "$f" "$tmp_md"

  # Collect remote images
  local -a urls
  urls=($(grep -oE '!\[[^]]*\]\((https?[^)[:space:]]+)' "$tmp_md" | sed -E 's/^!\[[^]]*\]\(//')) || true
  urls+=($(grep -oE '<img[^>]*src="https?[^"]+"' "$tmp_md" | sed -E 's/^.*src="([^"]+)".*$/\1/')) || true

  if (( ${#urls[@]} )); then
    urls=($(printf "%s\n" "${urls[@]}" | awk '!seen[$0]++'))
    echo "Found ${#urls[@]} remote image URL(s)"
  else
    echo "No remote images detected."
  fi

  local had_error=0
  for u in "${urls[@]}"; do
    [[ "$u" =~ ^https?:// ]] || { echo "Skipping non-http URL: $u"; continue; }
    local fn dest esc_u esc_p
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

    esc_u="$(printf '%s' "$u" | sed 's/[\/&]/\\&/g')"
    esc_p="$(printf '%s' "images/$fn" | sed 's/[\/&]/\\&/g')"
    sed -i '' -E "s#(!\[[^]]*\]\()$esc_u(\))#\1$esc_p\2#g" "$tmp_md"
    sed -i '' -E "s#(src=\")$esc_u(\")#\1$esc_p\2#g" "$tmp_md"
  done

  if (( had_error && CONTINUE_ON_ERROR == 1 )); then
    echo "Proceeding to PDF despite image fetch errors…"
  fi

  echo "Converting to PDF: $out_pdf"
  if ! pandoc "$tmp_md" --standalone -o "$out_pdf" --pdf-engine=/opt/homebrew/bin/weasyprint; then
    die_or_collect "Pandoc/WeasyPrint failed for $f" "$workdir" || return 1
  fi

  /usr/bin/osascript -e \
    'display notification "Created '"${out_pdf##*/}"'" with title "Markdown → PDF"'

  (( DEBUG > 0 )) && echo "DEBUG=1 → keeping workdir: $workdir" || rm -rf "$workdir"
  echo "Done: $out_pdf"
}

# Build file list
typeset -a files
if (( $# == 0 )); then files=( ./*.md ); else files=( "$@" ); fi

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
