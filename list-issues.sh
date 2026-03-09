#!/bin/bash
# List GitHub issues script

echo "🔍 Checking GitHub Issues"
echo "========================="
echo ""

REPO="kondlada/CodeFixChallenge"

echo "Fetching issues from: https://github.com/$REPO/issues"
echo ""

# Fetch issues
ISSUES=$(curl -s "https://api.github.com/repos/$REPO/issues" 2>&1)

# Check if we got valid JSON
if echo "$ISSUES" | python3 -c "import sys, json; json.load(sys.stdin)" 2>/dev/null; then
    echo "Open Issues:"
    echo "$ISSUES" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if isinstance(data, list) and len(data) > 0:
        for issue in data:
            if 'pull_request' not in issue:  # Skip PRs
                number = issue.get('number', '?')
                title = issue.get('title', 'Unknown')
                state = issue.get('state', 'unknown')
                print(f\"  #{number}: {title} [{state}]\")
    else:
        print('  No issues found')
except Exception as e:
    print(f'  Error parsing: {e}')
"
else
    echo "❌ Could not fetch issues (network or API error)"
    echo ""
    echo "Please check manually at:"
    echo "https://github.com/$REPO/issues"
fi

echo ""
echo "To run agent for an issue:"
echo "  ./scripts/start-agent.sh <issue_number>"

