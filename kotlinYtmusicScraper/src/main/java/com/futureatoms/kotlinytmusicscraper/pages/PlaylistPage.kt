package com.futureatoms.kotlinytmusicscraper.pages

import com.futureatoms.kotlinytmusicscraper.models.Album
import com.futureatoms.kotlinytmusicscraper.models.Artist
import com.futureatoms.kotlinytmusicscraper.models.MusicResponsiveListItemRenderer
import com.futureatoms.kotlinytmusicscraper.models.PlaylistItem
import com.futureatoms.kotlinytmusicscraper.models.SongItem
import com.futureatoms.kotlinytmusicscraper.models.oddElements
import com.futureatoms.kotlinytmusicscraper.utils.parseTime

data class PlaylistPage(
    val playlist: PlaylistItem,
    val songs: List<SongItem>,
    val songsContinuation: String?,
    val continuation: String?,
) {
    companion object {
        fun fromMusicResponsiveListItemRenderer(renderer: MusicResponsiveListItemRenderer?): SongItem? {
            if (renderer == null) {
                return null
            } else {
                return SongItem(
                    id = renderer.playlistItemData?.videoId ?: return null,
                    title =
                        renderer.flexColumns
                            .firstOrNull()
                            ?.musicResponsiveListItemFlexColumnRenderer
                            ?.text
                            ?.runs
                            ?.firstOrNull()
                            ?.text ?: return null,
                    artists =
                        renderer.flexColumns
                            .getOrNull(1)
                            ?.musicResponsiveListItemFlexColumnRenderer
                            ?.text
                            ?.runs
                            ?.oddElements()
                            ?.map {
                                Artist(
                                    name = it.text,
                                    id = it.navigationEndpoint?.browseEndpoint?.browseId,
                                )
                            } ?: return null,
                    album =
                        renderer.flexColumns.getOrNull(2)?.musicResponsiveListItemFlexColumnRenderer?.text?.runs?.firstOrNull()?.let {
                            Album(
                                name = it.text,
                                id = it.navigationEndpoint?.browseEndpoint?.browseId ?: return null,
                            )
                        },
                    duration =
                        renderer.fixedColumns
                            ?.firstOrNull()
                            ?.musicResponsiveListItemFlexColumnRenderer
                            ?.text
                            ?.runs
                            ?.firstOrNull()
                            ?.text
                            ?.parseTime(),
                    thumbnail = renderer.thumbnail?.musicThumbnailRenderer?.getThumbnailUrl() ?: return null,
                    explicit =
                        renderer.badges?.find {
                            it.musicInlineBadgeRenderer?.icon?.iconType == "MUSIC_EXPLICIT_BADGE"
                        } != null,
                    endpoint =
                        renderer.overlay
                            ?.musicItemThumbnailOverlayRenderer
                            ?.content
                            ?.musicPlayButtonRenderer
                            ?.playNavigationEndpoint
                            ?.watchEndpoint,
                    thumbnails = renderer.thumbnail.musicThumbnailRenderer.thumbnail,
                )
            }
        }
    }
}