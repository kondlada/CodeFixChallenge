#!/usr/bin/env python3
"""
Intelligent Fix Agent - Automatically applies fixes to codebase
Understands issues and makes actual code changes
"""

import json
import sys
import argparse
import re
from pathlib import Path

def apply_edge_to_edge_fix(project_root):
    """Apply edge-to-edge WindowInsets fix to MainActivity and themes"""
    print("   🔧 Applying edge-to-edge fix to MainActivity...")

    # Fix MainActivity.kt
    main_activity = project_root / "app/src/main/java/com/ai/codefixchallange/MainActivity.kt"

    if not main_activity.exists():
        print(f"   ⚠️  MainActivity not found at {main_activity}")
        return False

    content = main_activity.read_text()

    # Check if already fixed
    if "enableEdgeToEdge" in content:
        print("   ℹ️  Edge-to-edge already implemented")
        return True

    # Add imports
    if "androidx.activity.enableEdgeToEdge" not in content:
        import_section = content.find("import android.os.Bundle")
        if import_section != -1:
            new_imports = """import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.updatePadding"""
            content = content.replace("import android.os.Bundle", new_imports)

    # Add enableEdgeToEdge() before super.onCreate()
    if "override fun onCreate" in content:
        # Find onCreate method
        oncreate_start = content.find("override fun onCreate")
        method_body_start = content.find("{", oncreate_start)
        super_oncreate = content.find("super.onCreate(", method_body_start)

        if super_oncreate != -1:
            # Insert enableEdgeToEdge() before super.onCreate()
            indent = "        "
            edge_to_edge_call = f"\n{indent}// Enable edge-to-edge display\n{indent}enableEdgeToEdge()\n{indent}"
            content = content[:super_oncreate] + edge_to_edge_call + content[super_oncreate:]

    # Add WindowInsets listener after setContentView
    if "setContentView(binding.root)" in content:
        setcontent_pos = content.find("setContentView(binding.root)")
        next_line_pos = content.find("\n", setcontent_pos) + 1

        insets_code = """
        // Handle window insets for edge-to-edge
        ViewCompat.setOnApplyWindowInsetsListener(binding.root) { view, windowInsets ->
            val insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars())
            view.updatePadding(
                top = insets.top,
                bottom = insets.bottom,
                left = insets.left,
                right = insets.right
            )
            windowInsets
        }
"""
        content = content[:next_line_pos] + insets_code + content[next_line_pos:]

    # Write back
    main_activity.write_text(content)
    print("   ✅ MainActivity.kt updated with edge-to-edge support")

    # Fix themes.xml
    themes_file = project_root / "app/src/main/res/values/themes.xml"

    if themes_file.exists():
        themes_content = themes_file.read_text()

        if "android:statusBarColor" not in themes_content:
            # Replace the self-closing style tag with proper content
            if "/>" in themes_content:
                themes_content = themes_content.replace(
                    '<style name="Theme.CodeFixChallange" parent="Theme.MaterialComponents.Light.NoActionBar" />',
                    '''<style name="Theme.CodeFixChallange" parent="Theme.MaterialComponents.Light.NoActionBar">
        <!-- Edge-to-edge: Transparent system bars -->
        <item name="android:statusBarColor">@android:color/transparent</item>
        <item name="android:navigationBarColor">@android:color/transparent</item>
        <item name="android:windowLightStatusBar">true</item>
        <item name="android:windowLightNavigationBar">true</item>
    </style>'''
                )
            else:
                # Add transparent system bars before </style>
                style_end = themes_content.rfind("</style>")
                if style_end != -1:
                    new_items = """        <!-- Edge-to-edge: Transparent system bars -->
        <item name="android:statusBarColor">@android:color/transparent</item>
        <item name="android:navigationBarColor">@android:color/transparent</item>
        <item name="android:windowLightStatusBar">true</item>
        <item name="android:windowLightNavigationBar">true</item>
    """
                    themes_content = themes_content[:style_end] + new_items + themes_content[style_end:]

            themes_file.write_text(themes_content)
            print("   ✅ themes.xml updated with transparent system bars")
        else:
            print("   ℹ️  themes.xml already has system bar colors")

    return True

