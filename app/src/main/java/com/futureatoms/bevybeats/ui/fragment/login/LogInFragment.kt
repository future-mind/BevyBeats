package com.futureatoms.bevybeats.ui.fragment.login

import android.annotation.SuppressLint
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.animation.AnimationUtils
import android.webkit.CookieManager
import android.webkit.WebStorage
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.Toast
import androidx.compose.ui.platform.ComposeView
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.fragment.app.viewModels
import androidx.media3.common.util.UnstableApi
import androidx.navigation.fragment.findNavController
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.futureatoms.bevybeats.R
import com.futureatoms.bevybeats.common.Config
import com.futureatoms.bevybeats.databinding.FragmentLogInBinding
import com.futureatoms.bevybeats.extension.isMyServiceRunning
import com.futureatoms.bevybeats.service.SimpleMediaService
import com.futureatoms.bevybeats.viewModel.LogInViewModel
import com.futureatoms.bevybeats.viewModel.SettingsViewModel
import com.futureatoms.bevybeats.viewModel.SharedViewModel
import dev.chrisbanes.insetter.applyInsetter
import kotlinx.coroutines.runBlocking

class LogInFragment : Fragment() {
    private var _binding: FragmentLogInBinding? = null
    val binding get() = _binding!!

    private val viewModel by viewModels<LogInViewModel>()
    private val settingsViewModel by activityViewModels<SettingsViewModel>()
    private val sharedViewModel by activityViewModels<SharedViewModel>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?,
    ): View {
        _binding = FragmentLogInBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(
        view: View,
        savedInstanceState: Bundle?,
    ) {
        super.onViewCreated(view, savedInstanceState)
        binding.topAppBarLayout.applyInsetter {
            type(statusBars = true) {
                margin()
            }
        }
        val activity = requireActivity()
        val bottom = activity.findViewById<BottomNavigationView>(R.id.bottom_navigation_view)
        val miniplayer = activity.findViewById<ComposeView>(R.id.miniplayer)
        bottom.visibility = View.GONE
        miniplayer.visibility = View.GONE
        binding.webView.apply {
            webViewClient =
                object : WebViewClient() {
                    @SuppressLint("FragmentLiveDataObserve")
                    @UnstableApi
                    override fun onPageFinished(
                        view: WebView?,
                        url: String?,
                    ) {
                        if (url == Config.YOUTUBE_MUSIC_MAIN_URL) {
                            CookieManager.getInstance().getCookie(url)?.let {
                                settingsViewModel.addAccount(it)
                            }
                            WebStorage.getInstance().deleteAllData()

                            // Clear all the cookies
                            CookieManager.getInstance().removeAllCookies(null)
                            CookieManager.getInstance().flush()

                            binding.webView.clearCache(true)
                            binding.webView.clearFormData()
                            binding.webView.clearHistory()
                            binding.webView.clearSslPreferences()
                            Toast
                                .makeText(
                                    requireContext(),
                                    R.string.login_success,
                                    Toast.LENGTH_SHORT,
                                ).show()
                            findNavController().navigateUp()
                        }
                    }
                }
            settings.javaScriptEnabled = true
            settings.domStorageEnabled = true
            loadUrl(Config.LOG_IN_URL)
        }
        binding.topAppBar.setNavigationOnClickListener {
            findNavController().navigateUp()
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