package com.ai.codefixchallange.data.local

import androidx.room.Database
import androidx.room.RoomDatabase

/**
 * Room Database for the application
 * Contains the contacts table
 */
@Database(
    entities = [ContactEntity::class],
    version = 1,
    exportSchema = false
)
abstract class ContactDatabase : RoomDatabase() {
    abstract fun contactDao(): ContactDao

    companion object {
        const val DATABASE_NAME = "contact_database"
    }
}

