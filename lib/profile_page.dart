import 'package:flutter/material.dart';
import 'package:aura_app/widgets/glass_container.dart';
import 'package:aura_app/theme/app_colors.dart';
import 'package:aura_app/core/performance/optimized_image_manager.dart';
import 'package:aura_app/core/error/error_handler.dart';
import 'package:aura_app/services/api_service.dart';
import 'package:aura_app/models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<User?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = ApiService().getUserProfile();
    // Preload critical images for smooth experience
    // _preloadProfileImages(); // Defer until we have URL
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.sunsetCoral));
        }
        
        // Fallback or Error handling
        final user = snapshot.data;
        if (user == null) {
           return const Center(child: Text("Failed to load profile", style: TextStyle(color: Colors.white)));
        }

        return DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        GlassContainer(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.sunsetCoral, width: 2.5),
                                    ),
                                    child: ClipOval(
                                      child: user.profilePicture != null 
                                        ? OptimizedNetworkImage(
                                            imageUrl: user.profilePicture!,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(Icons.person, size: 40, color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: const [
                                        _StatItem("Posts", "0"), // dynamic later
                                        _StatItem("Followers", "0"), // dynamic later
                                        _StatItem("Following", "0"), // dynamic later
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  user.username,
                                  style: const TextStyle(
                                      color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user.bio ?? "No bio yet.",
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: GlassContainer(
                                 height: 45,
                                 borderRadius: 12,
                                 color: AppColors.sunsetCoral,
                                 opacity: 0.2,
                                 child: const Center(
                                   child: Text("Edit Profile", style: TextStyle(color: AppColors.sunsetCoral, fontWeight: FontWeight.bold)),
                                 ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                                onTap: () async {
                                  await ApiService().logout();
                                  // Trigger rebuild or navigation in main
                                  // For now, simpler to just pop or restart, but since main watches auth...
                                  // Actually main does NOT watch auth stream, so we need to restart app or nav to login
                                  // A simple way:
                                  if (mounted) {
                                     // This is a bit hacky without a real auth provider, but works for now:
                                     // Navigator.of(context, rootNavigator: true).pushReplacementNamed('/'); 
                                     // Better approach since we are deep in nested nav:
                                     // We can rely on the fact that if we restart the app, it checks auth.
                                     // But to give immediate feedback:
                                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out. Please restart app to login again.')));
                                  }
                                },
                                child: const GlassContainer(
                                width: 45,
                                height: 45,
                                borderRadius: 12,
                                child: Icon(Icons.logout, color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: Column(
              children: [
                const TabBar(
                  indicatorColor: AppColors.sunsetCoral,
                  labelColor: AppColors.sunsetCoral,
                  unselectedLabelColor: AppColors.textTertiary,
                  tabs: [
                    Tab(icon: Icon(Icons.grid_on)),
                    Tab(icon: Icon(Icons.bookmark_border)),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _ProfileGrid(),
                      const Center(child: Text("No saved items", style: TextStyle(color: AppColors.textTertiary))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
      ],
    );
  }
}

class _ProfileGrid extends StatefulWidget {
  @override
  State<_ProfileGrid> createState() => _ProfileGridState();
}

class _ProfileGridState extends State<_ProfileGrid> {
  @override
  void initState() {
    super.initState();
    _preloadGridImages();
  }

  Future<void> _preloadGridImages() async {
    final imageUrls = List.generate(15, (index) => "https://picsum.photos/200?random=${index + 100}");
    await ErrorHandler.instance.guardAsync(
      'GridImagePreload',
      () => OptimizedImageManager.instance.preloadImages(imageUrls),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 2, bottom: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 15,
      itemBuilder: (context, index) => OptimizedNetworkImage(
        imageUrl: "https://picsum.photos/200?random=${index + 100}",
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
