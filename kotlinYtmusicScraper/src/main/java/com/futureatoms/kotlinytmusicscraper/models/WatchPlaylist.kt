package com.futureatoms.kotlinytmusicscraper.models

data class WatchPlaylist(
    val title: String?,
    val playlistId: String?,
    val thumbnails: List<Thumbnail>?,
)