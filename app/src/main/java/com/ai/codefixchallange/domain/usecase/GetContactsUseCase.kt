package com.ai.codefixchallange.domain.usecase

import com.ai.codefixchallange.domain.model.Contact
import com.ai.codefixchallange.domain.repository.ContactRepository
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

/**
 * Use case for getting all contacts
 * Encapsulates the business logic for retrieving contacts
 */
class GetContactsUseCase @Inject constructor(
    private val contactRepository: ContactRepository
) {
    /**
     * Execute the use case to get all contacts
     * @return Flow of list of contacts
     */
    operator fun invoke(): Flow<List<Contact>> {
        return contactRepository.getContacts()
    }
}

