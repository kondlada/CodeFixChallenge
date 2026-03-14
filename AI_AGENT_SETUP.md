# AI-Powered Agent Setup Guide

## Overview

The agent now supports **AI-powered code generation** using Large Language Models (LLMs) instead of just template-based fixes. This enables the agent to understand complex issues and generate intelligent, context-aware fixes.

---

## 🤖 Supported AI Models

### Option 1: Anthropic Claude (Recommended)
- **Model**: Claude 3.5 Sonnet
- **Best for**: Code generation, complex reasoning
- **Cost**: ~$3 per 1M input tokens, ~$15 per 1M output tokens
- **Get API Key**: https://console.anthropic.com/

### Option 2: OpenAI GPT
- **Model**: GPT-4 Turbo
- **Best for**: General purpose, widely supported
- **Cost**: ~$10 per 1M input tokens, ~$30 per 1M output tokens
- **Get API Key**: https://platform.openai.com/api-keys

---

## 📦 Installation

### Step 1: Install Python Dependencies

```bash
cd /Users/karthikkondlada/AndroidStudioProjects/CodeFixChallange

# Install AI dependencies
pip3 install -r requirements-ai.txt
```

This installs:
- `anthropic` - Anthropic Claude API client
- `openai` - OpenAI GPT API client

### Step 2: Get API Keys

#### For Anthropic Claude (Recommended):
1. Go to https://console.anthropic.com/
2. Sign up or log in
3. Navigate to API Keys
4. Create a new API key
5. Copy the key (starts with `sk-ant-...`)

#### For OpenAI GPT:
1. Go to https://platform.openai.com/
2. Sign up or log in
3. Navigate to API Keys
4. Create a new API key
5. Copy the key (starts with `sk-...`)

### Step 3: Configure API Keys

#### Option A: Environment Variables (Recommended)

```bash
# Add to your ~/.zshrc or ~/.bash_profile

# For Anthropic Claude
export ANTHROPIC_API_KEY='sk-ant-your-key-here'

# OR for OpenAI GPT
export OPENAI_API_KEY='sk-your-key-here'

# Reload shell
source ~/.zshrc  # or source ~/.bash_profile
```

#### Option B: .env File

```bash
# Copy example file
cp .env.example .env

# Edit .env and add your keys
nano .env
```

Add your keys:
```bash
ANTHROPIC_API_KEY=sk-ant-your-key-here
# OR
OPENAI_API_KEY=sk-your-key-here
```

Load environment:
```bash
# Before running agent
source .env
```

### Step 4: Verify Setup

```bash
# Test AI agent
python3 scripts/ai-fix-agent.py --help

# Should show:
# ✅ Using Anthropic Claude
# or
# ✅ Using OpenAI GPT
```

---

## 🚀 Usage

### Basic Usage (AI-Powered)

```bash
# Set API key
export ANTHROPIC_API_KEY='your-key-here'

# Run workflow - will automatically use AI
./scripts/complete-agent-workflow.sh <issue_number> 57111FDCH007MJ
```

The workflow will:
1. ✅ Detect API key automatically
2. ✅ Use AI to generate intelligent fixes
3. ✅ Fall back to templates if AI fails
4. ✅ Apply fixes and run tests

### Manual AI Fix Generation

```bash
# Generate fix with AI (dry-run)
python3 scripts/ai-fix-agent.py \
    --issue /tmp/issue_data.json \
    --dry-run

# Apply AI-generated fix
python3 scripts/ai-fix-agent.py \
    --issue /tmp/issue_data.json

# Specify model provider
python3 scripts/ai-fix-agent.py \
    --issue /tmp/issue_data.json \
    --model anthropic  # or 'openai'
```

### Template-Based Fallback

If no API keys are set, the agent automatically falls back to template-based fixes:

```bash
# No API keys set - uses templates
./scripts/complete-agent-workflow.sh 5 57111FDCH007MJ
```

Output:
```
ℹ️  No AI API keys found, using template-based fixes
   Set ANTHROPIC_API_KEY or OPENAI_API_KEY for AI-powered fixes
```

