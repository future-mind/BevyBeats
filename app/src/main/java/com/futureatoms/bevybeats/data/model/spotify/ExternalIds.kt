package com.futureatoms.bevybeats.data.model.spotify

import com.google.gson.annotations.SerializedName

data class ExternalIds(
    @SerializedName("isrc")
    val isrc: String?,
)