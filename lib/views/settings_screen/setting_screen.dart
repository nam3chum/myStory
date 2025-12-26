import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mystory/views/settings_screen/setting_viewmodel.dart';

import '../../core/constants/enums/view_type.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingVm = ref.watch(settingsProvider);
    final isDark = settingVm.themeMode == ThemeMode.dark;

    return Theme(
      data: isDark ? SettingsNotifier.buildDarkTheme() : SettingsNotifier.buildLightTheme(),
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          title: Text(
            'Cài đặt',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: ListView(
            padding: const EdgeInsets.all(0),
            children: [
              const SizedBox(height: 10),

              // Theme Section
              _buildSectionTitle('Chủ đề ', isDark),
              _buildSelectSetting(
                title: "Chủ đề",
                value: themeModeToText(settingVm.themeMode),
                onTap: () => _showThemeDialog(),
                isDark: isDark,
              ),

              // Font Settings
              _buildSectionTitle('Font chữ', isDark),

              // Language & Font Family
              _buildSelectSetting(
                title: 'Ngôn ngữ',
                value: settingVm.language,
                onTap: () => _showLanguageDialog(settingVm),
                isDark: isDark,
              ),

              _buildSelectSetting(
                title: 'Phông chữ',
                value: settingVm.fontFamily,
                onTap: () => _showFontDialog(settingVm),
                isDark: isDark,
              ),

              _buildFontSizeSetting(settingVm.fontSize, isDark),

              const SizedBox(height: 20),

              _buildPreviewSection(isDark, settingVm.fontSize, settingVm.fontFamily),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }


  Widget _buildFontSizeSetting(double fontSize, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cỡ chữ',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${fontSize.round()}px',
                style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.blue,
              inactiveTrackColor: isDark ? Colors.grey[700] : Colors.grey[300],
              thumbColor: Colors.blue,
              overlayColor: Colors.blue.withValues(alpha: 0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: fontSize,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setFontSize(value);
              },
              min: 12.0,
              max: 24.0,
              divisions: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectSetting({
    required String title,
    required String value,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(value, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[600], fontSize: 14)),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection(bool isDark, double fontSize, String fontFamily) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xem trước',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Đây là văn bản mẫu để xem trước font chữ và kích thước. '
            'Bạn có thể điều chỉnh các thiết lập ở trên để thay đổi giao diện.',
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              fontSize: fontSize,
              fontFamily: fontFamily,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(SettingsState settingVm) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor:
                settingVm.themeMode == ThemeMode.dark ? Colors.grey[900] : Colors.white,
            title: Text(
              'Chọn ngôn ngữ',
              style: TextStyle(
                color: settingVm.themeMode == ThemeMode.dark ? Colors.white : Colors.black87,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  SettingsConstants.languages
                      .map(
                        (lang) => ListTile(
                          title: Text(
                            lang,
                            style: TextStyle(
                              color:
                                  settingVm.themeMode == ThemeMode.dark
                                      ? Colors.white
                                      : Colors.black87,
                            ),
                          ),
                          trailing:
                              settingVm.language == lang
                                  ? const Icon(Icons.check, color: Colors.blue)
                                  : null,
                          onTap: () {
                            ref.read(settingsProvider.notifier).setLanguage(lang);
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }

  void _showThemeDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        final themeProvider = ref.read(settingsProvider.notifier);
        return AlertDialog(
          title: const Text('Chọn chủ đề'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.light_mode),
                title: const Text('Sáng'),
                onTap: () {
                  themeProvider.setTheme(ThemeMode.light);
                  Navigator.pop(dialogContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Tối'),
                onTap: () {
                  themeProvider.setTheme(ThemeMode.dark);
                  Navigator.pop(dialogContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone_android),
                title: const Text('Theo hệ thống'),
                onTap: () {
                  themeProvider.setTheme(ThemeMode.system);
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFontDialog(SettingsState settingVm) {

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor:
                settingVm.themeMode == ThemeMode.dark ? Colors.grey[900] : Colors.white,
            title: Text(
              'Chọn phông chữ',
              style: TextStyle(
                color: settingVm.themeMode == ThemeMode.dark ? Colors.white : Colors.black87,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  SettingsConstants.availableFonts
                      .map(
                        (font) => ListTile(
                          title: Text(
                            font,
                            style: TextStyle(
                              fontFamily: font,
                              color:
                                  settingVm.themeMode == ThemeMode.dark
                                      ? Colors.white
                                      : Colors.black87,
                            ),
                          ),
                          trailing:
                              settingVm.fontFamily == font
                                  ? const Icon(Icons.check, color: Colors.blue)
                                  : null,
                          onTap: () {
                            ref.read(settingsProvider.notifier).setFontFamily(font);
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }
}
