// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:aura_app/widgets/glass_container.dart';
import 'package:aura_app/theme/app_colors.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: GlassContainer(
            height: 50,
            borderRadius: 15,
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.search, color: AppColors.textTertiary),
                const SizedBox(width: 12),
                Text(
                  "Search creative works...",
                  style: const TextStyle(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.75,
            ),
            itemCount: 20,
            itemBuilder: (context, index) {
              return GlassContainer(
                enableBlur: false,
                borderRadius: 16,
                padding: EdgeInsets.zero,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      "https://picsum.photos/300/400?random=$index",
                      fit: BoxFit.cover,
                      color: AppColors.midnightInk.withOpacity(0.3),
                      colorBlendMode: BlendMode.darken,
                    ),
                    const Positioned(
                      bottom: 10,
                      left: 10,
                      child: Text(
                        "Ethereal",
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
