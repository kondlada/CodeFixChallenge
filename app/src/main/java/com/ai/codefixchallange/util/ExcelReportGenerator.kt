package com.ai.codefixchallange.util

import java.io.File
import java.io.FileWriter

/**
 * Utility class to generate CSV test reports (compatible with SDK 24+)
 * CSV files can be opened in Excel, Google Sheets, or any spreadsheet application
 */
object CsvReportGenerator {

    /**
     * Generate CSV report
     * @param summary Test summary
     * @param results List of test results
     * @param outputPath Output file path
     */
    fun generateReport(summary: TestSummary, results: List<TestResult>, outputPath: String) {
        val file = File(outputPath)
        FileWriter(file).use { writer ->
            // Write summary section
            writer.appendLine("TEST EXECUTION SUMMARY - CONTACTS MANAGER")
            writer.appendLine("")
            writer.appendLine("Metric,Value")
            writer.appendLine("Total Tests,${summary.totalTests}")
            writer.appendLine("Passed Tests,${summary.passedTests} (${String.format("%.1f", summary.passPercentage)}%)")
            writer.appendLine("Failed Tests,${summary.failedTests} (${String.format("%.1f", summary.failPercentage)}%)")
            writer.appendLine("Skipped Tests,${summary.skippedTests} (${String.format("%.1f", summary.skipPercentage)}%)")
            writer.appendLine("Total Duration,${summary.totalDuration} ms")
            writer.appendLine("Timestamp,${summary.timestamp}")
            writer.appendLine("")
            writer.appendLine("")

            // Write detailed results section
            writer.appendLine("DETAILED TEST RESULTS")
            writer.appendLine("")
            writer.appendLine("#,Test Name,Class Name,Status,Duration (ms),Error Message")

            results.forEachIndexed { index, result ->
                writer.appendLine(
                    "${index + 1}," +
                    "\"${result.testName}\"," +
                    "\"${result.className}\"," +
                    "${result.status}," +
                    "${result.duration}," +
                    "\"${result.errorMessage ?: ""}\""
                )
            }
        }
    }
}

/**
 * Extension function to append a line to FileWriter
 */
private fun FileWriter.appendLine(text: String = "") {
    this.append(text)
    this.append("\n")
}

