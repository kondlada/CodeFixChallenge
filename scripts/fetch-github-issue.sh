#!/bin/bash

# Fetch GitHub Issue Script
# Usage: ./fetch-github-issue.sh <issue_number>

set -e

ISSUE_NUMBER=$1
REPO_OWNER=${GITHUB_REPOSITORY_OWNER:-$(git config --get remote.origin.url | sed -n 's#.*/\([^/]*\)/.*#\1#p')}
REPO_NAME=${GITHUB_REPOSITORY_NAME:-$(basename -s .git $(git config --get remote.origin.url))}

if [ -z "$ISSUE_NUMBER" ]; then
    echo "❌ Error: Issue number required"
    echo "Usage: ./fetch-github-issue.sh <issue_number>"
    exit 1
fi

echo "🔍 Fetching issue #${ISSUE_NUMBER} from ${REPO_OWNER}/${REPO_NAME}..."

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) not installed"
    echo "Install: brew install gh"
    exit 1
fi

# Fetch issue details
ISSUE_JSON=$(gh issue view $ISSUE_NUMBER --json number,title,body,labels,state,author)

# Extract fields
ISSUE_TITLE=$(echo "$ISSUE_JSON" | jq -r '.title')
ISSUE_BODY=$(echo "$ISSUE_JSON" | jq -r '.body')
ISSUE_LABELS=$(echo "$ISSUE_JSON" | jq -r '.labels[].name' | tr '\n' ',' | sed 's/,$//')
ISSUE_STATE=$(echo "$ISSUE_JSON" | jq -r '.state')
ISSUE_AUTHOR=$(echo "$ISSUE_JSON" | jq -r '.author.login')

echo "✅ Issue fetched successfully!"
echo ""
echo "📋 Issue Details:"
echo "  Number: #${ISSUE_NUMBER}"
echo "  Title: ${ISSUE_TITLE}"
echo "  State: ${ISSUE_STATE}"
echo "  Author: ${ISSUE_AUTHOR}"
echo "  Labels: ${ISSUE_LABELS}"
echo ""
echo "📄 Description:"
echo "${ISSUE_BODY}"
echo ""

# Save to temporary file for processing
OUTPUT_FILE="/tmp/github_issue_${ISSUE_NUMBER}.json"
echo "$ISSUE_JSON" > "$OUTPUT_FILE"
echo "💾 Issue details saved to: ${OUTPUT_FILE}"

# Export variables for use in other scripts
export ISSUE_NUMBER
export ISSUE_TITLE
export ISSUE_BODY
export ISSUE_LABELS
export ISSUE_STATE
export ISSUE_AUTHOR

echo ""
echo "✨ Issue data ready for processing!"

