package com.ai.codefixchallange.presentation.detail

import com.ai.codefixchallange.domain.model.Contact

/**
 * UI State for Contact Detail Screen
 */
sealed class ContactDetailState {
    /**
     * Loading state
     */
    object Loading : ContactDetailState()

    /**
     * Success state with contact details
     * @param contact The contact to display
     */
    data class Success(val contact: Contact) : ContactDetailState()

    /**
     * Error state
     * @param message Error message to display
     */
    data class Error(val message: String) : ContactDetailState()
}

