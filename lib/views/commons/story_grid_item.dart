import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/genre_model.dart';
import '../../data/models/story_model.dart';

class StoryGridItem extends ConsumerWidget {
  final Story story;
  final List<Genre> listGenre;
  final Color accentColor;
  final double fontSize;

  const StoryGridItem({
    super.key,
    required this.fontSize,
    required this.story,
    required this.listGenre,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double base = fontSize / 16.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image placeholder
            Container(
              width: 130 * base,
              height: 210 * base,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(color: accentColor.withAlpha(77), blurRadius: 10, offset: const Offset(2, 2)),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child:
                    story.imgUrl.trim().isNotEmpty
                        ? Stack(
                          children: [
                            SizedBox(
                              width: 130 * base,
                              height: 210 * base,
                              child: Image.network(
                                story.imgUrl,
                                fit: BoxFit.cover,
                                width: 130 * base,
                                height: 210 * base,
                                alignment: Alignment.topCenter,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildImagePlaceholder(accentColor);
                                },
                              ),
                            ),
                            Container(
                              width: 130,
                              height: 210,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, accentColor.withAlpha(25)],
                                ),
                              ),
                            ),
                          ],
                        )
                        : _buildImagePlaceholder(accentColor),
              ),
            ),

            // Content overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                ),
              ),
            ),

            // Text content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Status badge
                    if (story.status.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(story.status),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          story.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),

                    // Title
                    Text(
                      story.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Chapter
                    Text(
                      "Chương ${story.numberOfChapter}",
                      style: TextStyle(color: Colors.grey[300], fontSize: 9, height: 1.1),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(Color color) {
    return Container(
      color: color.withValues(alpha: 0.1),
      child: const Center(child: Icon(Icons.auto_stories, size: 40, color: Colors.grey)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case '[c]':
        return Colors.green;
      case 'hot':
        return Colors.red;
      case 'new':
        return Colors.blue;
      case 'dịch':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
