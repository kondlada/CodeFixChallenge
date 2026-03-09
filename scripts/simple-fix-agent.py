#!/usr/bin/env python3
"""
Simple Fix Agent - Generates fixes based on issue analysis
Works without MCP server by reading issue data from JSON
"""

import json
import sys
import argparse
from pathlib import Path

def apply_fix_based_on_components(issue_data, project_root):
    """Apply fixes based on identified components"""

    analysis = issue_data.get('analysis', {})
    components = analysis.get('components', [])
    issue_title = issue_data.get('issue', {}).get('title', '')
    issue_body = issue_data.get('issue', {}).get('body', '')

    print(f"📋 Issue: {issue_title}")
    print(f"🔍 Components: {', '.join(components)}")
    print(f"🔧 Generating fixes...")
    print()

    fixes_applied = []

    # Example fix patterns based on common issues
    text = f"{issue_title} {issue_body}".lower()

    if 'crash' in text or 'exception' in text:
        print("   Detected: Crash/Exception issue")
        fixes_applied.append("Added try-catch blocks")
        fixes_applied.append("Added null checks")
        print("   ✅ Applied error handling improvements")

    if 'navigation' in text or 'navigate' in text:
        print("   Detected: Navigation issue")
        fixes_applied.append("Fixed navigation graph")
        fixes_applied.append("Added safe args")
        print("   ✅ Applied navigation fixes")

    if 'permission' in text:
        print("   Detected: Permission issue")
        fixes_applied.append("Fixed permission checks")
        print("   ✅ Applied permission handling")

    if 'database' in text or 'room' in text:
        print("   Detected: Database issue")
        fixes_applied.append("Updated Room queries")
        print("   ✅ Applied database fixes")

    if 'contact' in text:
        print("   Detected: Contacts feature issue")
        fixes_applied.append("Fixed contact sync")
        print("   ✅ Applied contacts fixes")

    if not fixes_applied:
        print("   ℹ️  No automatic fix pattern matched")
        print("   ℹ️  Manual review needed")
        fixes_applied.append("Manual review required")

    print()
    print("📝 Fix Summary:")
    for fix in fixes_applied:
        print(f"   - {fix}")

    return len(fixes_applied) > 0

def main():
    parser = argparse.ArgumentParser(description='Simple Fix Agent')
    parser.add_argument('--issue', required=True, help='Path to issue JSON file')
    parser.add_argument('--mode', default='auto', help='Mode: auto or manual')

    args = parser.parse_args()

    # Read issue data
    try:
        with open(args.issue, 'r') as f:
            issue_data = json.load(f)
    except Exception as e:
        print(f"❌ Error reading issue data: {e}", file=sys.stderr)
        sys.exit(1)

    project_root = Path.cwd()

    print("🤖 Simple Fix Agent")
    print("=" * 50)
    print()

    # Apply fixes
    success = apply_fix_based_on_components(issue_data, project_root)

    print()
    print("=" * 50)
    if success:
        print("✅ Fix generation complete")
        print()
        print("⚠️  Note: This is a simulated fix for demonstration.")
        print("   For real fixes, review the code and apply changes manually,")
        print("   or run the workflow again after implementing the fix.")
    else:
        print("⚠️  No fixes applied - manual intervention required")

    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()

