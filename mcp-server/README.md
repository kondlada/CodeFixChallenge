# 🤖 MCP Server & Intelligent Agent

Complete automation system for GitHub issue resolution with MCP (Model Context Protocol) server integration.

## 📋 Overview

This system provides end-to-end automation for processing GitHub issues and creating pull requests:

1. **GitHub MCP Server** - REST API that handles GitHub operations
2. **Intelligent Agent** - Orchestrates the complete workflow from issue to PR
3. **Integration** - Seamless connection between components

## 🏗️ Architecture

```
GitHub Issue (#42)
       ↓
[start-agent.sh] ← User triggers
       ↓
[MCP Server] ← Starts on port 8000
   ↓     ↑
   ↓     ↑ REST API calls
   ↓     ↑
[Intelligent Agent] ← Orchestrates workflow
   ↓
   ├─→ Fetch Issue (via MCP)
   ├─→ Analyze Codebase (via MCP)
   ├─→ Create Branch
   ├─→ Apply Fixes (manual prompt)
   ├─→ Run Tests (via MCP)
   ├─→ Commit Changes
   ├─→ Push Branch
   └─→ Create PR (via MCP)
       ↓
Draft PR Created ✅
```

## 📁 File Structure

```
CodeFixChallange/
├── mcp-server/
│   ├── __init__.py
│   ├── github_mcp_server.py      # MCP Server (Flask API)
│   ├── requirements.txt           # flask, flask-cors, requests
│   └── venv/                      # Virtual environment (auto-created)
│
├── agent/
│   ├── __init__.py
│   ├── intelligent_agent.py      # Intelligent Agent
│   ├── requirements.txt           # requests
│   └── venv/                      # Virtual environment (auto-created)
│
└── scripts/
    └── start-agent.sh             # Main startup script
```

## 🚀 Quick Start

### 1. Install Dependencies (First Time Only)

```bash
cd /Users/karthikkondlada/AndroidStudioProjects/CodeFixChallange

# MCP Server
cd mcp-server
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
deactivate

# Agent
cd ../agent
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
deactivate
```

### 2. Run Complete Automation

```bash
# Process issue #42 automatically
./scripts/start-agent.sh 42
```

That's it! The script will:
- ✅ Start MCP server automatically
- ✅ Fetch issue from GitHub
- ✅ Analyze codebase
- ✅ Create feature branch
- ✅ Prompt for fixes (manual step)
- ✅ Run all tests
- ✅ Commit and push
- ✅ Create draft PR
- ✅ Clean up resources

## 📖 Detailed Usage

### Option 1: Automated Workflow (Recommended)

```bash
./scripts/start-agent.sh <issue_number>
```

### Option 2: Manual MCP Server + Agent

**Terminal 1: Start MCP Server**
```bash
cd mcp-server
source venv/bin/activate
python github_mcp_server.py
# Server runs on http://localhost:8000
```

**Terminal 2: Run Agent**
```bash
cd agent
source venv/bin/activate
python intelligent_agent.py --issue 42
```

### Option 3: Test MCP Server Endpoints

```bash
# Health check
curl http://localhost:8000/health

# List available tools
curl http://localhost:8000/tools

# Execute a tool (fetch issue #42)
curl -X POST http://localhost:8000/execute \
  -H "Content-Type: application/json" \
  -d '{
    "tool": "fetch_github_issue",
    "parameters": {"issue_number": 42}
  }'
```

## 🛠️ MCP Server API

### Available Tools

1. **fetch_github_issue**
   - Fetches issue details from GitHub
   - Parameters: `issue_number` (int)

2. **analyze_codebase**
   - Analyzes project structure and issue context
   - Parameters: `issue_data` (object)

3. **generate_fix**
   - Generates code fix (placeholder for AI integration)
   - Parameters: `issue_data` (object), `analysis` (object)

4. **run_tests**
   - Runs tests and generates reports
   - Parameters: `test_type` (string, optional)

5. **create_pull_request**
   - Creates a draft PR on GitHub
   - Parameters: `branch_name`, `title`, `body`, `issue_number`

### Endpoints

- `GET /health` - Health check
- `GET /tools` - List available tools
- `POST /execute` - Execute a tool

## 🤖 Intelligent Agent Workflow

The agent orchestrates 8 steps:

1. **Fetch Issue** - Gets issue details from GitHub
2. **Analyze** - Determines type, complexity, affected modules
3. **Create Branch** - Creates `agent/issue-<number>-<title>` branch
4. **Apply Fixes** - Prompts user to make code changes
5. **Run Tests** - Executes full test suite
6. **Commit** - Commits changes with detailed message
7. **Push** - Pushes branch to origin
8. **Create PR** - Creates draft PR with comprehensive details

