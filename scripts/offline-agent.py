#!/usr/bin/env python3
"""
Offline Fix Agent - Works without GitHub API
For demo and testing when network is slow or unavailable
"""

import json
import sys
import argparse

def create_sample_issue(issue_number):
    """Create a sample issue for testing"""
    return {
        "source": "offline",
        "timestamp": "2026-03-10T00:00:00Z",
        "issue": {
            "number": issue_number,
            "title": f"Issue #{issue_number} - App functionality issue",
            "body": "Testing the agent workflow with offline mode",
            "state": "open",
            "labels": ["bug"],
            "author": "developer"
        },
        "analysis": {
            "components": ["ContactsFragment", "Navigation"],
            "priority": "medium",
            "type": "bug"
        },
        "metadata": {
            "repo": "kondlada/CodeFixChallenge",
            "fetched_at": "2026-03-10T00:00:00Z"
        }
    }

def main():
    if len(sys.argv) < 2:
        print("Usage: offline-agent.py <issue_number>", file=sys.stderr)
        sys.exit(1)

    issue_number = sys.argv[1]

    print(f"🔍 Fetching issue #{issue_number} (OFFLINE MODE)...", file=sys.stderr)

    # Create sample issue
    issue_data = create_sample_issue(int(issue_number))

    print(f"✅ Issue #{issue_number} fetched (offline mode)", file=sys.stderr)
    print(f"   Title: {issue_data['issue']['title']}", file=sys.stderr)
    print(f"   Components: {', '.join(issue_data['analysis']['components'])}", file=sys.stderr)

    # Output JSON
    print(json.dumps(issue_data, indent=2))

if __name__ == '__main__':
    main()

