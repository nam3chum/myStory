import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mystory/core/constants/text_styles/app_text_styles.dart';
import 'package:mystory/views/settings_screen/setting_viewmodel.dart';

import '../../services/truyen_crawler/src/models/detail_models.dart';
import '../../services/truyen_crawler/src/models/story.dart';

class StoryListItem extends ConsumerWidget {
  final Story story;
  final BuildContext context;
  final int index;

  final List<Color> gradientColors;

  const StoryListItem({
    required this.story,
    required this.context,
    required this.index,
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
                    child: Image.network(
                      story.cover ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: accentColor.withValues(alpha: 0.1),
                          child: Icon(Icons.auto_stories, color: accentColor.withValues(alpha: 0.5)),
                        );
                      },
                    )),
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
                              color: _getStatusColor(story.status ?? '').withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusToString(story.status ?? ''),
                              style: TextStyle(
                                fontSize: 11,
                                color: _getStatusColor(story.status ?? ''),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // const SizedBox(width: 8),
                          // Text(
                          //   '${story.status}',
                          //   style: TextStyle(
                          //     fontSize: 11,
                          //     fontWeight: FontWeight.w600,
                          //     color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  'Chương ${story.chapter.toString()}',
                  style: TextStyle(
                    fontSize: 11,
                    color: _getStatusColor(story.status ?? ''),
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

String statusToString(String status) {
  switch (status.toLowerCase()) {
    case 'true':
      return 'Hoàn thành';
    case 'false':
      return 'Đang ra';
    default:
      return 'Tạm dừng';
  }
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'Hoàn thành':
    case 'completed':
    case 'true':
      return Colors.green;
    case 'Đang ra':
    case 'ongoing':
    case 'false':
      return Colors.blue;
    case 'tạm dừng':
    case 'paused':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}
