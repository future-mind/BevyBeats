import 'package:flutter/material.dart';
import '../models/track.dart';

class TrackTile extends StatelessWidget {
  final Track track;
  final VoidCallback onTap;
  final bool showPlayingIndicator;

  const TrackTile({
    Key? key,
    required this.track,
    required this.onTap,
    this.showPlayingIndicator = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Hero(
        tag: 'album-art-${track.videoId}',
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              track.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.music_note, color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
      title: Text(
        track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight:
              showPlayingIndicator ? FontWeight.bold : FontWeight.normal,
          color: showPlayingIndicator ? Theme.of(context).primaryColor : null,
        ),
      ),
      subtitle: Text(
        track.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPlayingIndicator)
            Container(
              width: 3,
              height: 16,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          Text(
            track.duration ?? '',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.more_vert),
        ],
      ),
      onTap: onTap,
    );
  }
}