## 📊 Example Output

```
🚀 Starting Intelligent Agent Workflow
========================================
Issue: #42
Project: /Users/karthikkondlada/AndroidStudioProjects/CodeFixChallange

✅ MCP server running (PID: 12345)

🤖 Starting Intelligent Agent...

============================================================
🤖 Starting automated processing for issue #42
============================================================

📋 Step 1: Fetching issue details...
✅ Fetched: App crashes on empty contact list
   Author: kondlada
   State: open
   Labels: bug, automated

🔍 Step 2: Analyzing codebase...
✅ Analysis complete
   Type: bug_fix
   Complexity: medium
   Affected modules: presentation/contacts, domain
   Architecture: Clean Architecture

🌿 Step 3: Creating feature branch...
✅ Created branch: agent/issue-42-app-crashes-on-empty-contact-list

🔧 Step 4: Applying fixes...

Suggested approach:
   1. Write failing test
   2. Implement fix
   3. Verify test passes
   4. Update docs if needed

⚠️  MANUAL STEP REQUIRED:
   Please apply the necessary code changes to fix the issue.
   Once done, press Enter to continue...

[User makes changes and presses Enter]

✅ Proceeding with changes applied

🧪 Step 5: Running tests...
✅ All tests passed

💾 Step 6: Committing changes...
✅ Changes committed

⬆️  Step 7: Pushing branch...
✅ Branch pushed to origin

🔀 Step 8: Creating pull request...
✅ Pull request created successfully!
   URL: https://github.com/kondlada/CodeFixChallenge/pull/15

📌 Next steps:
   1. Review the PR on GitHub
   2. Check CI test results
   3. Mark PR as ready for review
   4. Request reviews from team
   5. Merge after approval

============================================================
✅ Successfully completed automated workflow!
============================================================

✨ Workflow completed successfully!

Next steps:
  1. Review the PR on GitHub
  2. Check CI test results
  3. Mark PR as ready for review
  4. Request reviews from team
  5. Merge after approval
```

## 🔧 Configuration

### Environment Variables

```bash
# Optional: Set custom MCP port (default: 8000)
export MCP_PORT=8000

# GitHub token (usually already set by gh CLI)
export GITHUB_TOKEN=your_token_here
```

## 🐛 Troubleshooting

### MCP Server Won't Start

```bash
# Check if port is already in use
lsof -i :8000

# Check logs
tail -f /tmp/mcp-server.log
```

### Agent Can't Connect to MCP

```bash
# Verify server is running
curl http://localhost:8000/health

# Start server manually
cd mcp-server
source venv/bin/activate
python github_mcp_server.py
```

### GitHub CLI Issues

```bash
# Check authentication
gh auth status

# Re-authenticate if needed
gh auth login
```

### Tests Failing

The agent will prompt you to continue anyway. You can:
- Press 'y' to continue despite failures
- Press 'n' to abort

## 🎯 Integration with AI Models

To add AI-powered code generation, edit `mcp-server/github_mcp_server.py`:

```python
def generate_fix(self, issue_data, analysis):
    # Option 1: OpenAI
    import openai
    response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[...]
    )
    
    # Option 2: Local LLM
    # Option 3: Custom MCP endpoint
    
    return {"success": True, "changes": [...]}
```

## 📚 Additional Documentation

- [CI/CD Setup Guide](../docs/CI_CD_SETUP.md)
- [Quick Start](../docs/CI_CD_QUICKSTART.md)
- [Architecture](../ARCHITECTURE.md)
- [Post-Implementation Checklist](../POST_IMPLEMENTATION_CHECKLIST.md)

## ✅ What's Included

✅ **Complete MCP Server** - REST API with 5 tools
✅ **Intelligent Agent** - Full workflow orchestration
✅ **Automated Startup** - One command to run everything
✅ **Error Handling** - Graceful failures and recovery
✅ **Logging** - Comprehensive audit trail
✅ **GitHub Integration** - Seamless issue and PR handling
✅ **Test Execution** - Automated testing with reports
✅ **Manual Override** - Control when needed
✅ **Clean Architecture** - Professional code structure
✅ **Documentation** - Complete guides and examples

## 🚀 Next Steps

1. **Test the system**: `./scripts/start-agent.sh 1`
2. **Review the PR** created by the agent
3. **Customize** the MCP server for your needs
4. **Integrate AI** for automated code generation
5. **Monitor** and improve based on results

---

**Questions?** Check the documentation or create an issue with the `question` label.

**Ready to automate!** 🎉

