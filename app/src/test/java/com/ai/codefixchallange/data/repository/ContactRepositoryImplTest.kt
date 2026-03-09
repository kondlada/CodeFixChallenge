package com.ai.codefixchallange.data.repository

import com.ai.codefixchallange.data.local.ContactDao
import com.ai.codefixchallange.data.local.ContactEntity
import com.ai.codefixchallange.data.source.ContactDataSource
import com.ai.codefixchallange.domain.model.Contact
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.every
import io.mockk.mockk
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

/**
 * Unit tests for ContactRepositoryImpl
 */
class ContactRepositoryImplTest {

    private lateinit var contactDao: ContactDao
    private lateinit var contactDataSource: ContactDataSource
    private lateinit var repository: ContactRepositoryImpl

    @Before
    fun setup() {
        contactDao = mockk()
        contactDataSource = mockk()
        repository = ContactRepositoryImpl(contactDao, contactDataSource)
    }

    @Test
    fun `getContacts should return contacts from dao as domain models`() = runTest {
        // Given
        val entities = listOf(
            ContactEntity("1", "John Doe", "+1234567890", "john@example.com", null),
            ContactEntity("2", "Jane Smith", "+0987654321", "jane@example.com", null)
        )
        every { contactDao.getAllContacts() } returns flowOf(entities)

        // When
        val result = repository.getContacts().first()

        // Then
        assertEquals(2, result.size)
        assertEquals("1", result[0].id)
        assertEquals("John Doe", result[0].name)
        assertEquals("2", result[1].id)
        assertEquals("Jane Smith", result[1].name)
    }

    @Test
    fun `getContactById should return contact when found`() = runTest {
        // Given
        val entity = ContactEntity("1", "John Doe", "+1234567890", "john@example.com", null)
        coEvery { contactDao.getContactById("1") } returns entity

        // When
        val result = repository.getContactById("1")

        // Then
        assertEquals("1", result?.id)
        assertEquals("John Doe", result?.name)
        coVerify { contactDao.getContactById("1") }
    }

    @Test
    fun `getContactById should return null when not found`() = runTest {
        // Given
        coEvery { contactDao.getContactById("999") } returns null

        // When
        val result = repository.getContactById("999")

        // Then
        assertNull(result)
        coVerify { contactDao.getContactById("999") }
    }

    @Test
    fun `hasContactPermission should return permission status from data source`() = runTest {
        // Given
        every { contactDataSource.hasContactPermission() } returns true

        // When
        val result = repository.hasContactPermission()

        // Then
        assertTrue(result)
    }

    @Test
    fun `syncContacts should fetch from data source and save to dao`() = runTest {
        // Given
        val contacts = listOf(
            Contact("1", "John Doe", "+1234567890", "john@example.com", null),
            Contact("2", "Jane Smith", "+0987654321", "jane@example.com", null)
        )
        coEvery { contactDataSource.fetchContacts() } returns contacts
        coEvery { contactDao.deleteAllContacts() } returns Unit
        coEvery { contactDao.insertContacts(any()) } returns Unit

        // When
        repository.syncContacts()

        // Then
        coVerify { contactDataSource.fetchContacts() }
        coVerify { contactDao.deleteAllContacts() }
        coVerify { contactDao.insertContacts(any()) }
    }

    @Test
    fun `syncContacts should handle empty contacts list`() = runTest {
        // Given
        coEvery { contactDataSource.fetchContacts() } returns emptyList()
        coEvery { contactDao.deleteAllContacts() } returns Unit
        coEvery { contactDao.insertContacts(emptyList()) } returns Unit

        // When
        repository.syncContacts()

        // Then
        coVerify { contactDataSource.fetchContacts() }
        coVerify { contactDao.deleteAllContacts() }
        coVerify { contactDao.insertContacts(emptyList()) }
    }
}

