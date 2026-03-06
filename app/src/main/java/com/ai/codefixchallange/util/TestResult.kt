package com.ai.codefixchallange.util

/**
 * Data class representing a test case result
 */
data class TestResult(
    val testName: String,
    val className: String,
    val status: TestStatus,
    val duration: Long,
    val errorMessage: String? = null
)

/**
 * Enum representing test status
 */
enum class TestStatus {
    PASSED,
    FAILED,
    SKIPPED
}

/**
 * Data class representing test summary
 */
data class TestSummary(
    val totalTests: Int,
    val passedTests: Int,
    val failedTests: Int,
    val skippedTests: Int,
    val totalDuration: Long,
    val timestamp: String
) {
    val passPercentage: Double
        get() = if (totalTests > 0) (passedTests.toDouble() / totalTests.toDouble()) * 100 else 0.0

    val failPercentage: Double
        get() = if (totalTests > 0) (failedTests.toDouble() / totalTests.toDouble()) * 100 else 0.0

    val skipPercentage: Double
        get() = if (totalTests > 0) (skippedTests.toDouble() / totalTests.toDouble()) * 100 else 0.0
}

