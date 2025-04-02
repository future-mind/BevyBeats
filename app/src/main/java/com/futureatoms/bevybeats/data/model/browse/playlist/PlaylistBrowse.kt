package com.futureatoms.bevybeats.data.model.browse.playlist

import androidx.compose.runtime.Immutable
import com.futureatoms.kotlinytmusicscraper.models.WatchEndpoint
import com.futureatoms.bevybeats.data.model.browse.album.Track
import com.futureatoms.bevybeats.data.model.searchResult.songs.Thumbnail

@Immutable
data class PlaylistBrowse(
    val author: Author,
    val description: String?,
    val duration: String,
    val durationSeconds: Int,
    val id: String,
    val privacy: String,
    val thumbnails: List<Thumbnail>,
    val title: String,
    val trackCount: Int,
    val tracks: List<Track>,
    val year: String,
    val shuffleEndpoint: WatchEndpoint? = null,
    val radioEndpoint: WatchEndpoint? = null,
)