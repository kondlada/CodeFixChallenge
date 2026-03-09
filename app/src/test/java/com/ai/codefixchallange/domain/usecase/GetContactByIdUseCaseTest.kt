package com.ai.codefixchallange.domain.usecase

import com.ai.codefixchallange.domain.model.Contact
import com.ai.codefixchallange.domain.repository.ContactRepository
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.mockk
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Before
import org.junit.Test

/**
 * Unit tests for GetContactByIdUseCase
 */
class GetContactByIdUseCaseTest {

    private lateinit var contactRepository: ContactRepository
    private lateinit var getContactByIdUseCase: GetContactByIdUseCase

    @Before
    fun setup() {
        contactRepository = mockk()
        getContactByIdUseCase = GetContactByIdUseCase(contactRepository)
    }

    @Test
    fun `invoke should return contact when found`() = runTest {
        // Given
        val contactId = "1"
        val expectedContact = Contact(contactId, "John Doe", "+1234567890", "john@example.com", null)
        coEvery { contactRepository.getContactById(contactId) } returns expectedContact

        // When
        val result = getContactByIdUseCase(contactId)

        // Then
        assertEquals(expectedContact, result)
        coVerify { contactRepository.getContactById(contactId) }
    }

    @Test
    fun `invoke should return null when contact not found`() = runTest {
        // Given
        val contactId = "999"
        coEvery { contactRepository.getContactById(contactId) } returns null

        // When
        val result = getContactByIdUseCase(contactId)

        // Then
        assertNull(result)
        coVerify { contactRepository.getContactById(contactId) }
    }
}

