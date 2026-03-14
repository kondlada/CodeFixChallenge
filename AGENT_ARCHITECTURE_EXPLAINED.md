# Agent Architecture Explained

## Overview

This agent is a **rule-based automation system** (not AI/ML-based) that uses pattern matching and code templates to fix common Android issues. Let me explain how it works and how to build similar agents.

---

## 🤖 Is This Using AI Models?

### **No AI/ML Models Used**

This agent is **NOT** using:
- ❌ GPT/Claude/LLMs for code generation
- ❌ Machine learning models
- ❌ Neural networks
- ❌ Training data

### **What It Actually Uses**

This is a **rule-based expert system** using:
- ✅ Pattern matching (regex, keyword detection)
- ✅ Code templates (predefined fixes)
- ✅ Heuristics (if-then rules)
- ✅ Shell scripting + Python

**Think of it as:** A smart automation script, not an AI agent.

---

## 📐 Agent Architecture

### High-Level Flow

```
┌─────────────────────────────────────────────────────────┐
│                   ORCHESTRATOR                          │
│         (complete-agent-workflow.sh)                    │
│                                                         │
│  Controls all 10 phases of the workflow                │
└─────────────────────────────────────────────────────────┘
                         │
        ┌────────────────┼────────────────┐
        ▼                ▼                ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ MCP Client   │  │  Fix Agent   │  │ Test Runner  │
│ (Python)     │  │  (Python)    │  │  (Shell)     │
└──────────────┘  └──────────────┘  └──────────────┘
        │                │                │
        ▼                ▼                ▼
   GitHub API      Code Files        Gradle Tests
```

### Component Breakdown

#### 1. **Orchestrator** (`complete-agent-workflow.sh`)
- **Language**: Bash shell script
- **Purpose**: Coordinates all phases
- **Key responsibilities**:
  - Calls other scripts in sequence
  - Manages state between phases
  - Handles verification logic
  - Decides whether to close issues

#### 2. **MCP Client** (`mcp-client.py`)
- **Language**: Python 3
- **Purpose**: Fetches and analyzes GitHub issues
- **Key responsibilities**:
  - Fetches issue from GitHub API
  - Analyzes issue text for patterns
  - Identifies affected components
  - Outputs structured JSON

#### 3. **Fix Agent** (`simple-fix-agent.py`)
- **Language**: Python 3
- **Purpose**: Applies code fixes
- **Key responsibilities**:
  - Reads issue analysis
  - Matches patterns to fix templates
  - Modifies code files
  - Creates documentation

#### 4. **Test Runner** (`test-runner.sh`)
- **Language**: Bash shell script
- **Purpose**: Executes tests and parses results
- **Key responsibilities**:
  - Runs Gradle tests
  - Parses JUnit XML
  - Generates coverage reports

---

## 🔍 How Pattern Matching Works

### Step 1: Issue Analysis (MCP Client)

```python
def analyze_components(title, body):
    """Analyze issue to identify affected components"""
    text = f"{title} {body}".lower()
    components = []
    
    # Pattern matching with keywords
    if 'contact' in text or 'recyclerview' in text:
        components.append('ContactsViewModel')
        components.append('ContactsFragment')
    
    if 'crash' in text or 'exception' in text:
        components.append('ErrorHandling')
    
    if 'navigation' in text or 'navigate' in text:
        components.append('Navigation')
    
    return components
```

**How it works:**
1. Converts issue title + body to lowercase
2. Searches for keywords: "crash", "navigation", "contact", etc.
3. Maps keywords to code components
4. Returns list of affected components

**Example:**
```
Input: "App crashes when clicking contact"
Keywords found: "crash", "contact"
Components identified: ['ErrorHandling', 'ContactsFragment']
```

### Step 2: Fix Selection (Fix Agent)

```python
def apply_fix_based_on_components(issue_data, project_root):
    text = f"{issue_title} {issue_body}".lower()
    
    # Rule 1: Crash/Exception fixes
    if 'crash' in text or 'exception' in text:
        apply_crash_fix(project_root)
    
    # Rule 2: Navigation fixes
    if 'navigation' in text or 'navigate' in text:
        apply_navigation_fix(project_root)
    
    # Rule 3: Null safety fixes
    if 'null' in text:
        apply_null_safety_fix(project_root)
```

