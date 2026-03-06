package com.ai.codefixchallange.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

/**
 * DAO (Data Access Object) for Contact operations
 * Provides methods to interact with the local Room database
 */
@Dao
interface ContactDao {
    /**
     * Get all contacts from the database
     * @return Flow of list of contact entities
     */
    @Query("SELECT * FROM contacts ORDER BY name ASC")
    fun getAllContacts(): Flow<List<ContactEntity>>

    /**
     * Get a specific contact by ID
     * @param contactId The unique identifier of the contact
     * @return The contact entity if found, null otherwise
     */
    @Query("SELECT * FROM contacts WHERE id = :contactId")
    suspend fun getContactById(contactId: String): ContactEntity?

    /**
     * Insert contacts into the database
     * @param contacts List of contact entities to insert
     */
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertContacts(contacts: List<ContactEntity>)

    /**
     * Delete all contacts from the database
     */
    @Query("DELETE FROM contacts")
    suspend fun deleteAllContacts()
}

