class Track {
  final String id;
  final String title;
  final String artist;
  final String albumArt;
  final String videoId;
  final String source; // 'youtube', 'soundcloud', or 'fma'

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumArt,
    required this.videoId,
    required this.source,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      albumArt: json['albumArt'] ?? '',
      videoId: json['videoId'] ?? '',
      source: json['source'] ?? 'youtube',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'albumArt': albumArt,
      'videoId': videoId,
      'source': source,
    };
  }
}
