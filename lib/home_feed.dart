// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:aura_app/widgets/glass_container.dart';
import 'package:aura_app/theme/app_colors.dart';

class HomeFeed extends StatelessWidget {
  const HomeFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// STORIES SECTION
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: 10,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.sunsetCoral.withOpacity(0.8), width: 2.5),
                        gradient: const LinearGradient(
                          colors: [AppColors.sunsetCoral, AppColors.terracotta],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.5),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.midnightInk,
                          ),
                          child: const Icon(Icons.person, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "User $index",
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    )
                  ],
                ),
              );
            },
          ),
        ),

        Divider(color: AppColors.twilight.withOpacity(0.5), height: 1),

        /// POSTS SECTION
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              return _PostCard(index: index);
            },
          ),
        ),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  final int index;
  const _PostCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      enableBlur: false,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: AppColors.twilight,
              child: const Icon(Icons.person, size: 20, color: AppColors.textPrimary),
            ),
            title: Row(
              children: [
                Text(
                  "Creator $index",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 4),
                // Verified badge with Halo Gold emotion color (show on even indexes)
                if (index % 2 == 0)
                  const Icon(
                    Icons.verified,
                    size: 16,
                    color: AppColors.haloGold,
                  ),
              ],
            ),
            subtitle: const Text(
              "2 hours ago",
              style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
            trailing: const Icon(Icons.more_vert, color: AppColors.textTertiary),
          ),

          /// IMAGE PLACEHOLDER
          Container(
            height: 250,
            width: double.infinity,
            color: AppColors.twilight.withOpacity(0.4),
            child: const Center(
              child: Icon(Icons.blur_on, size: 50, color: AppColors.textTertiary),
            ),
          ),

          /// ACTIONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                _ActionButton(icon: Icons.favorite_border, label: "2.4k", isLikeButton: true),
                const SizedBox(width: 16),
                _ActionButton(icon: Icons.chat_bubble_outline, label: "480"),
                const Spacer(),
                const _SaveButton(),
              ],
            ),
          ),

          /// CAPTION
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: AppColors.textSecondary),
                children: [
                  const TextSpan(
                    text: "Abstract Art ",
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  TextSpan(
                    text: "Exploring the depths of ocean aesthetics. #Aura #Blue $index",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isLikeButton;
  
  const _ActionButton({
    required this.icon, 
    required this.label,
    this.isLikeButton = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isLikeButton) {
      setState(() {
        _isLiked = !_isLiked;
      });
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.isLikeButton && _isLiked;
    final Color iconColor = isActive ? AppColors.lightRose : AppColors.textSecondary;
    
    return GestureDetector(
      onTap: _handleTap,
      child: Row(
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              isActive ? Icons.favorite : widget.icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            widget.label,
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Save/Bookmark Button with Clean Mint emotion color
class _SaveButton extends StatefulWidget {
  const _SaveButton();

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSaved = !_isSaved;
        });
      },
      child: Icon(
        _isSaved ? Icons.bookmark : Icons.bookmark_border,
        color: _isSaved ? AppColors.cleanMint : AppColors.textSecondary,
        size: 24,
      ),
    );
  }
}

