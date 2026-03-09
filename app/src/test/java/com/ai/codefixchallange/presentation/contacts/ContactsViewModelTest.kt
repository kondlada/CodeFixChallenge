package com.ai.codefixchallange.presentation.contacts

import androidx.arch.core.executor.testing.InstantTaskExecutorRule
import com.ai.codefixchallange.data.repository.ContactRepositoryImpl
import com.ai.codefixchallange.domain.model.Contact
import com.ai.codefixchallange.domain.usecase.GetContactsUseCase
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.every
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Rule
import org.junit.Test

/**
 * Unit tests for ContactsViewModel
 */
@OptIn(ExperimentalCoroutinesApi::class)
class ContactsViewModelTest {

    @get:Rule
    val instantExecutorRule = InstantTaskExecutorRule()

    private val testDispatcher = StandardTestDispatcher()

    private lateinit var getContactsUseCase: GetContactsUseCase
    private lateinit var contactRepository: ContactRepositoryImpl
    private lateinit var viewModel: ContactsViewModel

    @Before
    fun setup() {
        Dispatchers.setMain(testDispatcher)
        getContactsUseCase = mockk()
        contactRepository = mockk()
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `init should load contacts when permission is granted`() = runTest {
        // Given
        val contacts = listOf(
            Contact("1", "John Doe", "+1234567890", "john@example.com", null)
        )
        coEvery { contactRepository.hasContactPermission() } returns true
        every { getContactsUseCase() } returns flowOf(contacts)

        // When
        viewModel = ContactsViewModel(getContactsUseCase, contactRepository)
        advanceUntilIdle()

        // Then
        val state = viewModel.state.value
        assertTrue(state is ContactsState.Success)
        assertEquals(contacts, (state as ContactsState.Success).contacts)
    }

    @Test
    fun `init should show permission required when permission not granted`() = runTest {
        // Given
        coEvery { contactRepository.hasContactPermission() } returns false

        // When
        viewModel = ContactsViewModel(getContactsUseCase, contactRepository)
        advanceUntilIdle()

        // Then
        val state = viewModel.state.value
        assertTrue(state is ContactsState.PermissionRequired)
    }

    @Test
    fun `syncContacts should sync and load contacts`() = runTest {
        // Given
        val contacts = listOf(
            Contact("1", "John Doe", "+1234567890", "john@example.com", null)
        )
        coEvery { contactRepository.hasContactPermission() } returns true
        every { getContactsUseCase() } returns flowOf(contacts)
        coEvery { contactRepository.syncContacts() } returns Unit

        viewModel = ContactsViewModel(getContactsUseCase, contactRepository)
        advanceUntilIdle()

        // When
        viewModel.syncContacts()
        advanceUntilIdle()

        // Then
        coVerify { contactRepository.syncContacts() }
        val state = viewModel.state.value
        assertTrue(state is ContactsState.Success)
    }

    @Test
    fun `syncContacts should show error when sync fails`() = runTest {
        // Given
        val errorMessage = "Sync failed"
        coEvery { contactRepository.hasContactPermission() } returns false
        coEvery { contactRepository.syncContacts() } throws Exception(errorMessage)

        viewModel = ContactsViewModel(getContactsUseCase, contactRepository)
        advanceUntilIdle()

        // When
        viewModel.syncContacts()
        advanceUntilIdle()

        // Then
        val state = viewModel.state.value
        assertTrue(state is ContactsState.Error)
        assertEquals(errorMessage, (state as ContactsState.Error).message)
    }

    @Test
    fun `retry should check permission and load contacts`() = runTest {
        // Given
        val contacts = listOf(
            Contact("1", "John Doe", "+1234567890", "john@example.com", null)
        )
        coEvery { contactRepository.hasContactPermission() } returns true
        every { getContactsUseCase() } returns flowOf(contacts)

        viewModel = ContactsViewModel(getContactsUseCase, contactRepository)
        advanceUntilIdle()

        // When
        viewModel.retry()
        advanceUntilIdle()

        // Then
        coVerify(atLeast = 2) { contactRepository.hasContactPermission() }
        val state = viewModel.state.value
        assertTrue(state is ContactsState.Success)
    }

    @Test
    fun `should show success state with empty list not error - regression test for issue 2`() = runTest {
        // Regression test for issue #2: Empty contacts should show Success, not Error
        // Bug was: when count == 0, it showed error which prevented contacts from displaying
        // Given
        val emptyContacts = emptyList<Contact>()
        coEvery { contactRepository.hasContactPermission() } returns true
        every { getContactsUseCase() } returns flowOf(emptyContacts)

        // When
        viewModel = ContactsViewModel(getContactsUseCase, contactRepository)
        advanceUntilIdle()

        // Then - Should be Success state, NOT Error
        val state = viewModel.state.value
        assertTrue(state is ContactsState.Success)
        assertEquals(emptyContacts, (state as ContactsState.Success).contacts)
    }

    @Test
    fun `should show loading state before success`() = runTest {
        // Given
        val contacts = listOf(
            Contact("1", "John Doe", "+1234567890", "john@example.com", null)
        )
        coEvery { contactRepository.hasContactPermission() } returns true
        every { getContactsUseCase() } returns flowOf(contacts)

        // When
        viewModel = ContactsViewModel(getContactsUseCase, contactRepository)

        // Then - initial state is loading
        val initialState = viewModel.state.value
        assertTrue(initialState is ContactsState.Loading)

        advanceUntilIdle()

        // Then - final state is success
        val finalState = viewModel.state.value
        assertTrue(finalState is ContactsState.Success)
    }
}
