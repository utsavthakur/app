import 'package:flutter/material.dart';
import 'package:aura_app/widgets/glass_container.dart';
import 'package:aura_app/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                                  image: const DecorationImage(
                                    image: NetworkImage("https://picsum.photos/200"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: const [
                                    _StatItem("Posts", "24"),
                                    _StatItem("Followers", "1.2M"),
                                    _StatItem("Following", "102"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Utsav The Creator",
                              style: TextStyle(
                                  color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Digital Artist | Flutter Enthusiast \nCreating aura in every pixel ✨",
                            style: TextStyle(color: AppColors.textSecondary),
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
                        const GlassContainer(
                          height: 45,
                          width: 45,
                          borderRadius: 12,
                          child: Icon(Icons.share, color: AppColors.textPrimary),
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

class _ProfileGrid extends StatelessWidget {
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
      itemBuilder: (context, index) => Image.network(
        "https://picsum.photos/200?random=${index + 100}",
        fit: BoxFit.cover,
      ),
    );
  }
}
