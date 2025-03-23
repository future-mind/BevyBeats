class Track {
  final String videoId;
  final String title;
  final String artist;
  final String thumbnailUrl;
  final String streamUrl;
  final int durationSeconds;
  final String? album;
  final String? duration; // Formatted duration like "3:45"

  Track({
    required this.videoId,
    required this.title,
    required this.artist,
    required this.thumbnailUrl,
    required this.streamUrl,
    required this.durationSeconds,
    this.album,
    this.duration,
  });

  // Create a Track from a JSON map from YouTube Music API
  factory Track.fromYouTubeJson(Map<String, dynamic> json, String streamUrl) {
    // Parse duration string to seconds
    int durationToSeconds(String? durationStr) {
      if (durationStr == null || durationStr.isEmpty) return 0;

      // Handle different duration formats
      if (durationStr.contains(':')) {
        final parts = durationStr.split(':').map(int.parse).toList();
        if (parts.length == 2) {
          // mm:ss format
          return parts[0] * 60 + parts[1];
        } else if (parts.length == 3) {
          // hh:mm:ss format
          return parts[0] * 3600 + parts[1] * 60 + parts[2];
        }
      }
      return 0;
    }

    return Track(
      videoId: json['videoId'] ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      thumbnailUrl: json['thumbnail'] ?? '',
      streamUrl: streamUrl,
      durationSeconds:
          json['lengthSeconds'] != null
              ? int.tryParse(json['lengthSeconds'].toString()) ??
                  durationToSeconds(json['duration'])
              : durationToSeconds(json['duration']),
      album: json['album'],
      duration: json['duration'],
    );
  }

  // Create a copy of this Track with optional modified properties
  Track copyWith({
    String? videoId,
    String? title,
    String? artist,
    String? thumbnailUrl,
    String? streamUrl,
    int? durationSeconds,
    String? album,
    String? duration,
  }) {
    return Track(
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      streamUrl: streamUrl ?? this.streamUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      album: album ?? this.album,
      duration: duration ?? this.duration,
    );
  }

  // Convert Track to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'title': title,
      'artist': artist,
      'thumbnailUrl': thumbnailUrl,
      'streamUrl': streamUrl,
      'durationSeconds': durationSeconds,
      'album': album,
      'duration': duration,
    };
  }

  @override
  String toString() {
    return 'Track{videoId: $videoId, title: $title, artist: $artist}';
  }
}
