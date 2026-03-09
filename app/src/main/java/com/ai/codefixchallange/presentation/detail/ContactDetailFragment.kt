package com.ai.codefixchallange.presentation.detail

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import androidx.navigation.fragment.findNavController
import com.ai.codefixchallange.databinding.FragmentContactDetailBinding
import com.ai.codefixchallange.domain.model.Contact
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.launch

/**
 * Fragment for displaying contact details
 * Shows detailed information about a selected contact
 */
@AndroidEntryPoint
class ContactDetailFragment : Fragment() {

    private var _binding: FragmentContactDetailBinding? = null
    private val binding get() = _binding!!

    private val viewModel: ContactDetailViewModel by viewModels()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentContactDetailBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        setupToolbar()
        observeState()
    }

    /**
     * Setup toolbar with back navigation
     */
    private fun setupToolbar() {
        binding.toolbar.setNavigationOnClickListener {
            findNavController().navigateUp()
        }
    }

    /**
     * Observe ViewModel state and update UI
     */
    private fun observeState() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewLifecycleOwner.repeatOnLifecycle(Lifecycle.State.STARTED) {
                viewModel.state.collect { state ->
                    when (state) {
                        is ContactDetailState.Loading -> {
                            showLoading()
                        }
                        is ContactDetailState.Success -> {
                            showContactDetails(state.contact)
                        }
                        is ContactDetailState.Error -> {
                            showError(state.message)
                        }
                    }
                }
            }
        }
    }

    /**
     * Show loading state
     */
    private fun showLoading() {
        binding.progressBar.visibility = View.VISIBLE
        binding.contentLayout.visibility = View.GONE
        binding.errorLayout.visibility = View.GONE
    }

    /**
     * Show contact details
     */
    private fun showContactDetails(contact: Contact) {
        binding.progressBar.visibility = View.GONE
        binding.contentLayout.visibility = View.VISIBLE
        binding.errorLayout.visibility = View.GONE

        binding.contactName.text = contact.name
        binding.contactPhone.text = contact.phoneNumber
        binding.contactEmail.text = contact.email ?: "No email"

        // Setup call button
        binding.callButton.setOnClickListener {
            dialPhoneNumber(contact.phoneNumber)
        }

        // Setup SMS button
        binding.smsButton.setOnClickListener {
            sendSms(contact.phoneNumber)
        }

        // Setup email button
        binding.emailButton.apply {
            isEnabled = !contact.email.isNullOrEmpty()
            setOnClickListener {
                contact.email?.let { email ->
                    sendEmail(email)
                }
            }
        }
    }

    /**
     * Show error state
     */
    private fun showError(message: String) {
        binding.progressBar.visibility = View.GONE
        binding.contentLayout.visibility = View.GONE
        binding.errorLayout.visibility = View.VISIBLE
        binding.errorText.text = message
        binding.retryButton.setOnClickListener {
            viewModel.retry()
        }
    }

    /**
     * Dial phone number
     */
    private fun dialPhoneNumber(phoneNumber: String) {
        val intent = Intent(Intent.ACTION_DIAL).apply {
            data = Uri.parse("tel:$phoneNumber")
        }
        startActivity(intent)
    }

    /**
     * Send SMS
     */
    private fun sendSms(phoneNumber: String) {
        val intent = Intent(Intent.ACTION_SENDTO).apply {
            data = Uri.parse("smsto:$phoneNumber")
        }
        startActivity(intent)
    }

    /**
     * Send email
     */
    private fun sendEmail(email: String) {
        val intent = Intent(Intent.ACTION_SENDTO).apply {
            data = Uri.parse("mailto:$email")
        }
        startActivity(intent)
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}

