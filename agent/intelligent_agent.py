#!/usr/bin/env python3
"""
Intelligent Agent for Automated Issue Resolution
Connects to GitHub MCP Server and orchestrates the entire workflow
"""

import json
import logging
import subprocess
import requests
import sys
from pathlib import Path
from typing import Dict, Any, Optional
from datetime import datetime

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class IntelligentAgent:
    """Orchestrates the entire issue-to-PR workflow"""

    def __init__(self, mcp_url: str = "http://localhost:8000"):
        self.mcp_url = mcp_url
        self.project_root = Path.cwd()
        self.issue_number = None
        self.issue_data = None
        self.analysis = None
        self.branch_name = None

    def process_issue(self, issue_number: int) -> bool:
        """Main workflow: Process issue from start to PR"""
        self.issue_number = issue_number

        logger.info("=" * 60)
        logger.info(f"🤖 Starting automated processing for issue #{issue_number}")
        logger.info("=" * 60)

        try:
            # Step 1: Fetch issue
            if not self._fetch_issue():
                return False

            # Step 2: Analyze codebase
            if not self._analyze_codebase():
                return False

            # Step 3: Create branch
            if not self._create_branch():
                return False

            # Step 4: Generate and apply fix (placeholder - manual for now)
            if not self._apply_fixes():
                return False

            # Step 5: Run tests
            if not self._run_tests():
                return False

            # Step 6: Commit changes
            if not self._commit_changes():
                return False

            # Step 7: Push branch
            if not self._push_branch():
                return False

            # Step 8: Create PR
            if not self._create_pull_request():
                return False

            logger.info("=" * 60)
            logger.info("✅ Successfully completed automated workflow!")
            logger.info("=" * 60)
            return True

        except Exception as e:
            logger.error(f"❌ Workflow failed: {e}", exc_info=True)
            return False

    def _fetch_issue(self) -> bool:
        """Fetch issue from GitHub"""
        logger.info("")
        logger.info("📋 Step 1: Fetching issue details...")

        response = self._call_mcp("fetch_github_issue", {
            "issue_number": self.issue_number
        })

        if response.get("success"):
            self.issue_data = response.get("data")
            logger.info(f"✅ Fetched: {self.issue_data.get('title')}")
            logger.info(f"   Author: {self.issue_data.get('author', {}).get('login', 'unknown')}")
            logger.info(f"   State: {self.issue_data.get('state')}")
            labels = [label['name'] for label in self.issue_data.get('labels', [])]
            if labels:
                logger.info(f"   Labels: {', '.join(labels)}")
            return True
        else:
            logger.error(f"❌ Failed to fetch issue: {response.get('error')}")
            return False

    def _analyze_codebase(self) -> bool:
        """Analyze codebase"""
        logger.info("")
        logger.info("🔍 Step 2: Analyzing codebase...")

        response = self._call_mcp("analyze_codebase", {
            "issue_data": self.issue_data
        })

        if response:
            self.analysis = response
            logger.info(f"✅ Analysis complete")
            logger.info(f"   Type: {self.analysis.get('issue_type')}")
            logger.info(f"   Complexity: {self.analysis.get('complexity')}")
            logger.info(f"   Affected modules: {', '.join(self.analysis.get('affected_modules', []))}")
            logger.info(f"   Architecture: {self.analysis.get('architecture')}")
            return True
        else:
            logger.error("❌ Analysis failed")
            return False

    def _create_branch(self) -> bool:
        """Create feature branch"""
        logger.info("")
        logger.info("🌿 Step 3: Creating feature branch...")

        # Generate branch name
        title_slug = self.issue_data.get('title', '').lower()
        title_slug = ''.join(c if c.isalnum() else '-' for c in title_slug)[:40]
        self.branch_name = f"agent/issue-{self.issue_number}-{title_slug}"

        try:
            # Check if we're on main/master
            subprocess.run(['git', 'checkout', 'main'],
                         capture_output=True, check=False, cwd=self.project_root)

            # Pull latest
            subprocess.run(['git', 'pull', 'origin', 'main'],
                         capture_output=True, check=False, cwd=self.project_root)

            # Create new branch
            result = subprocess.run(
                ['git', 'checkout', '-b', self.branch_name],
                capture_output=True, text=True, cwd=self.project_root
            )

            if result.returncode != 0:
                # Branch might already exist, try to checkout
                result = subprocess.run(
                    ['git', 'checkout', self.branch_name],
                    capture_output=True, text=True, cwd=self.project_root
                )

            if result.returncode == 0:
                logger.info(f"✅ Created branch: {self.branch_name}")
                return True
            else:
                logger.error(f"❌ Failed to create branch: {result.stderr}")
                return False

        except Exception as e:
            logger.error(f"❌ Failed to create branch: {e}")
            return False

    def _apply_fixes(self) -> bool:
        """Apply fixes (manual step for now)"""
        logger.info("")
        logger.info("🔧 Step 4: Applying fixes...")
        logger.info("")
        logger.info("Suggested approach:")
        approach = self.analysis.get('suggested_approach', 'No approach suggested')
        for line in approach.split('\n'):
            logger.info(f"   {line}")

        logger.info("")
        logger.info("⚠️  MANUAL STEP REQUIRED:")
        logger.info("   Please apply the necessary code changes to fix the issue.")
        logger.info("   Once done, press Enter to continue...")

        try:
            input()
            logger.info("✅ Proceeding with changes applied")
            return True
        except KeyboardInterrupt:
            logger.error("❌ Cancelled by user")
            return False

    def _run_tests(self) -> bool:
        """Run tests"""
        logger.info("")
        logger.info("🧪 Step 5: Running tests...")

        response = self._call_mcp("run_tests", {
            "test_type": "all"
        })

        if response and response.get("success"):
            logger.info("✅ All tests passed")
            return True
        else:
            logger.error("❌ Tests failed")
            logger.error(f"   Output: {response.get('output', 'No output')[-200:]}")

            # Ask if we should continue anyway
            logger.info("")
            logger.info("Continue anyway? (y/n): ")
            try:
                choice = input().strip().lower()
                if choice == 'y':
                    logger.info("⚠️  Continuing despite test failures...")
                    return True
            except KeyboardInterrupt:
                pass

            return False

    def _commit_changes(self) -> bool:
        """Commit changes"""
        logger.info("")
        logger.info("💾 Step 6: Committing changes...")

        try:
            # Add all changes
            subprocess.run(['git', 'add', '.'],
                         check=True, cwd=self.project_root)

            # Create commit message
            commit_msg = f"""fix: Resolve issue #{self.issue_number} - {self.issue_data.get('title')}

Automated fix by Intelligent Agent.

Issue Details:
- Number: #{self.issue_number}
- Type: {self.analysis.get('issue_type', 'unknown')}
- Complexity: {self.analysis.get('complexity', 'unknown')}
- Modules: {', '.join(self.analysis.get('affected_modules', []))}

Closes #{self.issue_number}
"""

            result = subprocess.run(
                ['git', 'commit', '-m', commit_msg],
                capture_output=True, text=True, cwd=self.project_root
            )

            if result.returncode == 0:
                logger.info("✅ Changes committed")
                return True
            elif 'nothing to commit' in result.stdout:
                logger.warning("⚠️  No changes to commit")
                return True
            else:
                logger.error(f"❌ Commit failed: {result.stderr}")
                return False

        except Exception as e:
            logger.error(f"❌ Failed to commit: {e}")
            return False

    def _push_branch(self) -> bool:
        """Push branch to remote"""
        logger.info("")
        logger.info("⬆️  Step 7: Pushing branch...")

        try:
            result = subprocess.run(
                ['git', 'push', 'origin', self.branch_name],
                capture_output=True, text=True, cwd=self.project_root
            )

            if result.returncode == 0:
                logger.info("✅ Branch pushed to origin")
                return True
            else:
                logger.error(f"❌ Failed to push: {result.stderr}")
                return False

        except Exception as e:
            logger.error(f"❌ Failed to push: {e}")
            return False

    def _create_pull_request(self) -> bool:
        """Create pull request"""
        logger.info("")
        logger.info("🔀 Step 8: Creating pull request...")

        # Generate PR body
        pr_body = f"""## 🤖 Automated Fix for Issue #{self.issue_number}

### 📋 Issue Details
**Title**: {self.issue_data.get('title')}
**Type**: {self.analysis.get('issue_type')}
**Complexity**: {self.analysis.get('complexity')}
**Author**: @{self.issue_data.get('author', {}).get('login', 'unknown')}

### 🔧 Changes Made
Automated fix generated and applied by Intelligent Agent.

### 📊 Analysis
**Affected Modules**: {', '.join(self.analysis.get('affected_modules', []))}
**Architecture**: {self.analysis.get('architecture')}

### 📋 Suggested Approach
{self.analysis.get('suggested_approach', 'No approach specified')}

### ✅ Test Results
- Tests executed: ✅
- Code quality checks: Pending CI

### 🔍 Review Checklist
- [ ] Code changes reviewed
- [ ] Tests are comprehensive
- [ ] Documentation updated if needed
- [ ] No breaking changes introduced

---
**Generated by**: Intelligent Agent
**Timestamp**: {datetime.now().isoformat()}
**Workflow**: Automated Issue Resolution

Closes #{self.issue_number}
"""

        response = self._call_mcp("create_pull_request", {
            "branch_name": self.branch_name,
            "title": f"🤖 Fix: {self.issue_data.get('title')}",
            "body": pr_body,
            "issue_number": self.issue_number
        })

        if response and response.get("success"):
            pr_url = response.get("pr_url")
            logger.info(f"✅ Pull request created successfully!")
            logger.info(f"   URL: {pr_url}")
            logger.info("")
            logger.info("📌 Next steps:")
            logger.info("   1. Review the PR on GitHub")
            logger.info("   2. Check CI test results")
            logger.info("   3. Mark PR as ready for review")
            logger.info("   4. Request reviews from team")
            logger.info("   5. Merge after approval")
            return True
        else:
            logger.error(f"❌ Failed to create PR: {response.get('error')}")
            return False

    def _call_mcp(self, tool: str, parameters: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Call MCP server"""
        try:
            response = requests.post(
                f"{self.mcp_url}/execute",
                json={"tool": tool, "parameters": parameters},
                timeout=300
            )
            response.raise_for_status()
            return response.json()
        except requests.exceptions.ConnectionError:
            logger.error(f"❌ Cannot connect to MCP server at {self.mcp_url}")
            logger.error("   Make sure the MCP server is running")
            return None
        except requests.exceptions.Timeout:
            logger.error(f"❌ MCP call timed out for tool: {tool}")
            return None
        except Exception as e:
            logger.error(f"❌ MCP call failed: {e}")
            return None


def main():
    import argparse

    parser = argparse.ArgumentParser(
        description='Intelligent Agent for Automated Issue Resolution',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python intelligent_agent.py --issue 42
  python intelligent_agent.py --issue 42 --mcp-url http://localhost:8000
        """
    )
    parser.add_argument('--issue', type=int, required=True,
                       help='GitHub issue number to process')
    parser.add_argument('--mcp-url', default='http://localhost:8000',
                       help='MCP server URL (default: http://localhost:8000)')

    args = parser.parse_args()

    logger.info("🚀 Intelligent Agent Starting...")
    logger.info(f"   Issue: #{args.issue}")
    logger.info(f"   MCP Server: {args.mcp_url}")
    logger.info("")

    agent = IntelligentAgent(mcp_url=args.mcp_url)
    success = agent.process_issue(args.issue)

    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()