---

## 🧠 How AI Agent Works

### 1. Issue Analysis
```python
# AI receives:
- Issue title: "App crashes on contact click"
- Issue description: Full details
- Affected components: ContactsFragment, Navigation
- Current code: Full file contents
```

### 2. AI Prompt
```
You are an expert Android/Kotlin developer. Fix the following issue:

## Issue Details
- Title: App crashes on contact click
- Description: When clicking a contact...
- Components: ContactsFragment, Navigation

## Current Code
### ContactsFragment.kt
```kotlin
[full file content]
```

## Task
Generate a fix with:
1. Complete modified code
2. Explanation of changes
3. Any new files needed
```

### 3. AI Response
```json
{
  "fixes": [
    {
      "file": "app/.../ContactsFragment.kt",
      "content": "[complete fixed code]",
      "explanation": "Added try-catch around navigation..."
    }
  ],
  "summary": "Fixed crash by adding error handling"
}
```

### 4. Application
- Parses AI response
- Applies fixes to files
- Creates documentation
- Runs tests

---

## 📊 AI vs Template Comparison

| Feature | AI-Powered | Template-Based |
|---------|-----------|----------------|
| **Intelligence** | ✅ Understands context | ❌ Pattern matching only |
| **Flexibility** | ✅ Handles novel issues | ❌ Limited to predefined patterns |
| **Code Quality** | ✅ Idiomatic, clean | ⚠️ Generic templates |
| **Explanation** | ✅ Detailed reasoning | ❌ No explanation |
| **Cost** | 💰 API costs (~$0.01-0.10/fix) | ✅ Free |
| **Speed** | ⚠️ 5-30 seconds | ✅ Instant |
| **Reliability** | ⚠️ Requires internet | ✅ Works offline |

---

## 💰 Cost Estimation

### Typical Fix Cost

**Input tokens** (per fix):
- Issue description: ~200 tokens
- Code context (2-3 files): ~2,000 tokens
- Prompt template: ~300 tokens
- **Total input**: ~2,500 tokens

**Output tokens** (per fix):
- Fixed code: ~1,500 tokens
- Explanation: ~200 tokens
- **Total output**: ~1,700 tokens

**Cost per fix**:
- **Anthropic Claude**: ~$0.01 - $0.03
- **OpenAI GPT-4**: ~$0.05 - $0.10

**Monthly estimate** (100 fixes):
- **Anthropic**: ~$1 - $3
- **OpenAI**: ~$5 - $10

---

## 🔧 Configuration Options

### Model Selection

```bash
# Auto-detect (default)
python3 scripts/ai-fix-agent.py --model auto

# Force Anthropic
python3 scripts/ai-fix-agent.py --model anthropic

# Force OpenAI
python3 scripts/ai-fix-agent.py --model openai
```

### Environment Variables

```bash
# Model provider preference
export AI_MODEL_PROVIDER=anthropic  # or 'openai' or 'auto'

# API keys
export ANTHROPIC_API_KEY='sk-ant-...'
export OPENAI_API_KEY='sk-...'
```

---

## 🐛 Troubleshooting

### "No AI client available"

**Problem**: API keys not found

**Solution**:
```bash
# Check if keys are set
echo $ANTHROPIC_API_KEY
echo $OPENAI_API_KEY

# Set the key
export ANTHROPIC_API_KEY='your-key-here'
```

### "Anthropic API error: 401"

**Problem**: Invalid API key

**Solution**:
1. Check key is correct (starts with `sk-ant-`)
2. Verify key is active in console
3. Regenerate key if needed

### "Could not extract JSON from AI response"

**Problem**: AI response format issue

**Solution**:
- This is rare, agent will retry automatically
- Falls back to template-based fixes
- Check `/tmp/agent-workflow/fix_log.txt` for details

### "Module 'anthropic' not found"

**Problem**: Dependencies not installed

**Solution**:
```bash
pip3 install -r requirements-ai.txt
```

---

## 📝 Examples

