package com.ai.codefixchallange.presentation.detail

import androidx.arch.core.executor.testing.InstantTaskExecutorRule
import androidx.lifecycle.SavedStateHandle
import com.ai.codefixchallange.domain.model.Contact
import com.ai.codefixchallange.domain.usecase.GetContactByIdUseCase
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
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
 * Unit tests for ContactDetailViewModel
 */
@OptIn(ExperimentalCoroutinesApi::class)
class ContactDetailViewModelTest {

    @get:Rule
    val instantExecutorRule = InstantTaskExecutorRule()

    private val testDispatcher = StandardTestDispatcher()

    private lateinit var getContactByIdUseCase: GetContactByIdUseCase
    private lateinit var savedStateHandle: SavedStateHandle
    private lateinit var viewModel: ContactDetailViewModel

    @Before
    fun setup() {
        Dispatchers.setMain(testDispatcher)
        getContactByIdUseCase = mockk()
        savedStateHandle = SavedStateHandle(mapOf("contactId" to "1"))
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `init should load contact details when found`() = runTest {
        // Given
        val contact = Contact("1", "John Doe", "+1234567890", "john@example.com", null)
        coEvery { getContactByIdUseCase("1") } returns contact

        // When
        viewModel = ContactDetailViewModel(getContactByIdUseCase, savedStateHandle)
        advanceUntilIdle()

        // Then
        val state = viewModel.state.value
        assertTrue(state is ContactDetailState.Success)
        assertEquals(contact, (state as ContactDetailState.Success).contact)
        coVerify { getContactByIdUseCase("1") }
    }

    @Test
    fun `init should show error when contact not found`() = runTest {
        // Given
        coEvery { getContactByIdUseCase("1") } returns null

        // When
        viewModel = ContactDetailViewModel(getContactByIdUseCase, savedStateHandle)
        advanceUntilIdle()

        // Then
        val state = viewModel.state.value
        assertTrue(state is ContactDetailState.Error)
        assertEquals("Contact not found", (state as ContactDetailState.Error).message)
    }

    @Test
    fun `init should show error when exception occurs`() = runTest {
        // Given
        val errorMessage = "Database error"
        coEvery { getContactByIdUseCase("1") } throws Exception(errorMessage)

        // When
        viewModel = ContactDetailViewModel(getContactByIdUseCase, savedStateHandle)
        advanceUntilIdle()

        // Then
        val state = viewModel.state.value
        assertTrue(state is ContactDetailState.Error)
        assertEquals(errorMessage, (state as ContactDetailState.Error).message)
    }

    @Test
    fun `retry should reload contact details`() = runTest {
        // Given
        val contact = Contact("1", "John Doe", "+1234567890", "john@example.com", null)
        coEvery { getContactByIdUseCase("1") } returns contact

        viewModel = ContactDetailViewModel(getContactByIdUseCase, savedStateHandle)
        advanceUntilIdle()

        // When
        viewModel.retry()
        advanceUntilIdle()

        // Then
        coVerify(exactly = 2) { getContactByIdUseCase("1") }
        val state = viewModel.state.value
        assertTrue(state is ContactDetailState.Success)
    }

    @Test
    fun `should show loading state before success`() = runTest {
        // Given
        val contact = Contact("1", "John Doe", "+1234567890", "john@example.com", null)
        coEvery { getContactByIdUseCase("1") } returns contact

        // When
        viewModel = ContactDetailViewModel(getContactByIdUseCase, savedStateHandle)

        // Then - initial state is loading
        val initialState = viewModel.state.value
        assertTrue(initialState is ContactDetailState.Loading)

        advanceUntilIdle()

        // Then - final state is success
        val finalState = viewModel.state.value
        assertTrue(finalState is ContactDetailState.Success)
    }

    @Test
    fun `should handle empty contactId`() = runTest {
        // Given
        savedStateHandle = SavedStateHandle(mapOf("contactId" to ""))
        coEvery { getContactByIdUseCase("") } returns null

        // When
        viewModel = ContactDetailViewModel(getContactByIdUseCase, savedStateHandle)
        advanceUntilIdle()

        // Then
        val state = viewModel.state.value
        assertTrue(state is ContactDetailState.Error)
    }
}

