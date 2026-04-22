import 'package:flutter/material.dart';

import '../models/word_mode.dart';
import '../navigation/app_routes.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/user_info_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modes = WordMode.values;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFDF3FF), Color(0xFFF3E2FF), Color(0xFFE6E1FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AdBanner(location: 'top'),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: _HomeHeader(
                  onOpenSettings: () => _showComingSoon(context, 'Settings'),
                  onOpenMenu: () => _showComingSoon(context, 'Menu'),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: UserInfoBar(),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: AppSectionHeader(
                  title: 'Game Modes',
                  actionLabel: 'View Stats',
                  onAction: () => pushMode(context, WordMode.dailyChallenge),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: modes.length,
                    itemBuilder: (context, index) {
                      final mode = modes[index];
                      final featured = index == 0;
                      return _ModeTile(
                        mode: mode,
                        featured: featured,
                        onTap: () => pushMode(context, mode),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AdBanner(location: 'bottom'),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onOpenMenu, required this.onOpenSettings});

  final VoidCallback onOpenMenu;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconButton(icon: Icons.menu_rounded, onPressed: onOpenMenu),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Word Quizz',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [Color(0xFF6A37D4), Color(0xFFB00D6A)],
                ).createShader(const Rect.fromLTWH(0, 0, 220, 40)),
            ),
          ),
        ),
        _IconButton(icon: Icons.settings_rounded, onPressed: onOpenSettings),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: const Color(0xFF6A37D4)),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.mode,
    required this.featured,
    required this.onTap,
  });

  final WordMode mode;
  final bool featured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (featured) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: mode.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'New Today',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(mode.icon, color: mode.accent, size: 18),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                mode.title,
                style: Theme.of(context).textTheme.headlineMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                mode.subtitle,
                style: const TextStyle(color: Color(0xFF67537C)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: 0.65,
                          backgroundColor: const Color(0xFFF3E2FF),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            mode.accent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: mode.accent,
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onTap,
                    child: const Text('Play Now'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: mode.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(mode.icon, color: mode.accent),
            ),
            Text(
              mode.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Text(
              mode.subtitle,
              style: const TextStyle(color: Color(0xFF67537C), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

void _showComingSoon(BuildContext context, String title) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('$title is coming soon')));
}
