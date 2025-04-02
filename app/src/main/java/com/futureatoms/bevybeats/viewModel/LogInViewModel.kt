package com.futureatoms.bevybeats.viewModel

import android.app.Application
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import androidx.media3.common.util.UnstableApi
import com.futureatoms.bevybeats.viewModel.base.BaseViewModel
import kotlinx.coroutines.launch

@UnstableApi
class LogInViewModel(
    private val application: Application,
) : BaseViewModel(application) {
    private val _spotifyStatus: MutableLiveData<Boolean> = MutableLiveData(false)
    var spotifyStatus: LiveData<Boolean> = _spotifyStatus

    fun saveSpotifySpdc(cookie: String) {
        viewModelScope.launch {
            cookie
                .split("; ")
                .filter { it.isNotEmpty() }
                .associate {
                    val (key, value) = it.split("=")
                    key to value
                }.let {
                    dataStoreManager.setSpdc(it["sp_dc"] ?: "")
                    _spotifyStatus.postValue(true)
                }
        }
    }
}