**How it works:**
1. Checks issue text against predefined patterns
2. Calls appropriate fix function
3. Each fix function has a template

### Step 3: Code Modification (Template-Based)

```python
def apply_crash_fix(project_root):
    """Apply crash/exception handling fixes"""
    file_path = project_root / "app/.../ContactsFragment.kt"
    content = file_path.read_text()
    
    # Template: OLD code pattern
    old_code = """        adapter = ContactsAdapter { contact ->
            findNavController().navigate(action)
        }"""
    
    # Template: NEW code pattern
    new_code = """        adapter = ContactsAdapter { contact ->
            try {
                findNavController().navigate(action)
            } catch (e: Exception) {
                Toast.makeText(context, "Error: ${e.message}").show()
            }
        }"""
    
    # String replacement
    if old_code in content:
        content = content.replace(old_code, new_code)
        file_path.write_text(content)
        return True
```

**How it works:**
1. Reads the entire file as text
2. Searches for exact string match (old pattern)
3. Replaces with new pattern (template)
4. Writes modified content back to file

---

## 🛠️ Fix Templates

The agent has predefined templates for common fixes:

### Template 1: Crash Handling
```kotlin
// BEFORE
findNavController().navigate(action)

// AFTER
try {
    findNavController().navigate(action)
} catch (e: Exception) {
    Toast.makeText(context, "Error: ${e.message}").show()
}
```

### Template 2: Navigation Safety
```kotlin
// BEFORE
findNavController().navigateUp()

// AFTER
if (isAdded && view != null) {
    findNavController().navigateUp()
}
```

### Template 3: Null Safety
```kotlin
// BEFORE
binding.contactName.text = contact.name

// AFTER
binding.contactName.text = contact.name ?: "Unknown"
```

---

## 🔄 Workflow Execution

### Phase-by-Phase Breakdown

```bash
#!/bin/bash
# complete-agent-workflow.sh

# PHASE 1: Fetch Issue
python3 scripts/mcp-client.py $ISSUE_NUMBER > issue_data.json

# PHASE 2: Capture Before Screenshot
./scripts/screenshot-capture.sh before $ISSUE_NUMBER $DEVICE

# PHASE 3: Apply Fix
python3 scripts/simple-fix-agent.py --issue issue_data.json

# PHASE 4: Build & Install
./gradlew clean assembleDebug
./gradlew installDebug

# PHASE 5: Capture After Screenshot
./scripts/screenshot-capture.sh after $ISSUE_NUMBER $DEVICE

# PHASE 6: Run Tests
./scripts/test-runner.sh > test_results.txt
# Parse actual results from JUnit XML
UNIT_TOTAL=$(grep -o 'tests="[0-9]*"' TEST-*.xml | grep -o '[0-9]*')
UNIT_FAILED=$(grep -o 'failures="[0-9]*"' TEST-*.xml | grep -o '[0-9]*')

# PHASE 7-8: Generate reports
python3 scripts/generate-test-charts.py
cat > fix-report.md << EOF
# Fix Report
...
EOF

# PHASE 9: Commit & Push
git add .
git commit -m "fix: Issue #$ISSUE_NUMBER"
git push origin main

# PHASE 10: Close Issue (with verification)
if [ "$CODE_CHANGED" = "true" ] && [ "$TESTS_PASSED" = "true" ]; then
    gh issue close $ISSUE_NUMBER
fi
```

---

## 🧠 Decision Logic (Verification Gates)

### Verification Algorithm

```bash
# Step 1: Check if code was modified
CODE_CHANGED=false
git diff --quiet HEAD -- app/ || CODE_CHANGED=true

# Step 2: Check if tests passed
if [ $UNIT_FAILED -eq 0 ] && [ $UNIT_TOTAL -gt 0 ]; then
    TESTS_PASSED=true
else
    TESTS_PASSED=false
fi

# Step 3: Decide whether to close issue
SHOULD_CLOSE=false

if [ "$CODE_CHANGED" = "true" ] && [ "$TESTS_PASSED" = "true" ]; then
    SHOULD_CLOSE=true
    # Close the issue
    gh issue close $ISSUE_NUMBER
else
    # Just comment, don't close
    gh issue comment $ISSUE_NUMBER --body "Needs review"
fi
```

