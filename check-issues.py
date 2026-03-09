#!/usr/bin/env python3
"""
Quick script to fetch GitHub issues without gh CLI
"""
import json
import urllib.request
import sys

def fetch_github_issues(repo_owner, repo_name):
    """Fetch open issues from GitHub"""
    url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/issues?state=open"

    try:
        with urllib.request.urlopen(url) as response:
            data = json.loads(response.read().decode())

        if not data:
            print("✅ No open issues found!")
            return []

        print(f"📋 Found {len(data)} open issue(s):\n")

        for issue in data:
            # Skip pull requests (they appear as issues in the API)
            if 'pull_request' in issue:
                continue

            number = issue['number']
            title = issue['title']
            labels = ', '.join([label['name'] for label in issue.get('labels', [])])
            created = issue['created_at'][:10]

            print(f"#{number} - {title}")
            print(f"   Labels: {labels if labels else 'None'}")
            print(f"   Created: {created}")
            print(f"   URL: {issue['html_url']}")
            print()

        return data

    except urllib.error.HTTPError as e:
        if e.code == 404:
            print(f"❌ Repository not found or is private")
        else:
            print(f"❌ Error: {e}")
        return []
    except Exception as e:
        print(f"❌ Error fetching issues: {e}")
        return []

if __name__ == "__main__":
    # Try to get repo info from git config
    import subprocess

    try:
        result = subprocess.run(
            ['git', 'config', '--get', 'remote.origin.url'],
            capture_output=True,
            text=True,
            check=True
        )

        url = result.stdout.strip()

        # Parse GitHub URL
        if 'github.com' in url:
            # Handle both SSH and HTTPS URLs
            parts = url.replace('git@github.com:', '').replace('https://github.com/', '').replace('.git', '').split('/')
            if len(parts) >= 2:
                owner, repo = parts[0], parts[1]
                print(f"🔍 Checking repository: {owner}/{repo}\n")
                issues = fetch_github_issues(owner, repo)

                if issues and len(issues) > 0:
                    first_issue = [i for i in issues if 'pull_request' not in i]
                    if first_issue:
                        print(f"\n💡 To fix the first issue, run:")
                        print(f"   ./scripts/start-agent.sh {first_issue[0]['number']}")
            else:
                print("❌ Could not parse repository URL")
        else:
            print("❌ Not a GitHub repository")

    except subprocess.CalledProcessError:
        print("❌ Not in a git repository or no remote configured")
    except Exception as e:
        print(f"❌ Error: {e}")

