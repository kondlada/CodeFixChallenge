package com.ai.codefixchallange.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

/**
 * Room database entity for Contact
 * This represents the local cached version of contacts
 */
@Entity(tableName = "contacts")
data class ContactEntity(
    @PrimaryKey
    val id: String,
    val name: String,
    val phoneNumber: String,
    val email: String?,
    val photoUri: String?
)

