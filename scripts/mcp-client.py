#!/usr/bin/env python3
"""
MCP Client - Fetches issues from GitHub MCP
Supports both GitHub Actions workflows and direct API access
"""

import sys
import json
import subprocess
import urllib.request
import ssl
from datetime import datetime

REPO = "kondlada/CodeFixChallenge"

def fetch_via_gh_cli(issue_number):
    """Fetch issue using GitHub CLI"""
    try:
        result = subprocess.run([
            'gh', 'issue', 'view', str(issue_number),
            '--json', 'number,title,body,labels,state,createdAt'
        ], capture_output=True, text=True, timeout=10)

        if result.returncode == 0:
            return json.loads(result.stdout)
    except Exception as e:
        print(f"⚠️  gh CLI failed: {e}", file=sys.stderr)

    return None

def fetch_via_api(issue_number):
    """Fetch issue using GitHub REST API"""
    try:
        # Create SSL context
        ssl_context = ssl.create_default_context()
        ssl_context.check_hostname = False
        ssl_context.verify_mode = ssl.CERT_NONE

        url = f'https://api.github.com/repos/{REPO}/issues/{issue_number}'
        req = urllib.request.Request(url)
        req.add_header('User-Agent', 'AgentMCPClient/1.0')

        with urllib.request.urlopen(req, timeout=10, context=ssl_context) as response:
            data = json.loads(response.read().decode())

            # Transform to standard format
            return {
                'number': data['number'],
                'title': data['title'],
                'body': data.get('body', ''),
                'state': data['state'],
                'labels': [{'name': l['name']} for l in data.get('labels', [])],
                'createdAt': data.get('created_at', ''),
                'user': {'login': data.get('user', {}).get('login', 'unknown')}
            }
    except Exception as e:
        print(f"⚠️  API failed: {e}", file=sys.stderr)

    return None

def analyze_components(title, body):
    """Analyze issue to identify affected components"""
    text = f"{title} {body}".lower()
    components = []

    # Component keywords
    if 'contact' in text or 'recyclerview' in text:
        components.append('ContactsViewModel')
        components.append('ContactsFragment')
    if 'crash' in text or 'exception' in text:
        components.append('ErrorHandling')
    if 'permission' in text:
        components.append('PermissionHandler')
    if 'database' in text or 'room' in text:
        components.append('Repository')
    if 'navigation' in text or 'navigate' in text:
        components.append('Navigation')

    return components if components else ['Unknown']

def determine_priority(labels, title, body):
    """Determine issue priority"""
    label_names = [l['name'].lower() for l in labels]

    if 'critical' in label_names or 'crash' in title.lower():
        return 'critical'
    elif 'bug' in label_names:
        return 'high'
    elif 'enhancement' in label_names:
        return 'medium'
    else:
        return 'low'

def main():
    if len(sys.argv) < 2:
        print("Usage: mcp-client.py <issue_number>", file=sys.stderr)
        sys.exit(1)

    issue_number = sys.argv[1]

    print(f"🔍 Fetching issue #{issue_number} from GitHub MCP...", file=sys.stderr)

    # Try gh CLI first
    issue_data = fetch_via_gh_cli(issue_number)
    source = "gh-cli"

    # Fallback to API
    if not issue_data:
        print("   Trying GitHub API...", file=sys.stderr)
        issue_data = fetch_via_api(issue_number)
        source = "api"

    if not issue_data:
        print(f"❌ Failed to fetch issue #{issue_number}", file=sys.stderr)
        sys.exit(1)

    # Analyze and enhance data
    components = analyze_components(issue_data['title'], issue_data.get('body', ''))
    priority = determine_priority(issue_data.get('labels', []), issue_data['title'], issue_data.get('body', ''))

    # Create MCP structured output
    mcp_data = {
        'source': source,
        'timestamp': datetime.utcnow().isoformat(),
        'issue': {
            'number': issue_data['number'],
            'title': issue_data['title'],
            'body': issue_data.get('body', ''),
            'state': issue_data.get('state', 'open'),
            'labels': [l['name'] for l in issue_data.get('labels', [])],
            'author': issue_data.get('user', {}).get('login', 'unknown')
        },
        'analysis': {
            'components': components,
            'priority': priority,
            'type': 'bug' if any(l['name'].lower() == 'bug' for l in issue_data.get('labels', [])) else 'enhancement'
        },
        'metadata': {
            'repo': REPO,
            'fetched_at': datetime.utcnow().isoformat()
        }
    }

    # Output JSON
    print(json.dumps(mcp_data, indent=2))

    print(f"✅ Issue #{issue_number} fetched via {source}", file=sys.stderr)

if __name__ == '__main__':
    main()

