#!/usr/bin/env python3
"""
GitHub MCP Server
A Model Context Protocol server that provides GitHub operations and AI-powered code generation.
"""

import json
import os
import subprocess
import logging
from typing import Dict, Any, List, Optional
from pathlib import Path
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)


class GitHubMCPServer:
    """MCP Server for GitHub operations and code generation"""

    def __init__(self):
        self.github_token = os.getenv('GITHUB_TOKEN') or os.getenv('GH_TOKEN')
        self.project_root = Path.cwd()

    def get_available_tools(self) -> List[Dict[str, Any]]:
        """Return list of available MCP tools"""
        return [
            {
                "name": "fetch_github_issue",
                "description": "Fetch issue details from GitHub",
                "parameters": {
                    "issue_number": {"type": "integer", "required": True}
                }
            },
            {
                "name": "analyze_codebase",
                "description": "Analyze project structure and relevant code",
                "parameters": {
                    "issue_data": {"type": "object", "required": True}
                }
            },
            {
                "name": "generate_fix",
                "description": "Generate code fix based on issue and context",
                "parameters": {
                    "issue_data": {"type": "object", "required": True},
                    "analysis": {"type": "object", "required": True}
                }
            },
            {
                "name": "run_tests",
                "description": "Run tests and generate reports",
                "parameters": {
                    "test_type": {"type": "string", "required": False}
                }
            },
            {
                "name": "create_pull_request",
                "description": "Create a pull request with changes",
                "parameters": {
                    "branch_name": {"type": "string", "required": True},
                    "title": {"type": "string", "required": True},
                    "body": {"type": "string", "required": True},
                    "issue_number": {"type": "integer", "required": True}
                }
            }
        ]

    def fetch_github_issue(self, issue_number: int) -> Dict[str, Any]:
        """Fetch issue details from GitHub using gh CLI or API fallback"""
        logger.info(f"Fetching issue #{issue_number}")

        # Try gh CLI first
        try:
            cmd = ['gh', 'issue', 'view', str(issue_number), '--json',
                   'number,title,body,labels,state,author,createdAt,comments']

            result = subprocess.run(cmd, capture_output=True, text=True,
                                   check=True, timeout=10)
            issue_data = json.loads(result.stdout)

            logger.info(f"Successfully fetched issue via gh CLI: {issue_data['title']}")
            return {
                "success": True,
                "data": issue_data
            }
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired, FileNotFoundError) as e:
            logger.warning(f"gh CLI failed: {e}, trying API fallback...")

            # Fallback to GitHub API
            try:
                import urllib.request

                # Get repo from git remote
                try:
                    repo_result = subprocess.run(['git', 'config', '--get', 'remote.origin.url'],
                                                capture_output=True, text=True, check=True)
                    repo_url = repo_result.stdout.strip()
                    # Parse repo owner/name from URL
                    if 'github.com' in repo_url:
                        repo_path = repo_url.split('github.com')[1].strip('/:').replace('.git', '')
                    else:
                        repo_path = "kondlada/CodeFixChallenge"  # Default
                except:
                    repo_path = "kondlada/CodeFixChallenge"  # Default

                api_url = f"https://api.github.com/repos/{repo_path}/issues/{issue_number}"

                # Add authentication if token available
                req = urllib.request.Request(api_url)
                if self.github_token:
                    req.add_header('Authorization', f'token {self.github_token}')

                with urllib.request.urlopen(req, timeout=10) as response:
                    api_data = json.loads(response.read().decode())

                # Transform API response to match gh CLI format
                issue_data = {
                    'number': api_data.get('number'),
                    'title': api_data.get('title'),
                    'body': api_data.get('body', ''),
                    'state': api_data.get('state'),
                    'labels': [{'name': label['name']} for label in api_data.get('labels', [])],
                    'author': {'login': api_data.get('user', {}).get('login', 'unknown')},
                    'createdAt': api_data.get('created_at'),
                    'comments': []  # API doesn't include comments in single issue call
                }

                logger.info(f"Successfully fetched issue via API: {issue_data['title']}")
                return {
                    "success": True,
                    "data": issue_data,
                    "source": "api"
                }

            except Exception as api_error:
                logger.error(f"API fallback also failed: {api_error}")
                return {
                    "success": False,
                    "error": f"Both gh CLI and API failed. gh CLI: {str(e)}, API: {str(api_error)}"
                }

    def analyze_codebase(self, issue_data: Dict[str, Any]) -> Dict[str, Any]:
        """Analyze codebase to understand context"""
        logger.info("Analyzing codebase...")

        title = issue_data.get('title', '').lower()
        body = issue_data.get('body', '').lower()
        labels = [label['name'].lower() for label in issue_data.get('labels', [])]

        analysis = {
            'issue_type': self._determine_issue_type(labels, title, body),
            'complexity': self._estimate_complexity(body),
            'affected_modules': self._identify_modules(title, body),
            'architecture': 'Clean Architecture',
            'test_strategy': self._plan_test_strategy(labels),
            'suggested_approach': self._suggest_approach(labels, title)
        }

        logger.info(f"Analysis complete: {analysis['issue_type']}, {analysis['complexity']}")
        return analysis

    def generate_fix(self, issue_data: Dict[str, Any],
                    analysis: Dict[str, Any]) -> Dict[str, Any]:
        """Generate code fix based on analysis"""
        logger.info(f"Generating fix for: {issue_data.get('title')}")

        # This is where you'd integrate with AI models (OpenAI, local LLM, etc.)
        # For now, return structured response

        return {
            "success": True,
            "changes": [],
            "tests": [],
            "message": "Fix generation placeholder - integrate with AI model",
            "approach": analysis['suggested_approach']
        }

    def run_tests(self, test_type: str = "all") -> Dict[str, Any]:
        """Run tests and collect results"""
        logger.info(f"Running tests: {test_type}")

        try:
            if test_type == "unit":
                cmd = ['./gradlew', 'testDebugUnitTest', 'jacocoTestReport']
            elif test_type == "instrumentation":
                cmd = ['./gradlew', 'connectedDebugAndroidTest']
            else:
                cmd = ['./scripts/run-tests-with-reports.sh']

            result = subprocess.run(cmd, capture_output=True, text=True, cwd=self.project_root)

            return {
                "success": result.returncode == 0,
                "output": result.stdout[-1000:] if result.stdout else "",  # Last 1000 chars
                "reports_path": "build/reports/"
            }
        except Exception as e:
            logger.error(f"Test execution failed: {e}")
            return {
                "success": False,
                "error": str(e)
            }

    def create_pull_request(self, branch_name: str, title: str,
                           body: str, issue_number: int) -> Dict[str, Any]:
        """Create a pull request"""
        logger.info(f"Creating PR for issue #{issue_number}")

        try:
            cmd = [
                'gh', 'pr', 'create',
                '--title', title,
                '--body', body,
                '--head', branch_name,
                '--base', 'main',
                '--draft',
                '--label', 'automated'
            ]

            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            pr_url = result.stdout.strip()

            # Link to issue
            try:
                subprocess.run([
                    'gh', 'issue', 'comment', str(issue_number),
                    '--body', f'🤖 Automated fix in progress: {pr_url}'
                ], check=False)
            except:
                pass  # Non-critical

            logger.info(f"PR created: {pr_url}")
            return {
                "success": True,
                "pr_url": pr_url
            }
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to create PR: {e.stderr}")
            return {
                "success": False,
                "error": str(e.stderr)
            }

    # Private helper methods

    def _determine_issue_type(self, labels: List[str], title: str, body: str) -> str:
        """Determine the type of issue"""
        if 'bug' in labels:
            return 'bug_fix'
        elif any(l in labels for l in ['feature', 'enhancement']):
            return 'feature'
        elif 'refactor' in labels or 'refactoring' in labels:
            return 'refactoring'
        elif 'performance' in labels:
            return 'performance'
        elif 'documentation' in labels or 'docs' in labels:
            return 'documentation'
        else:
            return 'general'

    def _estimate_complexity(self, body: str) -> str:
        """Estimate complexity based on description"""
        word_count = len(body.split())
        if word_count < 50:
            return 'low'
        elif word_count < 200:
            return 'medium'
        else:
            return 'high'

    def _identify_modules(self, title: str, body: str) -> List[str]:
        """Identify affected modules"""
        text = (title + ' ' + body).lower()
        modules = []

        keywords = {
            'presentation/contacts': ['contact', 'list', 'recyclerview', 'fragment'],
            'presentation/detail': ['detail', 'show', 'display', 'view'],
            'domain': ['usecase', 'business logic', 'repository interface'],
            'data': ['repository', 'database', 'room', 'cache', 'dao'],
            'di': ['dependency injection', 'hilt', 'module'],
            'testing': ['test', 'coverage', 'junit', 'mockk']
        }

        for module, words in keywords.items():
            if any(word in text for word in words):
                modules.append(module)

        return modules if modules else ['general']

    def _plan_test_strategy(self, labels: List[str]) -> Dict[str, bool]:
        """Plan testing strategy"""
        return {
            "unit_tests": True,
            "integration_tests": 'bug' in labels or 'feature' in labels,
            "ui_tests": False
        }

    def _suggest_approach(self, labels: List[str], title: str) -> str:
        """Suggest implementation approach"""
        if 'bug' in labels:
            return "1. Write failing test\n2. Implement fix\n3. Verify test passes\n4. Update docs if needed"
        elif 'feature' in labels:
            return "1. Design architecture\n2. Implement domain layer\n3. Implement data layer\n4. Implement presentation\n5. Add tests\n6. Update documentation"
        else:
            return "1. Analyze requirements\n2. Implement changes\n3. Add tests\n4. Update docs"


