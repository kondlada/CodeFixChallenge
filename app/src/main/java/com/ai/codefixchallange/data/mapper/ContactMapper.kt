package com.ai.codefixchallange.data.mapper

import com.ai.codefixchallange.data.local.ContactEntity
import com.ai.codefixchallange.domain.model.Contact

/**
 * Mapper functions to convert between data and domain models
 */

/**
 * Convert ContactEntity to Contact domain model
 */
fun ContactEntity.toDomain(): Contact {
    return Contact(
        id = id,
        name = name,
        phoneNumber = phoneNumber,
        email = email,
        photoUri = photoUri
    )
}

/**
 * Convert Contact domain model to ContactEntity
 */
fun Contact.toEntity(): ContactEntity {
    return ContactEntity(
        id = id,
        name = name,
        phoneNumber = phoneNumber,
        email = email,
        photoUri = photoUri
    )
}

/**
 * Convert list of ContactEntity to list of Contact domain models
 */
fun List<ContactEntity>.toDomainList(): List<Contact> {
    return map { it.toDomain() }
}

/**
 * Convert list of Contact domain models to list of ContactEntity
 */
fun List<Contact>.toEntityList(): List<ContactEntity> {
    return map { it.toEntity() }
}

