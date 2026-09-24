import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/theme_tokens.dart';
import 'floating_bottom_nav_bar.dart';

/// ScaffoldWithNavBar wraps top-level tab destinations with the persistent floating bottom nav bar.
class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      body: navigationShell,
      bottomNavigationBar: FloatingBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
