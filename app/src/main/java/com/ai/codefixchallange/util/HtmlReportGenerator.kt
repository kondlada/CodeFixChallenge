package com.ai.codefixchallange.util

import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Utility class to generate HTML test reports
 */
object HtmlReportGenerator {

    fun generateReport(summary: TestSummary, results: List<TestResult>): String {
        val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
        val currentDate = dateFormat.format(Date())

        return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Execution Report - Contacts Manager</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            min-height: 100vh;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 32px;
            margin-bottom: 10px;
        }
        
        .header p {
            font-size: 16px;
            opacity: 0.9;
        }
        
        .summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            padding: 30px;
            background: #f8f9fa;
        }
        
        .summary-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            text-align: center;
            transition: transform 0.2s;
        }
        
        .summary-card:hover {
            transform: translateY(-5px);
        }
        
        .summary-card h3 {
            font-size: 14px;
            color: #6c757d;
            margin-bottom: 10px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .summary-card .value {
            font-size: 36px;
            font-weight: bold;
            color: #333;
        }
        
        .passed .value { color: #28a745; }
        .failed .value { color: #dc3545; }
        .skipped .value { color: #ffc107; }
        .total .value { color: #007bff; }
        
        .chart-container {
            padding: 30px;
            text-align: center;
        }
        
        .chart-container h2 {
            margin-bottom: 20px;
            color: #333;
        }
        
        .pie-chart {
            margin: 0 auto;
            width: 300px;
            height: 300px;
            border-radius: 50%;
            background: conic-gradient(
                #28a745 0deg ${summary.passPercentage * 3.6}deg,
                #dc3545 ${summary.passPercentage * 3.6}deg ${(summary.passPercentage + summary.failPercentage) * 3.6}deg,
                #ffc107 ${(summary.passPercentage + summary.failPercentage) * 3.6}deg 360deg
            );
            position: relative;
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
        }
        
        .pie-chart::after {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 60%;
            height: 60%;
            background: white;
            border-radius: 50%;
        }
        
        .legend {
            display: flex;
            justify-content: center;
            gap: 30px;
            margin-top: 30px;
            flex-wrap: wrap;
        }
        
        .legend-item {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .legend-color {
            width: 20px;
            height: 20px;
            border-radius: 3px;
        }
        
        .legend-passed { background: #28a745; }
        .legend-failed { background: #dc3545; }
        .legend-skipped { background: #ffc107; }
        
        .test-results {
            padding: 30px;
        }
        
        .test-results h2 {
            margin-bottom: 20px;
            color: #333;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            border-radius: 8px;
            overflow: hidden;
        }
        
        thead {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        th {
            padding: 15px;
            text-align: left;
            font-weight: 600;
        }
        
        td {
            padding: 12px 15px;
            border-bottom: 1px solid #e9ecef;
        }
        
        tr:last-child td {
            border-bottom: none;
        }
        
        tr:hover {
            background: #f8f9fa;
        }
        
        .status-badge {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
            display: inline-block;
        }
        
        .status-passed {
            background: #d4edda;
            color: #155724;
        }
        
        .status-failed {
            background: #f8d7da;
            color: #721c24;
        }
        
        .status-skipped {
            background: #fff3cd;
            color: #856404;
        }
        
        .footer {
            background: #f8f9fa;
            padding: 20px;
            text-align: center;
            color: #6c757d;
            font-size: 14px;
        }
        
        .error-message {
            color: #dc3545;
            font-size: 12px;
            margin-top: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Test Execution Report</h1>
            <p>Contacts Manager Application - Clean Architecture</p>
            <p>Generated on: $currentDate</p>
        </div>
        
        <div class="summary">
            <div class="summary-card total">
                <h3>Total Tests</h3>
                <div class="value">${summary.totalTests}</div>
            </div>
            <div class="summary-card passed">
                <h3>Passed</h3>
                <div class="value">${summary.passedTests}</div>
                <p>${String.format("%.1f", summary.passPercentage)}%</p>
            </div>
            <div class="summary-card failed">
                <h3>Failed</h3>
                <div class="value">${summary.failedTests}</div>
                <p>${String.format("%.1f", summary.failPercentage)}%</p>
            </div>
            <div class="summary-card skipped">
                <h3>Skipped</h3>
                <div class="value">${summary.skippedTests}</div>
                <p>${String.format("%.1f", summary.skipPercentage)}%</p>
            </div>
        </div>
        
        <div class="chart-container">
            <h2>Test Results Distribution</h2>
            <div class="pie-chart"></div>
            <div class="legend">
                <div class="legend-item">
                    <div class="legend-color legend-passed"></div>
                    <span>Passed (${summary.passedTests})</span>
                </div>
                <div class="legend-item">
                    <div class="legend-color legend-failed"></div>
                    <span>Failed (${summary.failedTests})</span>
                </div>
                <div class="legend-item">
                    <div class="legend-color legend-skipped"></div>
                    <span>Skipped (${summary.skippedTests})</span>
                </div>
            </div>
        </div>
        
        <div class="test-results">
            <h2>Detailed Test Results</h2>
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Test Name</th>
                        <th>Class</th>
                        <th>Status</th>
                        <th>Duration (ms)</th>
                    </tr>
                </thead>
                <tbody>
                    ${generateTableRows(results)}
                </tbody>
            </table>
        </div>
        
        <div class="footer">
            <p>Code Coverage: Target 100% | Min SDK: 24 | Target SDK: 36</p>
            <p>Clean Architecture Pattern | MVVM | Kotlin Coroutines | Hilt DI</p>
        </div>
    </div>
</body>
</html>
        """.trimIndent()
    }

    private fun generateTableRows(results: List<TestResult>): String {
        return results.mapIndexed { index, result ->
            val statusClass = when (result.status) {
                TestStatus.PASSED -> "status-passed"
                TestStatus.FAILED -> "status-failed"
                TestStatus.SKIPPED -> "status-skipped"
            }
            val statusText = result.status.name
            val errorMsg = if (result.errorMessage != null) {
                "<div class=\"error-message\">${result.errorMessage}</div>"
            } else ""

            """
                <tr>
                    <td>${index + 1}</td>
                    <td>${result.testName}$errorMsg</td>
                    <td>${result.className}</td>
                    <td><span class="status-badge $statusClass">$statusText</span></td>
                    <td>${result.duration}</td>
                </tr>
            """.trimIndent()
        }.joinToString("\n")
    }
}

