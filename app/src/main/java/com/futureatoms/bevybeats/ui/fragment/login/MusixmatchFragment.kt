package com.futureatoms.bevybeats.ui.fragment.login

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.animation.AnimationUtils
import android.widget.Toast
import androidx.compose.ui.platform.ComposeView
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.media3.common.util.UnstableApi
import androidx.navigation.fragment.findNavController
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.futureatoms.bevybeats.R
import com.futureatoms.bevybeats.databinding.FragmentMusixmatchBinding
import com.futureatoms.bevybeats.extension.isMyServiceRunning
import com.futureatoms.bevybeats.service.SimpleMediaService
import com.futureatoms.bevybeats.viewModel.MusixmatchViewModel
import com.futureatoms.bevybeats.viewModel.SharedViewModel
import dev.chrisbanes.insetter.applyInsetter
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking

class MusixmatchFragment : Fragment() {
    private var _binding: FragmentMusixmatchBinding? = null
    val binding get() = _binding!!

    private val viewModel by viewModels<MusixmatchViewModel>()
    private val sharedViewModel by activityViewModels<SharedViewModel>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?,
    ): View {
        // Inflate the layout for this fragment
        _binding = FragmentMusixmatchBinding.inflate(inflater, container, false)
        binding.topAppBar.applyInsetter {
            type(statusBars = true) {
                margin()
            }
        }
        return binding.root
    }

    override fun onViewCreated(
        view: View,
        savedInstanceState: Bundle?,
    ) {
        super.onViewCreated(view, savedInstanceState)
        val activity = requireActivity()
        val bottom = activity.findViewById<BottomNavigationView>(R.id.bottom_navigation_view)
        val miniplayer = activity.findViewById<ComposeView>(R.id.miniplayer)
        bottom.visibility = View.GONE
        miniplayer.visibility = View.GONE
        binding.btLogIn.setOnClickListener {
            if (binding.etEmail.text
                    .toString()
                    .isNotEmpty() &&
                binding.etPassword.text
                    .toString()
                    .isNotEmpty()
            ) {
                viewModel.login(binding.etEmail.text.toString(), binding.etPassword.text.toString())
            } else {
                Toast
                    .makeText(
                        requireContext(),
                        getString(R.string.please_enter_your_email_and_password),
                        Toast.LENGTH_SHORT,
                    ).show()
            }
        }
        lifecycleScope.launch {
            val loadingJob =
                launch {
                    viewModel.loading.collectLatest { loading ->
                        if (loading != null) {
                            if (loading) {
                                binding.progressBar.visibility = View.VISIBLE
                            } else {
                                binding.progressBar.visibility = View.GONE
                                Toast.makeText(requireContext(), getString(R.string.logged_in), Toast.LENGTH_SHORT).show()
                                delay(1000)
                                findNavController().navigateUp()
                            }
                        } else {
                            binding.progressBar.visibility = View.GONE
                        }
                    }
                }
            loadingJob.join()
        }
    }

    @UnstableApi
    override fun onDestroyView() {
        super.onDestroyView()
        val activity = requireActivity()
        val bottom = activity.findViewById<BottomNavigationView>(R.id.bottom_navigation_view)
        bottom.animation = AnimationUtils.loadAnimation(requireContext(), R.anim.bottom_to_top)
        bottom.visibility = View.VISIBLE
        val miniplayer = activity.findViewById<ComposeView>(R.id.miniplayer)
        if (requireActivity().isMyServiceRunning(SimpleMediaService::class.java)) {
            miniplayer.animation =
                AnimationUtils.loadAnimation(requireContext(), R.anim.bottom_to_top)
            if (runBlocking { sharedViewModel.nowPlayingState.value?.mediaItem != null }) {
                miniplayer.visibility = View.VISIBLE
            }
        }
    }
}