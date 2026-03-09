#!/bin/bash

# Fetch New Issues and Apply Fixes Automatically
# This script fetches all open issues and processes them

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🤖 Auto-Fix Agent - Fetch and Fix Issues${NC}"
echo "=========================================="
echo ""

cd "$PROJECT_DIR"

# Check for devices
DEVICE_COUNT=$(adb devices 2>/dev/null | grep -v "List" | grep "device" | wc -l | xargs)
echo -e "${BLUE}📱 Devices:${NC} $DEVICE_COUNT connected"
echo ""

# Fetch open issues
echo -e "${BLUE}🔍 Fetching open issues from GitHub...${NC}"
echo ""

python3 << 'FETCH_ISSUES'
import urllib.request
import json
import ssl

# Bypass SSL for macOS Python issue
ssl_context = ssl.create_default_context()
ssl_context.check_hostname = False
ssl_context.verify_mode = ssl.CERT_NONE

# Manual database of known issues
KNOWN_ISSUES = {
    2: {
        "number": 2,
        "title": "[BUG] It says no contacts available",
        "body": "App shows 'no contacts available' even though contacts exist in the device.",
        "state": "open",
        "labels": ["bug"]
    }
}

def fetch_from_api():
    """Try to fetch from GitHub API"""
    try:
        url = "https://api.github.com/repos/kondlada/CodeFixChallenge/issues?state=open"
        req = urllib.request.Request(url)
        req.add_header('User-Agent', 'AutoFixAgent')

        with urllib.request.urlopen(req, timeout=10, context=ssl_context) as response:
            data = json.loads(response.read().decode())

        issues = [issue for issue in data if 'pull_request' not in issue]
        return issues if issues else None
    except Exception as e:
        print(f"⚠️  GitHub API unavailable: {e}")
        return None

def get_issues():
    """Get issues from API or manual database"""
    print("Trying GitHub API...")
    api_issues = fetch_from_api()

    if api_issues:
        print(f"✅ Found {len(api_issues)} issue(s) from GitHub API\n")
        return api_issues
    else:
        print("⚠️  Using manual issue database\n")
        return list(KNOWN_ISSUES.values())

# Fetch issues
issues = get_issues()

if not issues:
    print("❌ No open issues found")
    exit(0)

print("📋 Open Issues:")
print("-" * 50)
for issue in issues:
    print(f"  #{issue['number']}: {issue['title']}")
    print(f"       State: {issue['state']}")
    labels = [l['name'] if isinstance(l, dict) else l for l in issue.get('labels', [])]
    if labels:
        print(f"       Labels: {', '.join(labels)}")
    print()

# Save issue numbers for processing
issue_numbers = [issue['number'] for issue in issues]
print(f"\n✅ Found {len(issue_numbers)} issue(s) to process")
print(f"Issue numbers: {', '.join(map(str, issue_numbers))}")

# Write to temp file for shell script
with open('/tmp/issues_to_fix.txt', 'w') as f:
    for num in issue_numbers:
        f.write(f"{num}\n")

FETCH_ISSUES

# Check if we found issues
if [ ! -f /tmp/issues_to_fix.txt ]; then
    echo -e "${RED}❌ No issues found to fix${NC}"
    exit 0
fi

# Read issues and process each one
echo ""
echo -e "${BLUE}🔧 Processing Issues...${NC}"
echo "=========================================="
echo ""

ISSUE_COUNT=0
FIXED_COUNT=0

while IFS= read -r ISSUE_NUM; do
    ISSUE_COUNT=$((ISSUE_COUNT + 1))

    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Processing Issue #${ISSUE_NUM} (${ISSUE_COUNT} of $(wc -l < /tmp/issues_to_fix.txt))${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Run the simple agent for this issue
    if ./scripts/simple-agent.sh "$ISSUE_NUM" 2>&1; then
        FIXED_COUNT=$((FIXED_COUNT + 1))
        echo -e "${GREEN}✅ Issue #${ISSUE_NUM} processed successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  Issue #${ISSUE_NUM} had errors${NC}"
    fi

    echo ""

done < /tmp/issues_to_fix.txt

# Cleanup
rm -f /tmp/issues_to_fix.txt

# Summary
echo ""
echo "=========================================="
echo -e "${GREEN}🎉 Batch Processing Complete!${NC}"
echo "=========================================="
echo ""
echo "Summary:"
echo "  Total issues found: $ISSUE_COUNT"
echo "  Successfully processed: $FIXED_COUNT"
echo ""

if [ "$FIXED_COUNT" -eq "$ISSUE_COUNT" ]; then
    echo -e "${GREEN}✅ All issues processed successfully!${NC}"
else
    echo -e "${YELLOW}⚠️  Some issues had errors. Check logs above.${NC}"
fi

echo ""
echo "Next steps:"
echo "  1. Review the created Pull Requests on GitHub"
echo "  2. Check test results"
echo "  3. Request code reviews"
echo "  4. Merge approved PRs"
echo ""

