package com.futureatoms.bevybeats.data.db.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.futureatoms.bevybeats.common.DownloadState
import com.futureatoms.bevybeats.data.type.PlaylistType
import com.futureatoms.bevybeats.data.type.RecentlyType
import java.time.LocalDateTime

@Entity(tableName = "album")
data class AlbumEntity(
    @PrimaryKey(autoGenerate = false) val browseId: String = "",
    val artistId: List<String?>? = null,
    val artistName: List<String>? = null,
    val audioPlaylistId: String,
    val description: String,
    val duration: String?,
    val durationSeconds: Int,
    val thumbnails: String?,
    val title: String,
    val trackCount: Int,
    val tracks: List<String>? = null,
    val type: String,
    val year: String?,
    val liked: Boolean = false,
    val inLibrary: LocalDateTime = LocalDateTime.now(),
    val downloadState: Int = DownloadState.STATE_NOT_DOWNLOADED,
) : PlaylistType,
    RecentlyType {
    override fun objectType(): RecentlyType.Type = RecentlyType.Type.ALBUM

    override fun playlistType(): PlaylistType.Type = PlaylistType.Type.ALBUM
}