**Decision Tree:**
```
                    Start
                      │
                      ▼
              Code Changed?
                 /        \
               Yes         No
                │           │
                ▼           ▼
          Tests Passed?   Comment Only
             /      \      (Don't Close)
           Yes      No
            │        │
            ▼        ▼
      Close Issue  Comment Only
                   (Don't Close)
```

---

## 📊 Data Flow

### 1. Issue Data Structure (JSON)

```json
{
  "source": "gh-cli",
  "timestamp": "2026-03-14T02:00:00Z",
  "issue": {
    "number": 5,
    "title": "App crashes on contact click",
    "body": "When clicking a contact, the app crashes...",
    "state": "open",
    "labels": ["bug", "crash"],
    "author": "kondlada"
  },
  "analysis": {
    "components": ["ContactsFragment", "Navigation", "ErrorHandling"],
    "priority": "high",
    "type": "bug"
  },
  "metadata": {
    "repo": "kondlada/CodeFixChallenge",
    "fetched_at": "2026-03-14T02:00:00Z"
  }
}
```

### 2. Fix Agent Processing

```python
# Read issue data
with open('issue_data.json') as f:
    issue_data = json.load(f)

# Extract information
title = issue_data['issue']['title']
body = issue_data['issue']['body']
components = issue_data['analysis']['components']

# Apply fixes based on analysis
if 'ErrorHandling' in components:
    apply_crash_fix()
if 'Navigation' in components:
    apply_navigation_fix()
```

### 3. Test Results (JUnit XML)

```xml
<testsuite name="ContactsViewModelTest" tests="15" failures="0" errors="0">
  <testcase name="testGetContacts" classname="...ContactsViewModelTest"/>
  <testcase name="testSyncContacts" classname="...ContactsViewModelTest"/>
  ...
</testsuite>
```

Parsed to:
```bash
UNIT_TOTAL=15
UNIT_FAILED=0
UNIT_PASSED=15
TESTS_PASSED=true
```

---

## 🏗️ How to Build Your Own Agent

### Step 1: Define Your Domain

```python
# What problems will your agent solve?
PROBLEM_DOMAINS = {
    'crash': ['exception', 'crash', 'error'],
    'performance': ['slow', 'lag', 'freeze'],
    'ui': ['button', 'layout', 'display']
}
```

### Step 2: Create Fix Templates

```python
FIX_TEMPLATES = {
    'crash': {
        'pattern': r'findNavController\(\)\.navigate\(([^)]+)\)',
        'replacement': '''try {
    findNavController().navigate(\1)
} catch (e: Exception) {
    Log.e(TAG, "Navigation error", e)
}'''
    },
    'null_safety': {
        'pattern': r'\.text = ([a-zA-Z.]+)',
        'replacement': r'.text = \1 ?: "Unknown"'
    }
}
```

### Step 3: Build Pattern Matcher

```python
def analyze_issue(title, body):
    """Identify problem type from issue text"""
    text = f"{title} {body}".lower()
    
    problems = []
    for problem_type, keywords in PROBLEM_DOMAINS.items():
        if any(keyword in text for keyword in keywords):
            problems.append(problem_type)
    
    return problems
```

### Step 4: Implement Fix Application

```python
def apply_fix(file_path, fix_template):
    """Apply fix template to file"""
    content = file_path.read_text()
    
    # Use regex for pattern matching
    import re
    pattern = fix_template['pattern']
    replacement = fix_template['replacement']
    
    modified = re.sub(pattern, replacement, content)
    
    if modified != content:
        file_path.write_text(modified)
        return True
    return False
```

### Step 5: Add Verification

```python
def verify_fix(project_root):
    """Verify the fix worked"""
    # Run tests
    result = subprocess.run(
        ['./gradlew', 'test'],
        capture_output=True,
        cwd=project_root
    )
    
    # Parse results
    if result.returncode == 0:
        return True
    return False
```

### Step 6: Create Orchestrator

