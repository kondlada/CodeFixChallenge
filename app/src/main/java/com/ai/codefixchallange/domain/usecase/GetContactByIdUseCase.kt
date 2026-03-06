package com.ai.codefixchallange.domain.usecase

import com.ai.codefixchallange.domain.model.Contact
import com.ai.codefixchallange.domain.repository.ContactRepository
import javax.inject.Inject

/**
 * Use case for getting a specific contact by ID
 * Encapsulates the business logic for retrieving a single contact
 */
class GetContactByIdUseCase @Inject constructor(
    private val contactRepository: ContactRepository
) {
    /**
     * Execute the use case to get a contact by ID
     * @param contactId The unique identifier of the contact
     * @return The contact if found, null otherwise
     */
    suspend operator fun invoke(contactId: String): Contact? {
        return contactRepository.getContactById(contactId)
    }
}

