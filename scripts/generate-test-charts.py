#!/usr/bin/env python3
"""
Test Chart Generator
Creates visual charts from JUnit and Jacoco reports
"""

import sys
import os
import xml.etree.ElementTree as ET
from pathlib import Path

try:
    import matplotlib
    matplotlib.use('Agg')  # Non-interactive backend
    import matplotlib.pyplot as plt
    MATPLOTLIB_AVAILABLE = True
except ImportError:
    MATPLOTLIB_AVAILABLE = False
    print("⚠️  matplotlib not available, chart generation skipped")

def parse_junit_results(results_dir):
    """Parse JUnit XML results"""
    total_tests = 0
    passed_tests = 0
    failed_tests = 0
    skipped_tests = 0

    results_path = Path(results_dir)
    if not results_path.exists():
        return 0, 0, 0, 0

    for xml_file in results_path.rglob('TEST-*.xml'):
        try:
            tree = ET.parse(xml_file)
            root = tree.getroot()

            tests = int(root.get('tests', 0))
            failures = int(root.get('failures', 0))
            skipped = int(root.get('skipped', 0))

            total_tests += tests
            failed_tests += failures
            skipped_tests += skipped
            passed_tests += (tests - failures - skipped)
        except Exception as e:
            print(f"Warning: Could not parse {xml_file}: {e}", file=sys.stderr)

    return total_tests, passed_tests, failed_tests, skipped_tests

def parse_jacoco_coverage(coverage_dir):
    """Parse Jacoco coverage XML"""
    line_coverage = 0
    branch_coverage = 0

    coverage_path = Path(coverage_dir) / 'jacocoTestReport' / 'jacocoTestReport.xml'

    if not coverage_path.exists():
        return 0, 0

    try:
        tree = ET.parse(coverage_path)
        root = tree.getroot()

        for counter in root.findall('.//counter[@type="LINE"]'):
            covered = int(counter.get('covered', 0))
            missed = int(counter.get('missed', 0))
            total = covered + missed
            if total > 0:
                line_coverage = (covered / total) * 100
                break

        for counter in root.findall('.//counter[@type="BRANCH"]'):
            covered = int(counter.get('covered', 0))
            missed = int(counter.get('missed', 0))
            total = covered + missed
            if total > 0:
                branch_coverage = (covered / total) * 100
                break

    except Exception as e:
        print(f"Warning: Could not parse coverage: {e}", file=sys.stderr)

    return line_coverage, branch_coverage

def generate_chart(test_results, coverage_results, output_file):
    """Generate combined test and coverage chart"""
    if not MATPLOTLIB_AVAILABLE:
        return False

    total, passed, failed, skipped = test_results
    line_cov, branch_cov = coverage_results

    # Create figure with 2 subplots
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Test Results & Coverage', fontsize=16, fontweight='bold')

    # Test Results Pie Chart
    if total > 0:
        sizes = [passed, failed, skipped]
        labels = [f'Passed\n{passed}', f'Failed\n{failed}', f'Skipped\n{skipped}']
        colors = ['#4CAF50', '#F44336', '#FFC107']
        explode = (0.05, 0, 0) if failed == 0 else (0, 0.05, 0)

        ax1.pie(sizes, explode=explode, labels=labels, colors=colors,
                autopct='%1.1f%%', shadow=True, startangle=90)
        ax1.set_title(f'Test Results\n(Total: {total})', fontsize=14, pad=20)
    else:
        ax1.text(0.5, 0.5, 'No test results',
                ha='center', va='center', fontsize=12)
        ax1.set_title('Test Results', fontsize=14)

    # Coverage Bar Chart
    categories = ['Line\nCoverage', 'Branch\nCoverage']
    values = [line_cov, branch_cov]
    colors_bar = ['#2196F3', '#FF9800']

    bars = ax2.bar(categories, values, color=colors_bar, width=0.6)
    ax2.set_ylabel('Percentage (%)', fontsize=12)
    ax2.set_ylim(0, 100)
    ax2.set_title('Code Coverage', fontsize=14, pad=20)
    ax2.grid(axis='y', alpha=0.3)

    # Add value labels on bars
    for bar, value in zip(bars, values):
        height = bar.get_height()
        ax2.text(bar.get_x() + bar.get_width()/2., height,
                f'{value:.1f}%',
                ha='center', va='bottom', fontsize=11, fontweight='bold')

    # Adjust layout and save
    plt.tight_layout()
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    plt.close()

    return True

def main():
    if len(sys.argv) < 4:
        print("Usage: generate-test-charts.py <test_results_dir> <coverage_dir> <output_png>")
        sys.exit(1)

    results_dir = sys.argv[1]
    coverage_dir = sys.argv[2]
    output_file = sys.argv[3]

    print("📊 Generating test charts...")

    # Parse results
    test_results = parse_junit_results(results_dir)
    coverage_results = parse_jacoco_coverage(coverage_dir)

    total, passed, failed, skipped = test_results
    line_cov, branch_cov = coverage_results

    print(f"   Tests: {passed}/{total} passed")
    print(f"   Coverage: Line={line_cov:.1f}%, Branch={branch_cov:.1f}%")

    # Generate chart
    if generate_chart(test_results, coverage_results, output_file):
        print(f"✅ Chart generated: {output_file}")
    else:
        print("⚠️  Chart generation skipped")

if __name__ == '__main__':
    main()

