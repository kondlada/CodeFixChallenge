package com.ai.codefixchallange.presentation.contacts

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import com.ai.codefixchallange.R
import com.ai.codefixchallange.databinding.FragmentContactsBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.launch

/**
 * Fragment for displaying the list of contacts
 * Uses RecyclerView to display contacts efficiently
 */
@AndroidEntryPoint
class ContactsFragment : Fragment() {

    private var _binding: FragmentContactsBinding? = null
    private val binding get() = _binding!!

    private val viewModel: ContactsViewModel by viewModels()
    private lateinit var adapter: ContactsAdapter

    private val requestPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        if (isGranted) {
            viewModel.syncContacts()
        } else {
            Toast.makeText(
                requireContext(),
                "Permission denied. Cannot access contacts.",
                Toast.LENGTH_LONG
            ).show()
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentContactsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        setupRecyclerView()
        observeState()
        setupSwipeRefresh()
    }

    /**
     * Setup RecyclerView with adapter and layout manager
     */
    private fun setupRecyclerView() {
        adapter = ContactsAdapter { contact ->
            // Navigate to detail fragment
            val action = ContactsFragmentDirections
                .actionContactsFragmentToContactDetailFragment(contact.id)
            findNavController().navigate(action)
        }

        binding.recyclerView.apply {
            layoutManager = LinearLayoutManager(requireContext())
            adapter = this@ContactsFragment.adapter
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
                        is ContactsState.Loading -> {
                            showLoading()
                        }
                        is ContactsState.Success -> {
                            showContacts(state.contacts.size)
                            adapter.submitList(state.contacts)
                        }
                        is ContactsState.Error -> {
                            showError(state.message)
                        }
                        is ContactsState.PermissionRequired -> {
                            requestContactPermission()
                        }
                    }
                }
            }
        }
    }

    /**
     * Setup swipe to refresh functionality
     */
    private fun setupSwipeRefresh() {
        binding.swipeRefresh.setOnRefreshListener {
            viewModel.syncContacts()
        }
    }

    /**
     * Show loading state
     */
    private fun showLoading() {
        binding.progressBar.visibility = View.VISIBLE
        binding.recyclerView.visibility = View.GONE
        binding.errorLayout.visibility = View.GONE
        binding.swipeRefresh.isRefreshing = false
    }

    /**
     * Show contacts
     */
    private fun showContacts(count: Int) {
        binding.progressBar.visibility = View.GONE
        binding.recyclerView.visibility = View.VISIBLE
        binding.errorLayout.visibility = View.GONE
        binding.swipeRefresh.isRefreshing = false

        // Don't show error for empty list - let RecyclerView show empty state
        // This was the bug: count == 0 was showing error and hiding RecyclerView
        // Now contacts can be displayed even if initially empty
    }

    /**
     * Show error state
     */
    private fun showError(message: String) {
        binding.progressBar.visibility = View.GONE
        binding.recyclerView.visibility = View.GONE
        binding.errorLayout.visibility = View.VISIBLE
        binding.errorText.text = message
        binding.retryButton.setOnClickListener {
            viewModel.retry()
        }
        binding.swipeRefresh.isRefreshing = false
    }

    /**
     * Request contact permission
     */
    private fun requestContactPermission() {
        when {
            ContextCompat.checkSelfPermission(
                requireContext(),
                Manifest.permission.READ_CONTACTS
            ) == PackageManager.PERMISSION_GRANTED -> {
                viewModel.syncContacts()
            }
            shouldShowRequestPermissionRationale(Manifest.permission.READ_CONTACTS) -> {
                // Show rationale
                showError("Contact permission is required to display contacts")
                binding.retryButton.setOnClickListener {
                    requestPermissionLauncher.launch(Manifest.permission.READ_CONTACTS)
                }
            }
            else -> {
                requestPermissionLauncher.launch(Manifest.permission.READ_CONTACTS)
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}

