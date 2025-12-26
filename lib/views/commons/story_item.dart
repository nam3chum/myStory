import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mystory/core/constants/text_styles/app_text_styles.dart';
import 'package:mystory/views/settings_screen/setting_viewmodel.dart';

import '../../data/models/genre_model.dart';
import '../../data/models/story_model.dart';

class StoryListItem extends ConsumerWidget {
  final Story story;
  final BuildContext context;
  final int index;

  final List<Genre> listGenre;
  final List<Color> gradientColors;

  const StoryListItem({
    required this.story,
    required this.context,
    required this.index,
    required this.listGenre,
    required this.gradientColors,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(settingsProvider.select((value) => value.fontSize));
    final accentColor = gradientColors[index % gradientColors.length];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: InkWell(
          child: Row(
            children: [
              // Hình ảnh truyện nhỏ gọn
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 120,
                  child: story.imgUrl.trim().isNotEmpty
                      ? Image.network(
                          story.imgUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: accentColor.withValues(alpha: 0.1),
                              child: Icon(Icons.auto_stories, color: accentColor.withValues(alpha: 0.5)),
                            );
                          },
                        )
                      : Container(
                          color: accentColor.withValues(alpha: 0.1),
                          child: Icon(Icons.auto_stories, color: accentColor.withValues(alpha: 0.5)),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Nội dung truyện
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tiêu đề
                      Text(
                        story.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(context: context, ref: ref, fontSize: fontSize),
                      ),
                      const SizedBox(height: 4),
                      // Tác giả
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 12, color: accentColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              story.author,
                              style: TextStyle(
                                fontSize: fontSize - 3,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Trạng thái + Số chương
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(story.status).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              story.status,
                              style: TextStyle(
                                fontSize: 11,
                                color: _getStatusColor(story.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${story.numberOfChapter} chương',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Thời gian cập nhật
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  'Vừa xong',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'hoàn thành':
    case 'completed':
      return Colors.green;
    case 'đang tiến hành':
    case 'ongoing':
      return Colors.blue;
    case 'tạm dừng':
    case 'paused':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}
