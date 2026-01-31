import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../chapter_viewmodel.dart';

class PlaySheetBottom extends ConsumerWidget {
  final String chapterTitle;
   const PlaySheetBottom({super.key, required this.chapterTitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(chapterViewModelProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Color(0xFFD4C4A8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tiến độ đọc
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0.4%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.brown[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    chapterTitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.brown[800],
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Thanh tiến độ
          Row(
            children: [
              Text(
                'Trước',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.brown[700],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 16,
                      ),
                      activeTrackColor: Colors.brown[800],
                      inactiveTrackColor: Colors.brown[300],
                      thumbColor: Colors.brown[900],
                      overlayColor: Colors.brown[800]?.withValues(alpha: 0.2),
                    ),
                    child: Slider(
                      value: 0.004,
                      min: 0,
                      max: 1,
                      onChanged: (value) {
                        // TODO: Implement scroll to position
                      },
                    ),
                  ),
                ),
              ),
              Text(
                'Tiếp',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.brown[700],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Các nút điều khiển
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildIconButton(
                icon: Icons.menu,
                onPressed: () {
                  ///hiển thị với showmodelbottomsheet
                  // showModalBottomSheet(
                  //   context: context,
                  //   isScrollControlled: true,
                  //   backgroundColor: Colors.transparent,
                  //   builder: (context) => const ChapterListBottomSheet(),
                  // );

                  ///hiển thị side bar dạng drawer
                  Scaffold.of(context).openDrawer();
                },
              ),
              _buildIconButton(
                icon: Icons.turned_in_outlined,
                onPressed: () {
                  // TODO: Sao chép
                },
              ),
              _buildIconButton(
                icon: Icons.headphones,
                onPressed: () {
                  // TODO: Phát âm thanh
                },
              ),
              _buildIconButton(
                icon: Icons.settings,
                onPressed: () {
                  // TODO: Mở cài đặt
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.brown[100]?.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon),
        iconSize: 24,
        color: Colors.brown[800],
        onPressed: onPressed,
      ),
    );
  }
}
