package com.ai.codefixchallange.integration

import android.Manifest
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.rule.GrantPermissionRule
import com.ai.codefixchallange.data.local.ContactDao
import com.ai.codefixchallange.data.repository.ContactRepositoryImpl
import com.ai.codefixchallange.data.source.ContactDataSource
import dagger.hilt.android.testing.HiltAndroidRule
import dagger.hilt.android.testing.HiltAndroidTest
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.runTest
import org.junit.Assert.*
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import javax.inject.Inject

/**
 * Integration test to verify contacts are actually pulled from device
 * and stored in database correctly
 */
@HiltAndroidTest
@RunWith(AndroidJUnit4::class)
class ContactsSyncIntegrationTest {

    @get:Rule
    val hiltRule = HiltAndroidRule(this)

    @get:Rule
    val permissionRule: GrantPermissionRule = GrantPermissionRule.grant(
        Manifest.permission.READ_CONTACTS
    )

    @Inject
    lateinit var contactRepository: ContactRepositoryImpl

    @Inject
    lateinit var contactDao: ContactDao

    @Inject
    lateinit var contactDataSource: ContactDataSource

    @Before
    fun setup() {
        hiltRule.inject()
    }

    @Test
    fun testContactsSyncFromDeviceToDatabase() = runTest {
        // Step 1: Verify permission is granted
        val hasPermission = contactDataSource.hasContactPermission()
        assertTrue("READ_CONTACTS permission should be granted", hasPermission)

        // Step 2: Fetch contacts from device
        val deviceContacts = contactDataSource.fetchContacts()
        assertNotNull("Device contacts should not be null", deviceContacts)
        println("✅ Fetched ${deviceContacts.size} contacts from device")

        // Step 3: Clear database
        contactDao.deleteAllContacts()
        val emptyList = contactDao.getAllContacts().first()
        assertTrue("Database should be empty after clear", emptyList.isEmpty())

        // Step 4: Sync contacts (device → database)
        contactRepository.syncContacts()
        println("✅ Synced contacts to database")

        // Step 5: Verify contacts are in database
        val dbContacts = contactRepository.getContacts().first()
        assertFalse("Database should have contacts after sync", dbContacts.isEmpty())
        assertEquals("Contact count should match", deviceContacts.size, dbContacts.size)
        println("✅ Verified ${dbContacts.size} contacts in database")

        // Step 6: Verify contact details
        if (dbContacts.isNotEmpty()) {
            val firstContact = dbContacts.first()
            assertNotNull("Contact ID should not be null", firstContact.id)
            assertFalse("Contact name should not be empty", firstContact.name.isEmpty())
            assertFalse("Contact phone should not be empty", firstContact.phoneNumber.isEmpty())
            println("✅ Sample contact verified: ${firstContact.name}")
        }
    }

    @Test
    fun testContactsDetailsAreCorrectlyMapped() = runTest {
        // Sync contacts
        contactRepository.syncContacts()
        val contacts = contactRepository.getContacts().first()

        // Verify each contact has required fields
        contacts.forEach { contact ->
            assertNotNull("Contact ID must not be null", contact.id)
            assertNotNull("Contact name must not be null", contact.name)
            assertNotNull("Contact phone must not be null", contact.phoneNumber)
            assertTrue("Contact ID must not be empty", contact.id.isNotEmpty())
            assertTrue("Contact name must not be empty", contact.name.isNotEmpty())
            assertTrue("Contact phone must not be empty", contact.phoneNumber.isNotEmpty())
        }

        println("✅ All ${contacts.size} contacts have valid details")
    }

    @Test
    fun testContactsSyncIsIdempotent() = runTest {
        // First sync
        contactRepository.syncContacts()
        val firstSyncContacts = contactRepository.getContacts().first()
        val firstCount = firstSyncContacts.size

        // Second sync
        contactRepository.syncContacts()
        val secondSyncContacts = contactRepository.getContacts().first()
        val secondCount = secondSyncContacts.size

        // Should have same count
        assertEquals("Sync should be idempotent", firstCount, secondCount)
        println("✅ Idempotent sync verified: $firstCount contacts")
    }
}

