package com.ai.codefixchallange

import com.ai.codefixchallange.util.CsvReportGenerator
import com.ai.codefixchallange.util.HtmlReportGenerator
import com.ai.codefixchallange.util.TestResult
import com.ai.codefixchallange.util.TestStatus
import com.ai.codefixchallange.util.TestSummary
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Sample test report generator
 * This demonstrates how to generate test reports programmatically
 *
 * Usage: Run this as a JVM application to generate sample reports
 */
fun main() {
    println("📊 Generating Sample Test Reports...")
    println("=====================================")

    // Create sample test results
    val testResults = createSampleTestResults()

    // Create test summary
    val summary = createTestSummary(testResults)

    // Generate HTML report
    generateHtmlReport(summary, testResults)

    // Generate CSV report (Excel-compatible)
    generateCsvReport(summary, testResults)

    println("✅ Reports generated successfully!")
    println("=====================================")
}

/**
 * Create sample test results
 */
private fun createSampleTestResults(): List<TestResult> {
    return listOf(
        // Domain Layer Tests
        TestResult(
            testName = "invoke should return contacts from repository",
            className = "GetContactsUseCaseTest",
            status = TestStatus.PASSED,
            duration = 45
        ),
        TestResult(
            testName = "invoke should return empty list when no contacts",
            className = "GetContactsUseCaseTest",
            status = TestStatus.PASSED,
            duration = 32
        ),
        TestResult(
            testName = "invoke should return contact when found",
            className = "GetContactByIdUseCaseTest",
            status = TestStatus.PASSED,
            duration = 28
        ),
        TestResult(
            testName = "invoke should return null when contact not found",
            className = "GetContactByIdUseCaseTest",
            status = TestStatus.PASSED,
            duration = 25
        ),

        // Data Layer Tests
        TestResult(
            testName = "toDomain should convert ContactEntity to Contact",
            className = "ContactMapperTest",
            status = TestStatus.PASSED,
            duration = 15
        ),
        TestResult(
            testName = "toEntity should convert Contact to ContactEntity",
            className = "ContactMapperTest",
            status = TestStatus.PASSED,
            duration = 12
        ),
        TestResult(
            testName = "toDomainList should convert list of ContactEntity to list of Contact",
            className = "ContactMapperTest",
            status = TestStatus.PASSED,
            duration = 18
        ),
        TestResult(
            testName = "toEntityList should convert list of Contact to list of ContactEntity",
            className = "ContactMapperTest",
            status = TestStatus.PASSED,
            duration = 16
        ),
        TestResult(
            testName = "mapper should handle null email and photoUri",
            className = "ContactMapperTest",
            status = TestStatus.PASSED,
            duration = 14
        ),
        TestResult(
            testName = "getContacts should return contacts from dao as domain models",
            className = "ContactRepositoryImplTest",
            status = TestStatus.PASSED,
            duration = 42
        ),
        TestResult(
            testName = "getContactById should return contact when found",
            className = "ContactRepositoryImplTest",
            status = TestStatus.PASSED,
            duration = 35
        ),
        TestResult(
            testName = "getContactById should return null when not found",
            className = "ContactRepositoryImplTest",
            status = TestStatus.PASSED,
            duration = 30
        ),
        TestResult(
            testName = "hasContactPermission should return permission status from data source",
            className = "ContactRepositoryImplTest",
            status = TestStatus.PASSED,
            duration = 20
        ),
        TestResult(
            testName = "syncContacts should fetch from data source and save to dao",
            className = "ContactRepositoryImplTest",
            status = TestStatus.PASSED,
            duration = 55
        ),

        // Presentation Layer Tests
        TestResult(
            testName = "init should load contacts when permission is granted",
            className = "ContactsViewModelTest",
            status = TestStatus.PASSED,
            duration = 48
        ),
        TestResult(
            testName = "init should show permission required when permission not granted",
            className = "ContactsViewModelTest",
            status = TestStatus.PASSED,
            duration = 38
        ),
        TestResult(
            testName = "syncContacts should sync and load contacts",
            className = "ContactsViewModelTest",
            status = TestStatus.PASSED,
            duration = 52
        ),
        TestResult(
            testName = "syncContacts should show error when sync fails",
            className = "ContactsViewModelTest",
            status = TestStatus.PASSED,
            duration = 41
        ),
        TestResult(
            testName = "retry should check permission and load contacts",
            className = "ContactsViewModelTest",
            status = TestStatus.PASSED,
            duration = 36
        ),
        TestResult(
            testName = "init should load contact details when found",
            className = "ContactDetailViewModelTest",
            status = TestStatus.PASSED,
            duration = 44
        ),
        TestResult(
            testName = "init should show error when contact not found",
            className = "ContactDetailViewModelTest",
            status = TestStatus.PASSED,
            duration = 33
        ),
        TestResult(
            testName = "init should show error when exception occurs",
            className = "ContactDetailViewModelTest",
            status = TestStatus.PASSED,
            duration = 37
        ),
        TestResult(
            testName = "retry should reload contact details",
            className = "ContactDetailViewModelTest",
            status = TestStatus.PASSED,
            duration = 40
        )
    )
}

/**
 * Create test summary from results
 */
private fun createTestSummary(results: List<TestResult>): TestSummary {
    val totalTests = results.size
    val passedTests = results.count { it.status == TestStatus.PASSED }
    val failedTests = results.count { it.status == TestStatus.FAILED }
    val skippedTests = results.count { it.status == TestStatus.SKIPPED }
    val totalDuration = results.sumOf { it.duration }

    val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
    val timestamp = dateFormat.format(Date())

    return TestSummary(
        totalTests = totalTests,
        passedTests = passedTests,
        failedTests = failedTests,
        skippedTests = skippedTests,
        totalDuration = totalDuration,
        timestamp = timestamp
    )
}

/**
 * Generate HTML report
 */
private fun generateHtmlReport(summary: TestSummary, results: List<TestResult>) {
    try {
        val html = HtmlReportGenerator.generateReport(summary, results)
        val outputFile = File("test-report.html")
        outputFile.writeText(html)
        println("📄 HTML Report: ${outputFile.absolutePath}")
    } catch (e: Exception) {
        println("❌ Failed to generate HTML report: ${e.message}")
    }
}

/**
 * Generate CSV report (Excel-compatible)
 */
private fun generateCsvReport(summary: TestSummary, results: List<TestResult>) {
    try {
        val outputPath = "test-report.csv"
        CsvReportGenerator.generateReport(summary, results, outputPath)
        println("📊 CSV Report: ${File(outputPath).absolutePath}")
    } catch (e: Exception) {
        println("❌ Failed to generate CSV report: ${e.message}")
    }
}

