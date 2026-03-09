package com.ai.codefixchallange.di

import android.content.ContentResolver
import android.content.Context
import android.content.pm.PackageManager
import androidx.room.Room
import com.ai.codefixchallange.data.local.ContactDao
import com.ai.codefixchallange.data.local.ContactDatabase
import com.ai.codefixchallange.data.repository.ContactRepositoryImpl
import com.ai.codefixchallange.data.source.ContactDataSource
import com.ai.codefixchallange.domain.repository.ContactRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

/**
 * Dagger Hilt module for dependency injection
 * Provides application-level dependencies
 */
@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    /**
     * Provides Room database instance
     */
    @Provides
    @Singleton
    fun provideContactDatabase(@ApplicationContext context: Context): ContactDatabase {
        return Room.databaseBuilder(
            context,
            ContactDatabase::class.java,
            ContactDatabase.DATABASE_NAME
        ).build()
    }

    /**
     * Provides ContactDao from database
     */
    @Provides
    @Singleton
    fun provideContactDao(database: ContactDatabase): ContactDao {
        return database.contactDao()
    }

    /**
     * Provides ContentResolver
     */
    @Provides
    @Singleton
    fun provideContentResolver(@ApplicationContext context: Context): ContentResolver {
        return context.contentResolver
    }

    /**
     * Provides ContactDataSource
     */
    @Provides
    @Singleton
    fun provideContactDataSource(
        contentResolver: ContentResolver,
        @ApplicationContext context: Context
    ): ContactDataSource {
        return ContactDataSource(contentResolver, context)
    }

    /**
     * Provides ContactRepository implementation
     */
    @Provides
    @Singleton
    fun provideContactRepository(
        contactDao: ContactDao,
        contactDataSource: ContactDataSource
    ): ContactRepository {
        return ContactRepositoryImpl(contactDao, contactDataSource)
    }
}

