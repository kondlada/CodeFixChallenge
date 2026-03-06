#!/bin/bash

# CI/CD Setup Validation Script
# Checks if all required files and tools are properly configured

set -e

echo "🔍 CI/CD Setup Validation"
echo "=================================="
echo ""

ERRORS=0
WARNINGS=0

# Function to check file exists
check_file() {
    if [ -f "$1" ]; then
        echo "✅ $1"
    else
        echo "❌ $1 - MISSING"
        ((ERRORS++))
    fi
}

# Function to check directory exists
check_dir() {
    if [ -d "$1" ]; then
        echo "✅ $1/"
    else
        echo "❌ $1/ - MISSING"
        ((ERRORS++))
    fi
}

# Function to check command exists
check_command() {
    if command -v "$1" &> /dev/null; then
        VERSION=$($1 --version 2>&1 | head -1)
        echo "✅ $1 - $VERSION"
    else
        echo "⚠️  $1 - NOT INSTALLED"
        ((WARNINGS++))
    fi
}

# Function to check file is executable
check_executable() {
    if [ -x "$1" ]; then
        echo "✅ $1 - executable"
    else
        echo "⚠️  $1 - not executable (run: chmod +x $1)"
        ((WARNINGS++))
    fi
}

echo "📁 Checking Files..."
echo "-------------------"

# GitHub workflows
check_file ".github/workflows/ci.yml"
check_file ".github/workflows/pr-automation.yml"
check_file ".github/workflows/code-quality.yml"

# Issue templates
check_file ".github/ISSUE_TEMPLATE/bug_report.md"
check_file ".github/ISSUE_TEMPLATE/feature_request.md"

# PR template
check_file ".github/PULL_REQUEST_TEMPLATE.md"

# CODEOWNERS
check_file ".github/CODEOWNERS"

# Scripts
check_file "scripts/agent-workflow.sh"
check_file "scripts/fetch-github-issue.sh"
check_file "scripts/create-pr.sh"
check_file "scripts/run-tests-with-reports.sh"
check_file "scripts/mcp-integration.py"

# Documentation
check_file "docs/CI_CD_SETUP.md"
check_file "docs/CI_CD_QUICKSTART.md"
check_file "CI_CD_IMPLEMENTATION_SUMMARY.md"

# Configuration
check_file ".editorconfig"

echo ""
echo "🔧 Checking Tools..."
echo "-------------------"

check_command "gh"
check_command "jq"
check_command "python3"
check_command "git"

echo ""
echo "🔐 Checking Permissions..."
echo "-------------------------"

check_executable "scripts/agent-workflow.sh"
check_executable "scripts/fetch-github-issue.sh"
check_executable "scripts/create-pr.sh"
check_executable "scripts/run-tests-with-reports.sh"
check_executable "generate-reports.sh"

echo ""
echo "🔗 Checking Git Configuration..."
echo "--------------------------------"

# Check if in git repo
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "✅ Git repository initialized"

    # Check remote
    if git remote get-url origin > /dev/null 2>&1; then
        REMOTE=$(git remote get-url origin)
        echo "✅ Git remote configured: $REMOTE"
    else
        echo "⚠️  No git remote configured"
        ((WARNINGS++))
    fi

    # Check current branch
    BRANCH=$(git branch --show-current)
    echo "✅ Current branch: $BRANCH"
else
    echo "❌ Not a git repository"
    ((ERRORS++))
fi

echo ""
echo "🔑 Checking GitHub Authentication..."
echo "------------------------------------"

if command -v gh &> /dev/null; then
    if gh auth status &> /dev/null; then
        echo "✅ GitHub CLI authenticated"
        gh auth status 2>&1 | grep "Logged in"
    else
        echo "⚠️  GitHub CLI not authenticated (run: gh auth login)"
        ((WARNINGS++))
    fi
else
    echo "⚠️  GitHub CLI not installed"
fi

echo ""
echo "📊 Summary"
echo "=================================="
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo "🎉 Perfect! Your CI/CD setup is complete!"
        echo ""
        echo "Next steps:"
        echo "1. Complete GitHub setup: see docs/CI_CD_SETUP.md"
        echo "2. Test workflow: ./scripts/agent-workflow.sh <issue_number>"
        echo "3. Review documentation: docs/CI_CD_QUICKSTART.md"
    else
        echo "⚠️  Setup is functional but has warnings"
        echo "Review warnings above and fix if needed"
    fi
    exit 0
else
    echo "❌ Setup has errors. Please fix them before proceeding."
    exit 1
fi