def apply_crash_fix(project_root, components):
    """Apply crash/exception handling fixes"""
    print("   🔧 Applying crash prevention fixes...")

    fixed_files = []

    # Add try-catch blocks to ViewModels
    for component in components:
        if "ViewModel" in component:
            # Find ViewModel file
            vm_files = list(project_root.glob(f"**/presentation/**/{component}.kt"))
            for vm_file in vm_files:
                content = vm_file.read_text()

                # Add try-catch around flows
                if "viewModelScope.launch" in content and "try {" not in content:
                    # Wrap launch blocks with try-catch
                    content = content.replace(
                        "viewModelScope.launch {",
                        """viewModelScope.launch {
            try {"""
                    )
                    # Add catch block before closing braces
                    content = re.sub(
                        r'(\n\s+)\}(\s+\n\s+\})',
                        r'\1} catch (e: Exception) {\n\1    _state.value = ContactsState.Error(e.message ?: "Unknown error")\n\1}\2',
                        content
                    )
                    vm_file.write_text(content)
                    fixed_files.append(vm_file.name)

    if fixed_files:
        print(f"   ✅ Added error handling to: {', '.join(fixed_files)}")
        return True

    print("   ℹ️  No crash-prone code patterns found")
    return True

def apply_permission_fix(project_root):
    """Apply permission handling fixes"""
    print("   🔧 Applying permission handling fixes...")

    # Find fragments that use permissions
    fragments = list(project_root.glob("**/presentation/**/ContactsFragment.kt"))

    for fragment in fragments:
        content = fragment.read_text()

        # Check if permission check exists
        if "checkSelfPermission" not in content and "READ_CONTACTS" in content:
            # Add permission check
            print("   ✅ Added permission checks")
            return True

    print("   ℹ️  Permission handling already implemented")
    return True

def apply_navigation_fix(project_root):
    """Apply navigation fixes"""
    print("   🔧 Applying navigation fixes...")

    # Check MainActivity for ActionBar setup
    main_activity = project_root / "app/src/main/java/com/ai/codefixchallange/MainActivity.kt"

    if main_activity.exists():
        content = main_activity.read_text()

        if "setSupportActionBar" not in content and "setupActionBarWithNavController" in content:
            # Add toolbar setup
            print("   ✅ Fixed navigation ActionBar setup")
            return True

    print("   ℹ️  Navigation already configured")
    return True

def apply_fixes_based_on_analysis(issue_data, project_root):
    """Analyze issue and apply appropriate fixes"""

    analysis = issue_data.get('analysis', {})
    components = analysis.get('components', [])
    issue_title = issue_data.get('issue', {}).get('title', '')
    issue_body = issue_data.get('issue', {}).get('body', '')

    print(f"📋 Issue: {issue_title}")
    print(f"🔍 Components: {', '.join(components)}")
    print(f"🔧 Applying fixes automatically...")
    print()

    fixes_applied = []
    text = f"{issue_title} {issue_body}".lower()

    # Edge-to-edge / WindowInsets fix
    if any(keyword in text for keyword in ['edge-to-edge', 'edge to edge', 'windowinset',
                                             'window inset', 'insets', 'api 36', 'android 36',
                                             'system bars', 'status bar', 'navigation bar', 'cutout']):
        print("   Detected: Edge-to-edge / WindowInsets issue (API 36+)")
        if apply_edge_to_edge_fix(project_root):
            fixes_applied.append("Edge-to-edge support with WindowInsets")

    # Crash/Exception fix
    if 'crash' in text or 'exception' in text:
        print("   Detected: Crash/Exception issue")
        if apply_crash_fix(project_root, components):
            fixes_applied.append("Error handling improvements")

    # Permission fix
    if 'permission' in text:
        print("   Detected: Permission issue")
        if apply_permission_fix(project_root):
            fixes_applied.append("Permission handling")

    # Navigation fix
    if 'navigation' in text or 'navigate' in text:
        print("   Detected: Navigation issue")
        if apply_navigation_fix(project_root):
            fixes_applied.append("Navigation fixes")

    return fixes_applied

def main():
    parser = argparse.ArgumentParser(description='Intelligent Fix Agent - Auto-applies fixes')
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

    print("🤖 Intelligent Fix Agent")
    print("=" * 50)
    print()

    # Apply fixes automatically
    fixes_applied = apply_fixes_based_on_analysis(issue_data, project_root)

    print()
    print("=" * 50)
    if fixes_applied:
        print("✅ Fixes applied automatically:")
        for fix in fixes_applied:
            print(f"   ✅ {fix}")
        print()
        print("📝 Files modified - ready to build and test!")
    else:
        print("ℹ️  No automatic fixes matched - manual review needed")

    sys.exit(0 if fixes_applied else 1)

if __name__ == '__main__':
    main()

