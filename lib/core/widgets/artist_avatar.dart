import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/artist.dart';

/// Circular artist image with a graceful initials fallback (most seed artists
/// have no [Artist.imageUrl] yet). Background colour is derived from the id so
/// the same artist always gets the same colour.
class ArtistAvatar extends StatelessWidget {
  const ArtistAvatar({super.key, required this.artist, this.radius = 28});

  final Artist artist;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color = Color(
      0xFF000000 | (artist.id.hashCode & 0x00808080) | 0x00404040,
    );
    final initials = artist.name.isNotEmpty
        ? artist.name.trim().split(' ').take(2).map((w) => w[0]).join()
        : '?';

    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.7,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    if (artist.imageUrl == null || artist.imageUrl!.isEmpty) return fallback;

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: artist.imageUrl!,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        placeholder: (_, _) => fallback,
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}