```bash
#!/bin/bash
# orchestrator.sh

# 1. Fetch issue
python3 fetch_issue.py $1 > issue.json

# 2. Analyze and fix
python3 fix_agent.py --issue issue.json

# 3. Verify
if python3 verify.py; then
    echo "Fix successful"
    git commit -am "Auto-fix: Issue #$1"
    git push
else
    echo "Fix failed, needs manual review"
fi
```

---

## 🎯 Key Design Principles

### 1. **Idempotency**
- Agent can be run multiple times safely
- Checks if fix already applied before modifying
- Skips existing screenshots/reports

### 2. **Fail-Safe**
- Never closes issue if verification fails
- Always creates documentation
- Preserves original code in git history

### 3. **Transparency**
- Logs every action
- Creates detailed reports
- Shows what was changed and why

### 4. **Modularity**
- Each phase is independent
- Can run phases separately
- Easy to add new fix templates

---

## 🔧 Technologies Used

### Languages
- **Python 3**: Fix agent, MCP client, chart generation
- **Bash**: Orchestration, test running, device automation
- **Kotlin**: Target language being fixed

### Tools
- **Git**: Version control, change detection
- **GitHub CLI (`gh`)**: Issue management
- **ADB**: Android device communication
- **Gradle**: Build system, test runner

### Libraries
- **Python stdlib**: `json`, `subprocess`, `pathlib`, `re`
- **matplotlib** (optional): Chart generation
- **JUnit**: Test framework (parsed by agent)

---

## 📈 Limitations & Future Improvements

### Current Limitations

1. **Pattern-based only**: Can't understand complex logic
2. **Fixed templates**: Limited to predefined fixes
3. **No learning**: Doesn't improve from past fixes
4. **Language-specific**: Only works with Kotlin/Android

### How to Add AI/ML

To make this a true AI agent, you could:

#### Option 1: Add LLM Integration
```python
import openai

def generate_fix_with_ai(issue_text, code_context):
    """Use GPT to generate fix"""
    prompt = f"""
    Issue: {issue_text}
    
    Current code:
    {code_context}
    
    Generate a fix for this issue.
    """
    
    response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}]
    )
    
    return response.choices[0].message.content
```

#### Option 2: Train Custom Model
```python
# Collect training data
training_data = [
    {"issue": "crash on click", "fix": "add try-catch"},
    {"issue": "null pointer", "fix": "add null check"},
    ...
]

# Train classifier
from sklearn.ensemble import RandomForestClassifier
model = RandomForestClassifier()
model.fit(X_train, y_train)

# Predict fix type
fix_type = model.predict([issue_features])
```

#### Option 3: Use Code Analysis AI
```python
from transformers import AutoModelForCausalLM

# Use CodeBERT or similar
model = AutoModelForCausalLM.from_pretrained("microsoft/codebert-base")

# Generate code fix
generated_code = model.generate(
    input_ids=tokenized_issue,
    max_length=200
)
```

---

## 🎓 Learning Resources

### To Build Similar Agents

1. **Pattern Matching**: Learn regex, string manipulation
2. **Shell Scripting**: Bash automation, process control
3. **Git Automation**: Git commands, hooks, workflows
4. **API Integration**: REST APIs, JSON parsing
5. **Testing**: JUnit, test automation, CI/CD

### To Add AI/ML

1. **LLM Integration**: OpenAI API, Anthropic Claude
2. **Code Models**: CodeBERT, CodeT5, StarCoder
3. **Fine-tuning**: Training on your codebase
4. **Prompt Engineering**: Crafting effective prompts
5. **Vector Databases**: Semantic search for similar issues

---

## 📝 Summary

### What This Agent Is
- ✅ Rule-based automation system
- ✅ Pattern matching + code templates
- ✅ Orchestrated workflow
- ✅ Verification-based decision making

### What This Agent Is NOT
- ❌ AI/ML model
- ❌ Learning system
- ❌ General-purpose code generator
- ❌ Replacement for human developers

### Best Use Cases
- ✅ Repetitive bug fixes
- ✅ Code style enforcement
- ✅ Common error patterns
- ✅ Automated testing workflows

### When to Use Human Developers
- ⚠️ Complex business logic
- ⚠️ Architecture decisions
- ⚠️ Novel problems
- ⚠️ Performance optimization

---

**The agent is a smart automation tool, not an AI. It's powerful for repetitive tasks but limited to predefined patterns.**
