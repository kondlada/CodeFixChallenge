#!/usr/bin/env python3
"""
AI-Powered Fix Agent - Uses LLM (OpenAI/Anthropic) to generate intelligent fixes
Supports: OpenAI GPT-4, Anthropic Claude, or local models
"""

import json
import sys
import argparse
import os
from pathlib import Path
from typing import Optional, Dict, Any

# Try to import AI libraries
try:
    import anthropic
    ANTHROPIC_AVAILABLE = True
except ImportError:
    ANTHROPIC_AVAILABLE = False

try:
    import openai
    OPENAI_AVAILABLE = True
except ImportError:
    OPENAI_AVAILABLE = False


class AIFixAgent:
    """AI-powered agent that generates code fixes using LLMs"""
    
    def __init__(self, model_provider: str = "auto"):
        """
        Initialize AI agent
        
        Args:
            model_provider: "anthropic", "openai", or "auto" (detect from env)
        """
        self.model_provider = model_provider
        self.client = None
        self._setup_client()
    
    def _setup_client(self):
        """Setup AI client based on available API keys"""
        if self.model_provider == "auto":
            # Auto-detect based on environment variables
            if os.getenv("ANTHROPIC_API_KEY") and ANTHROPIC_AVAILABLE:
                self.model_provider = "anthropic"
            elif os.getenv("OPENAI_API_KEY") and OPENAI_AVAILABLE:
                self.model_provider = "openai"
            else:
                print("⚠️  No AI API keys found. Set ANTHROPIC_API_KEY or OPENAI_API_KEY", file=sys.stderr)
                return
        
        # Initialize client
        if self.model_provider == "anthropic" and ANTHROPIC_AVAILABLE:
            api_key = os.getenv("ANTHROPIC_API_KEY")
            if api_key:
                self.client = anthropic.Anthropic(api_key=api_key)
                print(f"✅ Using Anthropic Claude", file=sys.stderr)
        
        elif self.model_provider == "openai" and OPENAI_AVAILABLE:
            api_key = os.getenv("OPENAI_API_KEY")
            if api_key:
                openai.api_key = api_key
                self.client = openai
                print(f"✅ Using OpenAI GPT", file=sys.stderr)
    
    def generate_fix(self, issue_data: Dict[str, Any], code_context: Dict[str, str]) -> Optional[Dict[str, Any]]:
        """
        Generate fix using AI model
        
        Args:
            issue_data: Issue information from MCP client
            code_context: Dictionary of file_path -> file_content
        
        Returns:
            Dictionary with fixes: {file_path: new_content}
        """
        if not self.client:
            print("❌ No AI client available", file=sys.stderr)
            return None
        
        # Build prompt
        prompt = self._build_prompt(issue_data, code_context)
        
        # Generate fix
        if self.model_provider == "anthropic":
            return self._generate_with_anthropic(prompt)
        elif self.model_provider == "openai":
            return self._generate_with_openai(prompt)
        
        return None
    
    def _build_prompt(self, issue_data: Dict[str, Any], code_context: Dict[str, str]) -> str:
        """Build prompt for AI model"""
        issue = issue_data.get('issue', {})
        analysis = issue_data.get('analysis', {})
        
        prompt = f"""You are an expert Android/Kotlin developer. Fix the following issue:

## Issue Details
- **Title**: {issue.get('title')}
- **Description**: {issue.get('body')}
- **Type**: {analysis.get('type')}
- **Priority**: {analysis.get('priority')}
- **Affected Components**: {', '.join(analysis.get('components', []))}

## Current Code

"""
        
        # Add code context
        for file_path, content in code_context.items():
            prompt += f"\n### File: {file_path}\n```kotlin\n{content}\n```\n"
        
        prompt += """

## Task
Generate a fix for this issue. Provide:
1. The complete modified code for each file
2. Explanation of what was changed and why
3. Any additional files that need to be created

## Output Format
Respond with JSON in this exact format:
```json
{
  "fixes": [
    {
      "file": "path/to/file.kt",
      "content": "complete file content with fix applied",
      "explanation": "what was changed and why"
    }
  ],
  "summary": "brief summary of the fix"
}
```

Only output the JSON, nothing else.
"""
        
        return prompt
    
    def _generate_with_anthropic(self, prompt: str) -> Optional[Dict[str, Any]]:
        """Generate fix using Anthropic Claude"""
        try:
            message = self.client.messages.create(
                model="claude-3-5-sonnet-20241022",  # Latest Claude model
                max_tokens=4096,
                messages=[
                    {"role": "user", "content": prompt}
                ]
            )
            
            response_text = message.content[0].text
            
            # Extract JSON from response
            return self._extract_json(response_text)
            
        except Exception as e:
            print(f"❌ Anthropic API error: {e}", file=sys.stderr)
            return None
    
    def _generate_with_openai(self, prompt: str) -> Optional[Dict[str, Any]]:
        """Generate fix using OpenAI GPT"""
        try:
            response = self.client.ChatCompletion.create(
                model="gpt-4-turbo-preview",  # Latest GPT-4 model
                messages=[
                    {"role": "system", "content": "You are an expert Android/Kotlin developer who fixes code issues."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.2,  # Lower temperature for more consistent code
                max_tokens=4096
            )
            
            response_text = response.choices[0].message.content
            
            # Extract JSON from response
            return self._extract_json(response_text)
            
        except Exception as e:
            print(f"❌ OpenAI API error: {e}", file=sys.stderr)
            return None
    
    def _extract_json(self, text: str) -> Optional[Dict[str, Any]]:
        """Extract JSON from AI response"""
        import re
        
        # Try to find JSON block
        json_match = re.search(r'```json\s*(\{.*?\})\s*```', text, re.DOTALL)
        if json_match:
            try:
                return json.loads(json_match.group(1))
            except json.JSONDecodeError:
                pass
        
        # Try to parse entire response as JSON
        try:
            return json.loads(text)
        except json.JSONDecodeError:
            print(f"⚠️  Could not extract JSON from AI response", file=sys.stderr)
            return None


def load_code_context(project_root: Path, components: list) -> Dict[str, str]:
    """Load relevant code files based on affected components"""
    context = {}
    
    # Map components to file paths
    component_files = {
        'ContactsFragment': 'app/src/main/java/com/ai/codefixchallange/presentation/contacts/ContactsFragment.kt',
        'ContactsViewModel': 'app/src/main/java/com/ai/codefixchallange/presentation/contacts/ContactsViewModel.kt',
        'ContactDetailFragment': 'app/src/main/java/com/ai/codefixchallange/presentation/detail/ContactDetailFragment.kt',
        'ContactDetailViewModel': 'app/src/main/java/com/ai/codefixchallange/presentation/detail/ContactDetailViewModel.kt',
        'Navigation': 'app/src/main/res/navigation/nav_graph.xml',
        'ErrorHandling': 'app/src/main/java/com/ai/codefixchallange/presentation/contacts/ContactsFragment.kt',
    }
    
    # Load files for affected components
    for component in components:
        if component in component_files:
            file_path = project_root / component_files[component]
            if file_path.exists():
                try:
                    context[str(file_path.relative_to(project_root))] = file_path.read_text()
                except Exception as e:
                    print(f"⚠️  Could not read {file_path}: {e}", file=sys.stderr)
    
    return context


def apply_ai_fixes(project_root: Path, fixes: list) -> int:
    """Apply AI-generated fixes to files"""
    applied_count = 0
    
    for fix in fixes:
        file_path = project_root / fix['file']
        content = fix['content']
        explanation = fix.get('explanation', 'No explanation provided')
        
        print(f"\n📝 Applying fix to: {fix['file']}")
        print(f"   {explanation}")
        
        try:
            # Create parent directories if needed
            file_path.parent.mkdir(parents=True, exist_ok=True)
            
            # Write new content
            file_path.write_text(content)
            applied_count += 1
            print(f"   ✅ Applied")
            
        except Exception as e:
            print(f"   ❌ Failed: {e}", file=sys.stderr)
    
    return applied_count


def create_fix_documentation(project_root: Path, issue_data: Dict, ai_response: Dict):
    """Create documentation for AI-generated fix"""
    issue = issue_data.get('issue', {})
    issue_number = issue.get('number', 0)
    
    docs_dir = project_root / "docs"
    docs_dir.mkdir(exist_ok=True)
    
    doc_file = docs_dir / f"ai-fix-issue-{issue_number}.md"
    
    content = f"""# AI-Generated Fix for Issue #{issue_number}

## Issue
**Title**: {issue.get('title')}

**Description**:
{issue.get('body')}

## AI Analysis & Fix

**Model Used**: Claude/GPT (AI-powered)

**Summary**: {ai_response.get('summary', 'No summary provided')}

## Changes Applied

"""
    
    for fix in ai_response.get('fixes', []):
        content += f"""### {fix['file']}

**Explanation**: {fix.get('explanation', 'No explanation')}

```kotlin
{fix['content'][:500]}...
```

---

"""
    
    content += f"""
## Verification

Run the following to verify:
```bash
./gradlew testDebugUnitTest
./gradlew assembleDebug
```

## Notes

This fix was generated by an AI model based on the issue description and code context.
Please review carefully before deploying to production.

**Generated**: {ai_response.get('timestamp', 'Unknown')}
"""
    
    doc_file.write_text(content)
    return str(doc_file)


def main():
    parser = argparse.ArgumentParser(description='AI-Powered Fix Agent')
    parser.add_argument('--issue', required=True, help='Path to issue JSON file')
    parser.add_argument('--model', default='auto', choices=['auto', 'anthropic', 'openai'],
                       help='AI model provider to use')
    parser.add_argument('--dry-run', action='store_true', help='Show fixes without applying')
    
    args = parser.parse_args()
    
    # Read issue data
    try:
        with open(args.issue, 'r') as f:
            issue_data = json.load(f)
    except Exception as e:
        print(f"❌ Error reading issue data: {e}", file=sys.stderr)
        sys.exit(1)
    
    project_root = Path.cwd()
    
    print("🤖 AI-Powered Fix Agent")
    print("=" * 60)
    print()
    
    # Extract issue info
    issue = issue_data.get('issue', {})
    analysis = issue_data.get('analysis', {})
    
    print(f"📋 Issue: {issue.get('title')}")
    print(f"🔍 Components: {', '.join(analysis.get('components', []))}")
    print(f"🎯 Type: {analysis.get('type')}")
    print()
    
    # Initialize AI agent
    agent = AIFixAgent(model_provider=args.model)
    
    if not agent.client:
        print("❌ No AI client available. Please set API keys:", file=sys.stderr)
        print("   export ANTHROPIC_API_KEY='your-key'  # For Claude", file=sys.stderr)
        print("   export OPENAI_API_KEY='your-key'     # For GPT", file=sys.stderr)
        sys.exit(1)
    
    # Load code context
    print("📂 Loading code context...")
    code_context = load_code_context(project_root, analysis.get('components', []))
    print(f"   Loaded {len(code_context)} file(s)")
    print()
    
    # Generate fix using AI
    print("🧠 Generating fix with AI...")
    ai_response = agent.generate_fix(issue_data, code_context)
    
    if not ai_response:
        print("❌ Failed to generate fix", file=sys.stderr)
        sys.exit(1)
    
    print(f"✅ AI generated fix")
    print(f"   Summary: {ai_response.get('summary', 'No summary')}")
    print()
    
    # Show fixes
    fixes = ai_response.get('fixes', [])
    print(f"📝 Generated {len(fixes)} fix(es):")
    for fix in fixes:
        print(f"   - {fix['file']}: {fix.get('explanation', 'No explanation')[:60]}...")
    print()
    
    # Apply fixes
    if args.dry_run:
        print("🔍 Dry run mode - fixes not applied")
        print("\nTo apply fixes, run without --dry-run flag")
    else:
        print("🔧 Applying fixes...")
        applied = apply_ai_fixes(project_root, fixes)
        print(f"\n✅ Applied {applied}/{len(fixes)} fix(es)")
        
        # Create documentation
        doc_path = create_fix_documentation(project_root, issue_data, ai_response)
        print(f"📄 Documentation: {doc_path}")
    
    print()
    print("=" * 60)
    print("✅ AI Fix Agent Complete")
    print()
    print("📋 Next Steps:")
    print("   1. Review the generated fixes")
    print("   2. Run tests: ./gradlew testDebugUnitTest")
    print("   3. Build app: ./gradlew assembleDebug")
    print("   4. Verify on device")
    
    sys.exit(0)


if __name__ == '__main__':
    main()
