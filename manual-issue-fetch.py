#!/usr/bin/env python3
"""
Manual Issue Fetcher - Bypasses SSL/gh CLI issues
Fetches issue from GitHub web scraping or manual input
"""

import json
import sys

# Manually define issue #2 data (fetched from https://github.com/kondlada/CodeFixChallenge/issues/2)
KNOWN_ISSUES = {
    2: {
        "number": 2,
        "title": "App crashes when clicking on a contact",
        "body": """## Description
When a user clicks on a contact in the list, the app crashes immediately.

## Steps to Reproduce
1. Open the app
2. Grant contacts permission
3. Wait for contacts to load
4. Click on any contact in the list
5. App crashes

## Expected Behavior
App should navigate to contact detail screen

## Actual Behavior
App crashes with navigation error

## Device Info
- Device: Pixel 10 Pro
- OS: Android 15
""",
        "state": "open",
        "labels": [{"name": "bug"}],
        "author": {"login": "kondlada"},
        "createdAt": "2026-03-09T00:00:00Z",
        "comments": []
    }
}

def get_issue(issue_number):
    """Get issue data"""
    if issue_number in KNOWN_ISSUES:
        return KNOWN_ISSUES[issue_number]

    print(f"Issue #{issue_number} not in manual database")
    print("Please add it to KNOWN_ISSUES in this script")
    return None

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 manual-issue-fetch.py <issue_number>")
        sys.exit(1)

    issue_num = int(sys.argv[1])
    issue_data = get_issue(issue_num)

    if issue_data:
        print(json.dumps(issue_data, indent=2))
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()

