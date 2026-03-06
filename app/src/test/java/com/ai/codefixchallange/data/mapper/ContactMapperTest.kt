package com.ai.codefixchallange.data.mapper

import com.ai.codefixchallange.data.local.ContactEntity
import com.ai.codefixchallange.domain.model.Contact
import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * Unit tests for Contact Mapper functions
 */
class ContactMapperTest {

    @Test
    fun `toDomain should convert ContactEntity to Contact`() {
        // Given
        val entity = ContactEntity(
            id = "1",
            name = "John Doe",
            phoneNumber = "+1234567890",
            email = "john@example.com",
            photoUri = "content://photo/1"
        )

        // When
        val domain = entity.toDomain()

        // Then
        assertEquals(entity.id, domain.id)
        assertEquals(entity.name, domain.name)
        assertEquals(entity.phoneNumber, domain.phoneNumber)
        assertEquals(entity.email, domain.email)
        assertEquals(entity.photoUri, domain.photoUri)
    }

    @Test
    fun `toEntity should convert Contact to ContactEntity`() {
        // Given
        val domain = Contact(
            id = "1",
            name = "John Doe",
            phoneNumber = "+1234567890",
            email = "john@example.com",
            photoUri = "content://photo/1"
        )

        // When
        val entity = domain.toEntity()

        // Then
        assertEquals(domain.id, entity.id)
        assertEquals(domain.name, entity.name)
        assertEquals(domain.phoneNumber, entity.phoneNumber)
        assertEquals(domain.email, entity.email)
        assertEquals(domain.photoUri, entity.photoUri)
    }

    @Test
    fun `toDomainList should convert list of ContactEntity to list of Contact`() {
        // Given
        val entities = listOf(
            ContactEntity("1", "John Doe", "+1234567890", "john@example.com", null),
            ContactEntity("2", "Jane Smith", "+0987654321", "jane@example.com", null)
        )

        // When
        val domains = entities.toDomainList()

        // Then
        assertEquals(entities.size, domains.size)
        assertEquals(entities[0].id, domains[0].id)
        assertEquals(entities[1].id, domains[1].id)
    }

    @Test
    fun `toEntityList should convert list of Contact to list of ContactEntity`() {
        // Given
        val domains = listOf(
            Contact("1", "John Doe", "+1234567890", "john@example.com", null),
            Contact("2", "Jane Smith", "+0987654321", "jane@example.com", null)
        )

        // When
        val entities = domains.toEntityList()

        // Then
        assertEquals(domains.size, entities.size)
        assertEquals(domains[0].id, entities[0].id)
        assertEquals(domains[1].id, entities[1].id)
    }

    @Test
    fun `mapper should handle null email and photoUri`() {
        // Given
        val entity = ContactEntity("1", "John Doe", "+1234567890", null, null)

        // When
        val domain = entity.toDomain()
        val backToEntity = domain.toEntity()

        // Then
        assertEquals(null, domain.email)
        assertEquals(null, domain.photoUri)
        assertEquals(entity, backToEntity)
    }
}

