import 'package:flutter/material.dart';
import 'package:aura_app/widgets/glass_container.dart';
import 'package:aura_app/theme/app_colors.dart';
import 'package:aura_app/services/api_service.dart';
import 'package:aura_app/models/post_model.dart';
import 'package:aura_app/models/story_model.dart';
import 'package:aura_app/core/performance/optimized_image_manager.dart';

class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key});

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  late Future<List<Post>> _postsFuture;
  late Future<List<Story>> _storiesFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = ApiService().getPosts();
    _storiesFuture = ApiService().getStories();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// STORIES SECTION
        SizedBox(
          height: 110,
          child: FutureBuilder<List<Story>>(
            future: _storiesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                 return const Center(child: CircularProgressIndicator(color: AppColors.sunsetCoral));
              }
              final stories = snapshot.data ?? [];
              // Return mock stories if empty for now to maintain UI look if backend empty
              final itemCount = stories.isEmpty ? 10 : stories.length;
              
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  if (stories.isEmpty) {
                     return _buildStoryItem(index.toString(), "User $index");
                  }
                  final story = stories[index];
                  return _buildStoryItem(story.user?.profilePicture, story.user?.username ?? 'User');
                },
              );
            },
          ),
        ),

        Divider(color: AppColors.twilight.withOpacity(0.5), height: 1),

        /// POSTS SECTION
        Expanded(
          child: FutureBuilder<List<Post>>(
            future: _postsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.sunsetCoral));
              }
              final posts = snapshot.data ?? [];
              
              if (posts.isEmpty) {
                return const Center(child: Text("No posts yet", style: TextStyle(color: Colors.white)));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  return _PostCard(post: posts[index], index: index);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoryItem(String? imageUrl, String name) {
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
                child: imageUrl != null && imageUrl.startsWith('http')
                  ? ClipOval(
                      child: OptimizedNetworkImage(
                        imageUrl: imageUrl, 
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.person, color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            name,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          )
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  final int index;
  const _PostCard({required this.post, required this.index});

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
              backgroundImage: post.user?.profilePicture != null
                  ? NetworkImage(post.user!.profilePicture!)
                  : null,
              child: post.user?.profilePicture == null 
                  ? const Icon(Icons.person, size: 20, color: AppColors.textPrimary) 
                  : null,
            ),
            title: Row(
              children: [
                Text(
                  post.user?.username ?? "Creator",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 4),
                // Verified badge logic could be real later
                if (index % 2 == 0)
                  const Icon(
                    Icons.verified,
                    size: 16,
                    color: AppColors.haloGold,
                  ),
              ],
            ),
            subtitle: Text(
              _timeAgo(post.createdAt),
              style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
            trailing: const Icon(Icons.more_vert, color: AppColors.textTertiary),
          ),

          /// IMAGE
          SizedBox(
            height: 250,
            width: double.infinity,
            child: OptimizedNetworkImage(
               imageUrl: post.mediaUrl,
               fit: BoxFit.cover,
            ),
          ),

          /// ACTIONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                _ActionButton(icon: Icons.favorite_border, label: "${post.likeCount}", isLikeButton: true),
                const SizedBox(width: 16),
                _ActionButton(icon: Icons.chat_bubble_outline, label: "${post.commentCount}"),
                const Spacer(),
                const _SaveButton(),
              ],
            ),
          ),

          /// CAPTION
          if (post.caption != null && post.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: AppColors.textSecondary),
                  children: [
                    TextSpan(
                      text: "${post.user?.username ?? 'User'} ",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    TextSpan(
                      text: post.caption,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime? date) {
    if (date == null) return 'Recently';
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
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
