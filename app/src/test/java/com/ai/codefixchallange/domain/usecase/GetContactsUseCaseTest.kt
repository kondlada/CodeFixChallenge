package com.ai.codefixchallange.domain.usecase

import com.ai.codefixchallange.domain.model.Contact
import com.ai.codefixchallange.domain.repository.ContactRepository
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test

/**
 * Unit tests for GetContactsUseCase
 */
class GetContactsUseCaseTest {

    private lateinit var contactRepository: ContactRepository
    private lateinit var getContactsUseCase: GetContactsUseCase

    @Before
    fun setup() {
        contactRepository = mockk()
        getContactsUseCase = GetContactsUseCase(contactRepository)
    }

    @Test
    fun `invoke should return contacts from repository`() = runTest {
        // Given
        val expectedContacts = listOf(
            Contact("1", "John Doe", "+1234567890", "john@example.com", null),
            Contact("2", "Jane Smith", "+0987654321", "jane@example.com", null)
        )
        every { contactRepository.getContacts() } returns flowOf(expectedContacts)

        // When
        val result = mutableListOf<List<Contact>>()
        getContactsUseCase().collect {
            result.add(it)
        }

        // Then
        assertEquals(1, result.size)
        assertEquals(expectedContacts, result[0])
        verify { contactRepository.getContacts() }
    }

    @Test
    fun `invoke should return empty list when no contacts`() = runTest {
        // Given
        every { contactRepository.getContacts() } returns flowOf(emptyList())

        // When
        val result = mutableListOf<List<Contact>>()
        getContactsUseCase().collect {
            result.add(it)
        }

        // Then
        assertEquals(1, result.size)
        assertEquals(0, result[0].size)
        verify { contactRepository.getContacts() }
    }
}

