package com.ai.codefixchallange.presentation.detail

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ai.codefixchallange.domain.usecase.GetContactByIdUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * ViewModel for Contact Detail Screen
 * Manages the UI state and business logic for displaying contact details
 */
@HiltViewModel
class ContactDetailViewModel @Inject constructor(
    private val getContactByIdUseCase: GetContactByIdUseCase,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val _state = MutableStateFlow<ContactDetailState>(ContactDetailState.Loading)
    val state: StateFlow<ContactDetailState> = _state

    private val contactId: String = savedStateHandle.get<String>("contactId") ?: ""

    init {
        loadContactDetails()
    }

    /**
     * Load contact details by ID
     */
    private fun loadContactDetails() {
        viewModelScope.launch {
            try {
                _state.value = ContactDetailState.Loading
                val contact = getContactByIdUseCase(contactId)
                if (contact != null) {
                    _state.value = ContactDetailState.Success(contact)
                } else {
                    _state.value = ContactDetailState.Error("Contact not found")
                }
            } catch (e: Exception) {
                _state.value = ContactDetailState.Error(
                    e.message ?: "An unknown error occurred"
                )
            }
        }
    }

    /**
     * Retry loading contact details
     */
    fun retry() {
        loadContactDetails()
    }
}

