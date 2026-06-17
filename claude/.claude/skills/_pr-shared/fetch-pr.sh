#!/usr/bin/env bash
# Fetch PR metadata, changed files, and diff in one compact pass.
# Usage: fetch-pr.sh [pr-number-or-url]   (omit to detect from current branch)
set -euo pipefail

ref="${1:-}"

meta=$(gh pr view ${ref:+"$ref"} --json number,title,url,author,baseRefName,headRefName,isDraft)
read -r owner repo < <(jq -r '.url | capture("github\\.com/(?<o>[^/]+)/(?<r>[^/]+)/pull") | "\(.o) \(.r)"' <<<"$meta")

echo "=== META ==="
jq -r '"number: \(.number)\ntitle: \(.title)\nurl: \(.url)\nauthor: \(.author.login)\nbase: \(.baseRefName)\nhead: \(.headRefName)\ndraft: \(.isDraft)"' <<<"$meta"
echo "owner: $owner"
echo "repo: $repo"

echo "=== FILES ==="
gh pr diff ${ref:+"$ref"} --name-only

echo "=== DIFF ==="
gh pr diff ${ref:+"$ref"}