### Example 1: Crash Fix with AI

```bash
# Issue: "App crashes when clicking contact"
export ANTHROPIC_API_KEY='your-key'
./scripts/complete-agent-workflow.sh 5 57111FDCH007MJ
```

**AI Output**:
```
🧠 Attempting AI-powered fix generation...
✅ Using Anthropic Claude
📂 Loading code context...
   Loaded 2 file(s)

🧠 Generating fix with AI...
✅ AI generated fix
   Summary: Added try-catch around navigation with user-friendly error message

📝 Generated 1 fix(es):
   - ContactsFragment.kt: Added error handling for navigation crashes

🔧 Applying fixes...
✅ Applied 1/1 fix(es)
📄 Documentation: docs/ai-fix-issue-5.md
```

### Example 2: Complex Issue with AI

```bash
# Issue: "Navigation fails when fragment not attached"
python3 scripts/ai-fix-agent.py \
    --issue issue_data.json \
    --model anthropic
```

**AI generates**:
- Lifecycle checks (`isAdded && view != null`)
- Safe navigation wrapper
- Proper error handling
- Detailed explanation

### Example 3: Fallback to Templates

```bash
# No API keys set
./scripts/complete-agent-workflow.sh 5 57111FDCH007MJ
```

**Output**:
```
ℹ️  No AI API keys found, using template-based fixes
   Set ANTHROPIC_API_KEY or OPENAI_API_KEY for AI-powered fixes

🔧 Applying fixes...
   Detected: Crash/Exception issue
   ✅ Applied error handling in ContactsFragment
```

---

## 🎯 Best Practices

### 1. Start with AI for Complex Issues
```bash
# Complex business logic, novel bugs
export ANTHROPIC_API_KEY='...'
./scripts/complete-agent-workflow.sh <issue>
```

### 2. Use Templates for Simple Patterns
```bash
# Simple null checks, common patterns
unset ANTHROPIC_API_KEY
./scripts/complete-agent-workflow.sh <issue>
```

### 3. Review AI-Generated Code
- Always review `docs/ai-fix-issue-{N}.md`
- Check the explanation makes sense
- Run tests before deploying

### 4. Monitor API Costs
```bash
# Check usage at:
# Anthropic: https://console.anthropic.com/settings/usage
# OpenAI: https://platform.openai.com/usage
```

---

## 🔒 Security

### API Key Safety

**DO**:
- ✅ Use environment variables
- ✅ Add `.env` to `.gitignore`
- ✅ Rotate keys regularly
- ✅ Use separate keys for dev/prod

**DON'T**:
- ❌ Commit keys to git
- ❌ Share keys in chat/email
- ❌ Use production keys for testing
- ❌ Hard-code keys in scripts

### .gitignore Entry

Already added:
```
.env
*.key
*_key.txt
```

---

## 📚 Additional Resources

### Anthropic Claude
- Documentation: https://docs.anthropic.com/
- API Reference: https://docs.anthropic.com/claude/reference/
- Pricing: https://www.anthropic.com/pricing

### OpenAI GPT
- Documentation: https://platform.openai.com/docs
- API Reference: https://platform.openai.com/docs/api-reference
- Pricing: https://openai.com/pricing

### Code Examples
- See `scripts/ai-fix-agent.py` for implementation
- See `AGENT_ARCHITECTURE_EXPLAINED.md` for architecture

---

## 🚀 Quick Start Checklist

- [ ] Install dependencies: `pip3 install -r requirements-ai.txt`
- [ ] Get API key from Anthropic or OpenAI
- [ ] Set environment variable: `export ANTHROPIC_API_KEY='...'`
- [ ] Test: `python3 scripts/ai-fix-agent.py --help`
- [ ] Run workflow: `./scripts/complete-agent-workflow.sh <issue> <device>`
- [ ] Review generated fixes in `docs/ai-fix-issue-{N}.md`
- [ ] Monitor API usage and costs

---

**Ready to use AI-powered fixes!** 🎉

The agent will automatically use AI when API keys are available, and fall back to templates when not.
