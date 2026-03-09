package com.ai.codefixchallange.presentation.contacts

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ai.codefixchallange.data.repository.ContactRepositoryImpl
import com.ai.codefixchallange.domain.usecase.GetContactsUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * ViewModel for Contacts List Screen
 * Manages the UI state and business logic for displaying contacts
 */
@HiltViewModel
class ContactsViewModel @Inject constructor(
    private val getContactsUseCase: GetContactsUseCase,
    private val contactRepository: ContactRepositoryImpl
) : ViewModel() {

    private val _state = MutableStateFlow<ContactsState>(ContactsState.Loading)
    val state: StateFlow<ContactsState> = _state

    init {
        checkPermissionAndLoadContacts()
    }

    /**
     * Check permission and load contacts
     * If permission is granted, sync contacts from device first (if DB is empty)
     */
    fun checkPermissionAndLoadContacts() {
        viewModelScope.launch {
            val hasPermission = contactRepository.hasContactPermission()
            if (hasPermission) {
                // First sync contacts from device to DB (if not already synced)
                try {
                    contactRepository.syncContacts()
                } catch (e: Exception) {
                    // Ignore sync errors, try to load from DB anyway
                }
                loadContacts()
            } else {
                _state.value = ContactsState.PermissionRequired
            }
        }
    }

    /**
     * Load contacts from repository
     */
    private fun loadContacts() {
        viewModelScope.launch {
            _state.value = ContactsState.Loading
            getContactsUseCase()
                .catch { e ->
                    _state.value = ContactsState.Error(
                        e.message ?: "An unknown error occurred"
                    )
                }
                .collect { contacts ->
                    _state.value = ContactsState.Success(contacts)
                }
        }
    }

    /**
     * Sync contacts from device after permission is granted
     */
    fun syncContacts() {
        viewModelScope.launch {
            try {
                _state.value = ContactsState.Loading
                contactRepository.syncContacts()
                loadContacts()
            } catch (e: Exception) {
                _state.value = ContactsState.Error(
                    e.message ?: "Failed to sync contacts"
                )
            }
        }
    }

    /**
     * Retry loading contacts
     */
    fun retry() {
        checkPermissionAndLoadContacts()
    }
}

