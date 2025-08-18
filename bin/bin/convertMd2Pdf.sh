#!/bin/bash

# Get the full path to the .md file
mdfile="$1"
# Remove .md extension and create .pdf path
pdffile="${mdfile%.md}.pdf"

/opt/homebrew/bin/pandoc "$mdfile" -o "$pdffile" --pdf-engine=/opt/homebrew/bin/weasyprint