# Flask API endpoints
@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "service": "GitHub MCP Server",
        "timestamp": datetime.now().isoformat()
    })

@app.route('/tools', methods=['GET'])
def list_tools():
    """List available tools"""
    server = GitHubMCPServer()
    return jsonify({"tools": server.get_available_tools()})

@app.route('/execute', methods=['POST'])
def execute_tool():
    """Execute a tool"""
    data = request.json
    tool_name = data.get('tool')
    parameters = data.get('parameters', {})

    logger.info(f"Executing tool: {tool_name}")

    server = GitHubMCPServer()

    if tool_name == "fetch_github_issue":
        result = server.fetch_github_issue(**parameters)
    elif tool_name == "analyze_codebase":
        result = server.analyze_codebase(**parameters)
    elif tool_name == "generate_fix":
        result = server.generate_fix(**parameters)
    elif tool_name == "run_tests":
        result = server.run_tests(**parameters)
    elif tool_name == "create_pull_request":
        result = server.create_pull_request(**parameters)
    else:
        result = {"success": False, "error": f"Unknown tool: {tool_name}"}

    return jsonify(result)


if __name__ == "__main__":
    port = int(os.getenv('MCP_PORT', 8000))
    logger.info(f"Starting GitHub MCP Server on port {port}")
    app.run(host='0.0.0.0', port=port, debug=False)

