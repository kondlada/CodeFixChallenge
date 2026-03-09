package com.ai.codefixchallange.domain.model

/**
 * Domain model representing a Contact entity
 * This is the core business model used across all layers
 */
data class Contact(
    val id: String,
    val name: String,
    val phoneNumber: String,
    val email: String? = null,
    val photoUri: String? = null
)

