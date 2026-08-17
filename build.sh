#!/bin/bash
# Wraps page.html into a complete index.html for GitHub Pages.
#
# page.html carries no <head> because the same file is also published as a
# Claude artifact, which supplies its own document skeleton. GitHub Pages does
# not — and without a viewport meta the page renders at desktop width on
# phones, which breaks the main use case (reading it at the printer).
#
# page.html is split at its single </style> tag: everything up to and including
# that line is head content, everything after it is body content.
set -e
cd "$(dirname "$0")"

URL="https://djnowhere.github.io/MakerBotMethod/"
DESC="A step-by-step guide to getting a MakerBot Method or Method X printing reliably: tool list, calibration, filament drying, a pre-print checklist, and failure triage."

if [ "$(grep -c '</style>' page.html)" != "1" ]; then
  echo "build: expected exactly one </style> in page.html" >&2
  exit 1
fi

SPLIT=$(grep -n '</style>' page.html | cut -d: -f1)

{
  echo '<!doctype html>'
  echo '<html lang="en">'
  echo '<head>'
  echo '<meta charset="utf-8">'
  echo '<meta name="viewport" content="width=device-width, initial-scale=1">'
  echo "<meta name=\"description\" content=\"$DESC\">"
  echo "<link rel=\"canonical\" href=\"$URL\">"
  echo '<meta property="og:type" content="article">'
  echo '<meta property="og:title" content="Method Startup Manual">'
  echo "<meta property=\"og:description\" content=\"$DESC\">"
  echo "<meta property=\"og:url\" content=\"$URL\">"
  echo '<meta name="twitter:card" content="summary">'
  head -n "$SPLIT" page.html
  echo '</head>'
  echo '<body>'
  tail -n +"$((SPLIT + 1))" page.html
  echo '</body>'
  echo '</html>'
} > index.html

echo "build: index.html ($(wc -c < index.html | tr -d ' ') bytes, split at line $SPLIT)"
