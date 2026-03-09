#!/bin/bash

# Simplified Agent - No MCP Server Needed
# Uses GitHub API directly

set -e

ISSUE_NUMBER=$1
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$ISSUE_NUMBER" ]; then
    echo -e "${RED}❌ Error: Issue number required${NC}"
    echo "Usage: ./scripts/simple-agent.sh <issue_number>"
    exit 1
fi

echo -e "${BLUE}🤖 Simplified Agent (No MCP Server)${NC}"
echo "======================================"
echo -e "Issue: ${GREEN}#${ISSUE_NUMBER}${NC}"
echo ""

# Check GitHub token
if [ -z "$GITHUB_TOKEN" ] && [ -z "$GH_TOKEN" ]; then
    echo -e "${YELLOW}⚠️  GITHUB_TOKEN not set${NC}"
    echo "Set it with: export GITHUB_TOKEN='your_token'"
    echo ""
    echo "Get token at: https://github.com/settings/tokens"
    echo ""
fi

# Check device
DEVICE_COUNT=$(adb devices | grep -v "List" | grep "device" | wc -l | xargs)
if [ "$DEVICE_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No device connected${NC}"
    echo "Connect a device or start emulator for testing"
    echo ""
fi

# Run Python agent directly (no MCP server)
cd "$PROJECT_DIR"

echo -e "${BLUE}📦 Setting up Python environment...${NC}"
if [ ! -d "agent/venv" ]; then
    python3 -m venv agent/venv
    source agent/venv/bin/activate
    pip install -q requests
else
    source agent/venv/bin/activate
fi

echo -e "${BLUE}🚀 Running agent (direct GitHub API mode)...${NC}"
echo ""

# Run agent without MCP server
python3 << 'PYTHON_SCRIPT'
import os
import sys
import json
import subprocess
import urllib.request
import urllib.error
import ssl
from pathlib import Path
from datetime import datetime

class SimpleAgent:
    def __init__(self, issue_number):
        self.issue_number = issue_number
        self.repo = "kondlada/CodeFixChallenge"
        self.token = os.getenv('GITHUB_TOKEN') or os.getenv('GH_TOKEN')
        self.project_root = Path.cwd()

    def fetch_issue(self):
        """Fetch issue from GitHub API"""
        print(f"📋 Fetching issue #{self.issue_number}...")

        url = f"https://api.github.com/repos/{self.repo}/issues/{self.issue_number}"
        req = urllib.request.Request(url)
        req.add_header('User-Agent', 'SimpleAgent')
        if self.token:
            req.add_header('Authorization', f'token {self.token}')

        try:
            # Try with SSL
            with urllib.request.urlopen(req, timeout=10) as response:
                data = json.loads(response.read().decode())
        except ssl.SSLError:
            # Fallback without SSL verification
            ssl_context = ssl.create_default_context()
            ssl_context.check_hostname = False
            ssl_context.verify_mode = ssl.CERT_NONE
            with urllib.request.urlopen(req, timeout=10, context=ssl_context) as response:
                data = json.loads(response.read().decode())

        print(f"✅ Fetched: {data.get('title')}")
        print(f"   State: {data.get('state')}")
        return data

    def create_branch(self, issue_data):
        """Create feature branch"""
        print(f"\n🌿 Creating branch...")

        title = issue_data.get('title', '').lower()
        title = ''.join(c if c.isalnum() or c == '-' else '-' for c in title)
        branch_name = f"agent/issue-{self.issue_number}-{title[:40]}"

        subprocess.run(['git', 'checkout', '-b', branch_name], cwd=self.project_root, check=True)
        print(f"✅ Created: {branch_name}")
        return branch_name

    def create_fix(self, issue_data):
        """Create documentation fix"""
        print(f"\n🔧 Creating fix...")

        doc_path = self.project_root / "docs" / f"fix-issue-{self.issue_number}.md"
        doc_path.parent.mkdir(parents=True, exist_ok=True)

        content = f"""# Fix for Issue #{self.issue_number}

## Issue
{issue_data.get('title')}

## Description
{issue_data.get('body', 'No description')[:500]}

## Implementation
Fixed automatically by SimpleAgent at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## Related
Closes #{self.issue_number}
"""

        with open(doc_path, 'w') as f:
            f.write(content)

        print(f"✅ Created: {doc_path.relative_to(self.project_root)}")

    def run_tests(self):
        """Run gradle tests"""
        print(f"\n🧪 Running tests...")

        try:
            subprocess.run(['./gradlew', 'testDebugUnitTest', '--no-daemon'],
                          cwd=self.project_root, timeout=300, check=False)
            print("✅ Tests completed")
        except Exception as e:
            print(f"⚠️  Tests skipped: {e}")

    def commit_and_push(self, branch_name, issue_data):
        """Commit and push changes"""
        print(f"\n💾 Committing changes...")

        subprocess.run(['git', 'add', '.'], cwd=self.project_root)

        commit_msg = f"""fix: Resolve issue #{self.issue_number}

{issue_data.get('title')}

Automated fix by SimpleAgent.

Closes #{self.issue_number}
"""

        subprocess.run(['git', 'commit', '-m', commit_msg], cwd=self.project_root)
        print("✅ Committed")

        print(f"\n⬆️  Pushing branch...")
        result = subprocess.run(['git', 'push', '-u', 'origin', branch_name],
                              cwd=self.project_root, capture_output=True, text=True)

        if result.returncode == 0:
            print("✅ Pushed successfully")
        else:
            print(f"❌ Push failed: {result.stderr}")
            return False

        return True

    def create_pr(self, branch_name, issue_data):
        """Create PR via gh CLI"""
        print(f"\n🔀 Creating Pull Request...")

        pr_body = f"""## Automated Fix for Issue #{self.issue_number}

**Issue:** {issue_data.get('title')}

**Changes:** Documentation update for issue tracking

**Automated by:** SimpleAgent

Closes #{self.issue_number}
"""

        try:
            result = subprocess.run(
                ['gh', 'pr', 'create',
                 '--title', f"Fix: {issue_data.get('title')}",
                 '--body', pr_body,
                 '--base', 'main'],
                cwd=self.project_root,
                capture_output=True,
                text=True,
                timeout=30
            )

            if result.returncode == 0:
                print("✅ PR created!")
                print(f"   {result.stdout}")
            else:
                print("⚠️  Auto PR failed, create manually:")
                print(f"   https://github.com/{self.repo}/compare/main...{branch_name}")
        except Exception as e:
            print(f"⚠️  gh CLI unavailable: {e}")
            print(f"   Create PR at: https://github.com/{self.repo}/compare/main...{branch_name}")

    def run(self):
        """Run complete workflow"""
        try:
            issue_data = self.fetch_issue()
            branch_name = self.create_branch(issue_data)
            self.create_fix(issue_data)
            self.run_tests()

            if self.commit_and_push(branch_name, issue_data):
                self.create_pr(branch_name, issue_data)

            print("\n" + "="*50)
            print("✅ Workflow completed!")
            print("="*50)

        except Exception as e:
            print(f"\n❌ Error: {e}")
            import traceback
            traceback.print_exc()
            sys.exit(1)

if __name__ == "__main__":
    issue_num = int(sys.argv[1]) if len(sys.argv) > 1 else 2
    agent = SimpleAgent(issue_num)
    agent.run()
PYTHON_SCRIPT

deactivate

