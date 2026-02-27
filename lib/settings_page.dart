// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:aura_app/widgets/glass_container.dart';
import 'package:aura_app/theme/app_colors.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback? onToggleSidebar;
  final bool isRightSide;
  
  const SettingsPage({
    super.key, 
    this.onToggleSidebar,
    this.isRightSide = true,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  bool _autoPlayVideos = false;
  bool _dataSaverMode = false;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Search Bar
                    GlassContainer(
                      height: 45,
                      borderRadius: 22.5,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: AppColors.textTertiary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value.toLowerCase();
                                });
                              },
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search settings...',
                                hintStyle: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Settings Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 10),
                
                // Account Section
                _buildSectionHeader('Account'),
                _buildSettingsGroup([
                  _buildSettingItem(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    subtitle: 'Manage your profile information',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.security_outlined,
                    title: 'Privacy',
                    subtitle: 'Control your privacy settings',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.verified_user_outlined,
                    title: 'Security',
                    subtitle: 'Password and authentication',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.block_outlined,
                    title: 'Blocked Accounts',
                    subtitle: 'Manage blocked users',
                    onTap: () {},
                  ),
                ]),

                const SizedBox(height: 24),

                // Preferences Section
                _buildSectionHeader('Preferences'),
                _buildSettingsGroup([
                  _buildSettingItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Push notifications',
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                      activeColor: AppColors.photonBlue,
                    ),
                  ),
                  _buildSettingItem(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: 'Always on',
                    trailing: Switch(
                      value: _darkModeEnabled,
                      onChanged: (value) {
                        setState(() {
                          _darkModeEnabled = value;
                        });
                      },
                      activeColor: AppColors.photonBlue,
                    ),
                  ),
                  _buildSettingItem(
                    icon: Icons.language_outlined,
                    title: 'Language',
                    subtitle: 'English (US)',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.access_time_outlined,
                    title: 'Time Zone',
                    subtitle: 'Auto-detect',
                    onTap: () {},
                  ),
                ]),

                const SizedBox(height: 24),

                // Content Section
                _buildSectionHeader('Content & Display'),
                _buildSettingsGroup([
                  _buildSettingItem(
                     icon: Icons.dock_outlined,
                     title: 'Sidebar Position',
                     subtitle: widget.isRightSide ? 'Right Side' : 'Left Side',
                     trailing: Icon(
                        widget.isRightSide ? Icons.align_horizontal_right : Icons.align_horizontal_left,
                        color: AppColors.photonBlue,
                     ),
                     onTap: widget.onToggleSidebar,
                  ),
                  _buildSettingItem(
                    icon: Icons.play_circle_outline,
                    title: 'Auto-play Videos',
                    subtitle: 'Play videos automatically',
                    trailing: Switch(
                      value: _autoPlayVideos,
                      onChanged: (value) {
                        setState(() {
                          _autoPlayVideos = value;
                        });
                      },
                      activeColor: AppColors.photonBlue,
                    ),
                  ),
                  _buildSettingItem(
                    icon: Icons.data_saver_on_outlined,
                    title: 'Data Saver',
                    subtitle: 'Reduce data usage',
                    trailing: Switch(
                      value: _dataSaverMode,
                      onChanged: (value) {
                        setState(() {
                          _dataSaverMode = value;
                        });
                      },
                      activeColor: AppColors.photonBlue,
                    ),
                  ),
                  _buildSettingItem(
                    icon: Icons.image_outlined,
                    title: 'Media Quality',
                    subtitle: 'High quality',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.download_outlined,
                    title: 'Download Settings',
                    subtitle: 'Manage downloads',
                    onTap: () {},
                  ),
                ]),

                const SizedBox(height: 24),

                // Support Section
                _buildSectionHeader('Support & About'),
                _buildSettingsGroup([
                  _buildSettingItem(
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    subtitle: 'Get help and support',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.feedback_outlined,
                    title: 'Send Feedback',
                    subtitle: 'Share your thoughts',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'Version 1.0.0',
                    onTap: () {},
                  ),
                ]),

                const SizedBox(height: 24),

                // Danger Zone
                _buildSectionHeader('Account Actions'),
                _buildSettingsGroup([
                  _buildSettingItem(
                    icon: Icons.logout,
                    title: 'Log Out',
                    titleColor: AppColors.sunsetCoral,
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.delete_outline,
                    title: 'Delete Account',
                    titleColor: Colors.red,
                    onTap: () {},
                  ),
                ]),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> items) {
    return GlassContainer(
      borderRadius: 16,
      padding: EdgeInsets.zero,
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    // Filter based on search
    if (_searchQuery.isNotEmpty &&
        !title.toLowerCase().contains(_searchQuery) &&
        (subtitle == null || !subtitle.toLowerCase().contains(_searchQuery))) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.sunsetCoral.withOpacity(0.1),
        highlightColor: AppColors.sunsetCoral.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.twilight.withOpacity(0.5),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.sunsetCoral.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: titleColor ?? AppColors.sunsetCoral,
                ),
              ),
              const SizedBox(width: 14),
              
              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: titleColor ?? AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Trailing
              if (trailing != null)
                trailing
              else if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
