package com.ai.codefixchallange.data.source

import android.Manifest
import android.content.ContentResolver
import android.content.Context
import android.content.pm.PackageManager
import android.database.Cursor
import android.provider.ContactsContract
import androidx.core.content.ContextCompat
import com.ai.codefixchallange.domain.model.Contact
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import javax.inject.Inject

/**
 * Data source for fetching contacts from the device
 * Handles the actual ContentProvider queries to get contacts
 */
class ContactDataSource @Inject constructor(
    private val contentResolver: ContentResolver,
    @ApplicationContext private val context: Context
) {

    /**
     * Check if the READ_CONTACTS permission is granted
     * @return true if permission is granted, false otherwise
     */
    fun hasContactPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.READ_CONTACTS
        ) == PackageManager.PERMISSION_GRANTED
    }

    /**
     * Fetch all contacts from the device
     * @return List of contacts
     */
    suspend fun fetchContacts(): List<Contact> = withContext(Dispatchers.IO) {
        val contacts = mutableListOf<Contact>()

        if (!hasContactPermission()) {
            return@withContext emptyList()
        }

        val projection = arrayOf(
            ContactsContract.Contacts._ID,
            ContactsContract.Contacts.DISPLAY_NAME,
            ContactsContract.Contacts.HAS_PHONE_NUMBER,
            ContactsContract.Contacts.PHOTO_URI
        )

        val cursor: Cursor? = contentResolver.query(
            ContactsContract.Contacts.CONTENT_URI,
            projection,
            null,
            null,
            ContactsContract.Contacts.DISPLAY_NAME + " ASC"
        )

        cursor?.use {
            val idIndex = it.getColumnIndex(ContactsContract.Contacts._ID)
            val nameIndex = it.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME)
            val hasPhoneIndex = it.getColumnIndex(ContactsContract.Contacts.HAS_PHONE_NUMBER)
            val photoUriIndex = it.getColumnIndex(ContactsContract.Contacts.PHOTO_URI)

            while (it.moveToNext()) {
                val id = it.getString(idIndex)
                val name = it.getString(nameIndex) ?: "Unknown"
                val hasPhone = it.getInt(hasPhoneIndex) > 0
                val photoUri = if (photoUriIndex >= 0) it.getString(photoUriIndex) else null

                if (hasPhone) {
                    val phoneNumber = getPhoneNumber(id)
                    val email = getEmail(id)

                    if (phoneNumber.isNotEmpty()) {
                        contacts.add(
                            Contact(
                                id = id,
                                name = name,
                                phoneNumber = phoneNumber,
                                email = email,
                                photoUri = photoUri
                            )
                        )
                    }
                }
            }
        }

        return@withContext contacts
    }

    /**
     * Get phone number for a specific contact
     * @param contactId The contact ID
     * @return The phone number or empty string
     */
    private fun getPhoneNumber(contactId: String): String {
        val phoneCursor: Cursor? = contentResolver.query(
            ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
            arrayOf(ContactsContract.CommonDataKinds.Phone.NUMBER),
            "${ContactsContract.CommonDataKinds.Phone.CONTACT_ID} = ?",
            arrayOf(contactId),
            null
        )

        phoneCursor?.use {
            if (it.moveToFirst()) {
                val numberIndex = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)
                if (numberIndex >= 0) {
                    return it.getString(numberIndex) ?: ""
                }
            }
        }

        return ""
    }

    /**
     * Get email for a specific contact
     * @param contactId The contact ID
     * @return The email or null
     */
    private fun getEmail(contactId: String): String? {
        val emailCursor: Cursor? = contentResolver.query(
            ContactsContract.CommonDataKinds.Email.CONTENT_URI,
            arrayOf(ContactsContract.CommonDataKinds.Email.ADDRESS),
            "${ContactsContract.CommonDataKinds.Email.CONTACT_ID} = ?",
            arrayOf(contactId),
            null
        )

        emailCursor?.use {
            if (it.moveToFirst()) {
                val emailIndex = it.getColumnIndex(ContactsContract.CommonDataKinds.Email.ADDRESS)
                if (emailIndex >= 0) {
                    return it.getString(emailIndex)
                }
            }
        }

        return null
    }
}

