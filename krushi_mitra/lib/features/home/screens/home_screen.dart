import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/weather_provider.dart';
import '../../../core/providers/market_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../ai_doctor/screens/ai_doctor_screen.dart';
import '../../chatbot/screens/chatbot_screen.dart';
import '../../weather/screens/weather_screen.dart';
import '../../market_prices/screens/market_prices_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _alertController;
  bool _alertDismissed = false;

  final List<Widget> _screens = const [
    _HomeContent(),
    AIDoctorScreen(),
    WeatherScreen(),
    MarketPricesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _alertController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _alertController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      floatingActionButton: _selectedIndex == 0
          ? _buildAIFAB(context)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAIFAB(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChatbotScreen()),
      ),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: AppTheme.goldGradient,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: AppColors.tertiary.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🤖', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              'Ask AI',
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.onTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    const navItems = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.medical_services_rounded, 'label': 'Doctor'},
      {'icon': Icons.wb_sunny_rounded, 'label': 'Weather'},
      {'icon': Icons.trending_up_rounded, 'label': 'Market'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.3)),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              navItems.length,
              (i) => _NavItem(
                icon: navItems[i]['icon'] as IconData,
                label: navItems[i]['label'] as String,
                isSelected: _selectedIndex == i,
                onTap: () => setState(() => _selectedIndex = i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Nav Item ────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.harvestGold : AppColors.onSurfaceVariant;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.harvestGold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Home Content ─────────────────────────────────────────────────
class _HomeContent extends ConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildTopNavigation(ref)),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(child: _AlertBanner()),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(child: _QuickStatsRow()),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Quick Actions',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(child: _FeatureGrid()),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildTopNavigation(WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userName = user?.displayName ?? (user?.isAnonymous == true ? 'Guest Farmer' : user?.email?.split('@')[0] ?? 'Farmer');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppTheme.headerGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: Text('🌿', style: TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Namaste, $userName!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Your farm at a glance',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Alert Banner ─────────────────────────────────────────────────
class _AlertBanner extends StatefulWidget {
  const _AlertBanner();

  @override
  State<_AlertBanner> createState() => _AlertBannerState();
}

class _AlertBannerState extends State<_AlertBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A3000), Color(0xFF5D3C00)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.harvestGold.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Text('🚨', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aphid Alert Detected',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: AppColors.harvestGold,
                  ),
                ),
                Text(
                  'Nearby farms affected • Monitor your cotton crop',
                  style: GoogleFonts.manrope(
                    fontSize: 12, color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _dismissed = true),
            child: Icon(Icons.close, color: Colors.white54, size: 18),
          ),
        ],
      ),
    );
  }
}

// ── Quick Stats Row ───────────────────────────────────────────────
class _QuickStatsRow extends ConsumerWidget {
  const _QuickStatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);
    final mandiAsync = ref.watch(mandiProvider);
    
    return Row(
      children: [
        const Expanded(child: _StatCard(emoji: '🌱', value: '87%', label: 'Crop Health', isGood: true)),
        const SizedBox(width: 10),
        Expanded(
          child: weatherAsync.when(
            data: (w) => _StatCard(
              emoji: '🌧️', 
              value: w.rainChance > 20 ? '${w.rainChance.round()}%' : 'No Rain', 
              label: 'Next Rain', 
              isGood: w.rainChance < 30
            ),
            loading: () => const _StatCard(emoji: '🌧️', value: '...', label: 'Next Rain'),
            error: (_, __) => const _StatCard(emoji: '🌧️', value: '---', label: 'Next Rain'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: mandiAsync.when(
            data: (prices) {
              final wheat = prices.firstWhere((p) => p.commodity == 'Wheat', orElse: () => prices.first);
              return _StatCard(emoji: '📈', value: '₹${wheat.modalPrice.round()}', label: '${wheat.commodity}/qtl', isGood: true);
            },
            loading: () => const _StatCard(emoji: '📈', value: '...', label: 'Market'),
            error: (_, __) => const _StatCard(emoji: '📈', value: '---', label: 'Market'),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final bool? isGood;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    this.isGood,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHighest.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outlineVariant.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: isGood == true
                      ? AppColors.primary
                      : isGood == false
                          ? AppColors.error
                          : AppColors.onSurface,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 11, color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Feature Grid ─────────────────────────────────────────────────
class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  static const _features = [
    {
      'emoji': '🤖',
      'title': 'AI Doctor',
      'subtitle': 'Diagnose crop disease',
      'gradient': 'green',
    },
    {
      'emoji': '🌤️',
      'title': 'Weather',
      'subtitle': '5-day forecast',
      'gradient': 'blue',
    },
    {
      'emoji': '💰',
      'title': 'Market',
      'subtitle': 'Live mandi rates',
      'gradient': 'amber',
    },
    {
      'emoji': '🗓️',
      'title': 'Calendar',
      'subtitle': 'Season planning',
      'gradient': 'purple',
    },
    {
      'emoji': '📔',
      'title': 'Farm Diary',
      'subtitle': 'Record keeping',
      'gradient': 'teal',
    },
    {
      'emoji': '🏛️',
      'title': 'Schemes',
      'subtitle': 'PM-KISAN & more',
      'gradient': 'red',
    },
  ];

  LinearGradient _getGradient(String type) {
    switch (type) {
      case 'green': return AppTheme.cardGradientGreen;
      case 'blue': return AppTheme.cardGradientBlue;
      case 'amber': return AppTheme.cardGradientAmber;
      case 'purple': return AppTheme.cardGradientPurple;
      case 'teal': return AppTheme.cardGradientTeal;
      case 'red': return AppTheme.cardGradientRed;
      default: return AppTheme.cardGradientGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _features.length,
      itemBuilder: (context, i) {
        final f = _features[i];
        return _FeatureCard(
          emoji: f['emoji']!,
          title: f['title']!,
          subtitle: f['subtitle']!,
          gradient: _getGradient(f['gradient']!),
          onTap: () => _handleTap(context, i),
        );
      },
    );
  }

  void _handleTap(BuildContext context, int i) {
    Widget? screen;
    switch (i) {
      case 0: screen = const AIDoctorScreen(); break;
      case 1: screen = const WeatherScreen(); break;
      case 2: screen = const MarketPricesScreen(); break;
      default: screen = null;
    }
    if (screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_features[i]['title']} - Coming soon!'),
          backgroundColor: AppColors.surfaceContainerHigh,
        ),
      );
    }
  }
}

class _FeatureCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) {
        _controller.forward();
        widget.onTap();
      },
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.first.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Decoration
              Positioned(
                right: -10,
                bottom: -10,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              // AI Verified Badge
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '✓ AI',
                    style: GoogleFonts.manrope(
                      fontSize: 9, fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(widget.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 8),
                    Text(
                      widget.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.manrope(
                        fontSize: 11, color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
