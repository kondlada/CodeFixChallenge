#!/usr/bin/env python3
"""
Test GitHub Issue Fetching
Tests both gh CLI and API methods
"""

import subprocess
import json
import urllib.request
import sys

def test_gh_cli(issue_number):
    """Test fetching via gh CLI"""
    print(f"🔍 Testing gh CLI for issue #{issue_number}...")
    try:
        cmd = ['gh', 'issue', 'view', str(issue_number), '--json', 'number,title,state']
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=10, check=True)
        data = json.loads(result.stdout)
        print(f"  ✅ gh CLI works!")
        print(f"  Title: {data.get('title')}")
        print(f"  State: {data.get('state')}")
        return True, data
    except subprocess.TimeoutExpired:
        print(f"  ❌ gh CLI timeout (>10s)")
        return False, "timeout"
    except subprocess.CalledProcessError as e:
        print(f"  ❌ gh CLI error: {e.stderr}")
        return False, e.stderr
    except FileNotFoundError:
        print(f"  ❌ gh CLI not installed")
        return False, "not_installed"
    except Exception as e:
        print(f"  ❌ gh CLI error: {e}")
        return False, str(e)

def test_api(issue_number, repo="kondlada/CodeFixChallenge"):
    """Test fetching via GitHub API"""
    print(f"\n🔍 Testing GitHub API for issue #{issue_number}...")
    try:
        import ssl

        url = f"https://api.github.com/repos/{repo}/issues/{issue_number}"
        req = urllib.request.Request(url)
        req.add_header('User-Agent', 'Mozilla/5.0')

        # Try with SSL verification first
        try:
            ssl_context = ssl.create_default_context()
            with urllib.request.urlopen(req, timeout=10, context=ssl_context) as response:
                data = json.loads(response.read().decode())
        except ssl.SSLError as ssl_error:
            print(f"  ⚠️  SSL verification failed, trying without verification...")
            # Fallback: disable SSL verification
            ssl_context = ssl.create_default_context()
            ssl_context.check_hostname = False
            ssl_context.verify_mode = ssl.CERT_NONE

            with urllib.request.urlopen(req, timeout=10, context=ssl_context) as response:
                data = json.loads(response.read().decode())

        if 'message' in data and data['message'] == 'Not Found':
            print(f"  ❌ Issue not found")
            return False, "not_found"

        print(f"  ✅ API works!")
        print(f"  Title: {data.get('title')}")
        print(f"  State: {data.get('state')}")
        print(f"  URL: {data.get('html_url')}")
        return True, data
    except urllib.error.HTTPError as e:
        print(f"  ❌ HTTP Error: {e.code} - {e.reason}")
        return False, f"http_{e.code}"
    except urllib.error.URLError as e:
        print(f"  ❌ URL Error: {e.reason}")
        return False, str(e.reason)
    except Exception as e:
        print(f"  ❌ API error: {e}")
        return False, str(e)

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 test-issue-fetch.py <issue_number>")
        print("Example: python3 test-issue-fetch.py 2")
        sys.exit(1)

    issue_number = sys.argv[1]

    print("=" * 60)
    print(f"Testing GitHub Issue Fetching for Issue #{issue_number}")
    print("=" * 60)

    # Test both methods
    gh_success, gh_result = test_gh_cli(issue_number)
    api_success, api_result = test_api(issue_number)

    print("\n" + "=" * 60)
    print("RESULTS:")
    print("=" * 60)

    if gh_success:
        print("✅ gh CLI: Working")
    else:
        print(f"❌ gh CLI: Failed ({gh_result})")

    if api_success:
        print("✅ GitHub API: Working")
    else:
        print(f"❌ GitHub API: Failed ({api_result})")

    print("\n" + "=" * 60)

    if gh_success or api_success:
        print("✅ At least one method works - agent should be able to fetch issue")
        print("\nRecommendation: Run the agent now")
        print(f"  ./scripts/start-agent.sh {issue_number}")
        return 0
    else:
        print("❌ Both methods failed - check network/authentication")
        print("\nTroubleshooting:")
        if gh_result == "not_installed":
            print("  1. Install gh CLI: brew install gh")
        elif gh_result == "timeout":
            print("  1. gh CLI is hanging - check authentication: gh auth status")

        if "http_404" in str(api_result):
            print(f"  2. Issue #{issue_number} doesn't exist or repo is private")
        elif "URLError" in str(api_result) or "timeout" in str(api_result):
            print("  2. Check network connectivity")

        print(f"\nVerify issue exists: https://github.com/kondlada/CodeFixChallenge/issues/{issue_number}")
        return 1

if __name__ == "__main__":
    sys.exit(main())

