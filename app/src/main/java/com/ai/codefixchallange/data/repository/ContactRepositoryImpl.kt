package com.ai.codefixchallange.data.repository

import com.ai.codefixchallange.data.local.ContactDao
import com.ai.codefixchallange.data.mapper.toDomainList
import com.ai.codefixchallange.data.mapper.toEntityList
import com.ai.codefixchallange.data.source.ContactDataSource
import com.ai.codefixchallange.domain.model.Contact
import com.ai.codefixchallange.domain.repository.ContactRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject

/**
 * Implementation of ContactRepository
 * Coordinates between local database and device contacts
 */
class ContactRepositoryImpl @Inject constructor(
    private val contactDao: ContactDao,
    private val contactDataSource: ContactDataSource
) : ContactRepository {

    override fun getContacts(): Flow<List<Contact>> {
        // Return cached contacts from database
        return contactDao.getAllContacts().map { entities ->
            entities.toDomainList()
        }
    }

    override suspend fun getContactById(contactId: String): Contact? {
        return contactDao.getContactById(contactId)?.let { entity ->
            Contact(
                id = entity.id,
                name = entity.name,
                phoneNumber = entity.phoneNumber,
                email = entity.email,
                photoUri = entity.photoUri
            )
        }
    }

    override suspend fun hasContactPermission(): Boolean {
        return contactDataSource.hasContactPermission()
    }

    /**
     * Sync contacts from device to local database
     * This should be called when permission is granted
     */
    suspend fun syncContacts() {
        val contacts = contactDataSource.fetchContacts()
        contactDao.deleteAllContacts()
        contactDao.insertContacts(contacts.toEntityList())
    }
}

