package com.ai.codefixchallange.presentation.contacts

import com.ai.codefixchallange.domain.model.Contact

/**
 * UI State for Contacts List Screen
 */
sealed class ContactsState {
    /**
     * Initial state or loading state
     */
    object Loading : ContactsState()

    /**
     * Success state with list of contacts
     * @param contacts List of contacts to display
     */
    data class Success(val contacts: List<Contact>) : ContactsState()

    /**
     * Error state
     * @param message Error message to display
     */
    data class Error(val message: String) : ContactsState()

    /**
     * Permission required state
     */
    object PermissionRequired : ContactsState()
}

