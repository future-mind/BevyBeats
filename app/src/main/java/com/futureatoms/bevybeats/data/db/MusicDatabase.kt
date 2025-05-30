package com.futureatoms.bevybeats.data.db

import androidx.room.AutoMigration
import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.futureatoms.bevybeats.data.db.entities.AlbumEntity
import com.futureatoms.bevybeats.data.db.entities.ArtistEntity
import com.futureatoms.bevybeats.data.db.entities.FollowedArtistSingleAndAlbum
import com.futureatoms.bevybeats.data.db.entities.GoogleAccountEntity
import com.futureatoms.bevybeats.data.db.entities.LocalPlaylistEntity
import com.futureatoms.bevybeats.data.db.entities.LyricsEntity
import com.futureatoms.bevybeats.data.db.entities.NewFormatEntity
import com.futureatoms.bevybeats.data.db.entities.NotificationEntity
import com.futureatoms.bevybeats.data.db.entities.PairSongLocalPlaylist
import com.futureatoms.bevybeats.data.db.entities.PlaylistEntity
import com.futureatoms.bevybeats.data.db.entities.QueueEntity
import com.futureatoms.bevybeats.data.db.entities.SearchHistory
import com.futureatoms.bevybeats.data.db.entities.SetVideoIdEntity
import com.futureatoms.bevybeats.data.db.entities.SongEntity
import com.futureatoms.bevybeats.data.db.entities.SongInfoEntity

@Database(
    entities = [
        NewFormatEntity::class, SongInfoEntity::class, SearchHistory::class, SongEntity::class, ArtistEntity::class,
        AlbumEntity::class, PlaylistEntity::class, LocalPlaylistEntity::class, LyricsEntity::class, QueueEntity::class,
        SetVideoIdEntity::class, PairSongLocalPlaylist::class, GoogleAccountEntity::class, FollowedArtistSingleAndAlbum::class,
        NotificationEntity::class,
    ],
    version = 13,
    exportSchema = true,
    autoMigrations = [
        AutoMigration(from = 2, to = 3), AutoMigration(
            from = 1,
            to = 3,
        ), AutoMigration(from = 3, to = 4), AutoMigration(from = 2, to = 4), AutoMigration(
            from = 3,
            to = 5,
        ), AutoMigration(4, 5), AutoMigration(6, 7), AutoMigration(
            7,
            8,
            spec = AutoMigration7_8::class,
        ), AutoMigration(8, 9),
        AutoMigration(9, 10),
        AutoMigration(from = 11, to = 12, spec = AutoMigration11_12::class),
    ],
)
@TypeConverters(Converters::class)
abstract class MusicDatabase : RoomDatabase() {
    abstract fun getDatabaseDao(): DatabaseDao
}