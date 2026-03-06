package com.ai.codefixchallange.domain.repository

import com.ai.codefixchallange.domain.model.Contact
import kotlinx.coroutines.flow.Flow

/**
 * Repository interface for Contact data operations
 * Following Clean Architecture principles, this interface is in the domain layer
 * and implemented in the data layer
 */
interface ContactRepository {
    /**
     * Get all contacts from the phone
     * @return Flow of list of contacts
     */
    fun getContacts(): Flow<List<Contact>>

    /**
     * Get a specific contact by ID
     * @param contactId The unique identifier of the contact
     * @return The contact if found, null otherwise
     */
    suspend fun getContactById(contactId: String): Contact?

    /**
     * Check if contact permission is granted
     * @return true if permission is granted, false otherwise
     */
    suspend fun hasContactPermission(): Boolean
}

