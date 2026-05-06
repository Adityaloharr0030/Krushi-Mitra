import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/weather_provider.dart';
import '../../../core/providers/market_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/ai_service.dart';
import '../../ai_doctor/screens/ai_doctor_screen.dart';
import '../../../core/providers/smart_context_provider.dart';
import '../../chatbot/screens/chatbot_screen.dart';
import '../../weather/screens/weather_screen.dart';
import '../../market_prices/screens/mandi_prices_screen.dart';
import '../../govt_schemes/screens/schemes_list_screen.dart';
import '../../soil_advisor/screens/soil_input_screen.dart';
import '../../crop_calendar/screens/crop_calendar_screen.dart';
import '../../farm_diary/screens/farm_diary_screen.dart';
import '../../marketplace/screens/marketplace_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  Future<void> _handleRefresh() async {
    ref.invalidate(currentUserProvider);
    ref.invalidate(weatherProvider);
    ref.invalidate(mandiProvider);
    ref.invalidate(smartContextProvider);
    ref.invalidate(ubiquitousContextProvider);
    ref.invalidate(farmerDiaryProvider);
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primaryEmerald,
        backgroundColor: AppColors.surfaceWhite,
        child: const _HomeContent(),
      ),
      floatingActionButton: _buildAIFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildAIFAB(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChatbotScreen()),
      ),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: AppTheme.celestialGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryEmerald.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✨', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Text(
              'Ask AI',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildTopNavigation(ref)),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(child: _QuickStatsRow()),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(child: _SmartInsightCard()),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Your Farm Services',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(child: _FeatureGrid()),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  Widget _buildTopNavigation(WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final weatherAsync = ref.watch(weatherProvider);

    return userAsync.when(
      loading: () => const SizedBox(height: 150),
      error: (_, __) => const SizedBox(height: 150),
      data: (profile) {
        final userName = profile?.name.split(' ').first ?? 'Farmer';
        final location = weatherAsync.maybeWhen(
          data: (w) => w.cityName,
          orElse: () => profile != null
              ? '${profile.district}, ${profile.state}'
              : 'Location...',
        );

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 32),
          decoration: BoxDecoration(
            gradient: AppTheme.celestialGradient,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryEmerald.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NAMASTE,',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.7),
                          letterSpacing: 3.0,
                        ),
                      ),
                      Text(
                        userName.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: profile?.photoUrl != null && profile!.photoUrl!.isNotEmpty
                          ? Image.network(
                              profile!.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Text('👨‍🌾', style: TextStyle(fontSize: 28)),
                              ),
                            )
                          : const Center(
                              child: Text('👨‍🌾', style: TextStyle(fontSize: 28)),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        location,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      'Live Updates',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickStatsRow extends ConsumerWidget {
  const _QuickStatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);
    final mandiAsync = ref.watch(mandiProvider);
    final profileAsync = ref.watch(currentUserProvider);

    return Row(
      children: [
        Expanded(
          child: profileAsync.when(
            data: (p) => _StatCard(
                emoji: '🌱',
                value: '${p?.landSize.toStringAsFixed(1) ?? '—'} ac',
                label: 'Farm Size',
                isGood: true),
            loading: () =>
                const _StatCard(emoji: '🌱', value: '...', label: 'Farm Size'),
            error: (_, __) =>
                const _StatCard(emoji: '🌱', value: '—', label: 'Farm Size'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: weatherAsync.when(
            data: (w) => _StatCard(
                emoji: '🌧️',
                value:
                    w.rainChance > 20 ? '${w.rainChance.round()}%' : 'No Rain',
                label: 'Next Rain',
                isGood: w.rainChance < 30),
            loading: () =>
                const _StatCard(emoji: '🌧️', value: '...', label: 'Next Rain'),
            error: (_, __) =>
                const _StatCard(emoji: '🌧️', value: '---', label: 'Next Rain'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: mandiAsync.when(
            data: (prices) {
              if (prices.isEmpty) {
                return const _StatCard(
                    emoji: '📈', value: 'N/A', label: 'Market');
              }
              final profile = profileAsync.value;
              final primaryCrop =
                  (profile != null && profile.cropsGrown.isNotEmpty)
                      ? profile.cropsGrown.first
                      : 'Wheat';

              final targetPrice = prices.firstWhere(
                (p) => p.commodity.toLowerCase() == primaryCrop.toLowerCase(),
                orElse: () => prices.first,
              );
              return _StatCard(
                emoji: '📈',
                value: '₹${targetPrice.modalPrice.round()}',
                label: '${targetPrice.commodity}/qtl',
                isGood: true,
              );
            },
            loading: () =>
                const _StatCard(emoji: '📈', value: '...', label: 'Market'),
            error: (_, __) =>
                const _StatCard(emoji: '📈', value: '---', label: 'Market'),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceObsidian,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isGood == true
                      ? AppColors.success
                      : AppColors.primaryEmerald)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color:
                  isGood == true ? AppColors.success : AppColors.primaryEmerald,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  static const _features = [
    {
      'emoji': '🤖',
      'title': 'AI Doctor',
      'subtitle': 'Diagnose crop',
      'gradient': 'green'
    },
    {
      'emoji': '🏪',
      'title': 'Marketplace',
      'subtitle': 'Sell Produce',
      'gradient': 'purple'
    },
    {
      'emoji': '🧪',
      'title': 'Soil Advisor',
      'subtitle': 'Fertilizer tip',
      'gradient': 'teal'
    },
    {
      'emoji': '🌤️',
      'title': 'Weather',
      'subtitle': 'Live forecast',
      'gradient': 'blue'
    },
    {
      'emoji': '💰',
      'title': 'Market',
      'subtitle': 'Mandi rates',
      'gradient': 'amber'
    },
    {
      'emoji': '🏛️',
      'title': 'Govt Schemes',
      'subtitle': 'Subsidies',
      'gradient': 'red'
    },
    {
      'emoji': '🗓️',
      'title': 'Calendar',
      'subtitle': 'Planning',
      'gradient': 'teal'
    },
    {
      'emoji': '📔',
      'title': 'Farm Diary',
      'subtitle': 'Record spends',
      'gradient': 'green'
    },
  ];

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

  LinearGradient _getGradient(String type) {
    switch (type) {
      case 'green':
        return AppTheme.celestialGradient;
      case 'blue':
        return const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)]);
      case 'amber':
        return const LinearGradient(
            colors: [Color(0xFFD97706), Color(0xFFF59E0B)]);
      case 'purple':
        return AppTheme.luxuryGradient;
      case 'teal':
        return const LinearGradient(
            colors: [Color(0xFF14B8A6), Color(0xFF5EEAD4)]);
      case 'red':
        return const LinearGradient(
            colors: [Color(0xFFEF4444), Color(0xFFF87171)]);
      default:
        return AppTheme.celestialGradient;
    }
  }

  void _handleTap(BuildContext context, int i) {
    Widget? screen;
    switch (i) {
      case 0:
        screen = const AIDoctorScreen();
        break;
      case 1:
        screen = const MarketplaceScreen();
        break;
      case 2:
        screen = const SoilInputScreen();
        break;
      case 3:
        screen = const WeatherScreen();
        break;
      case 4:
        screen = MandiPricesScreen();
        break;
      case 5:
        screen = const SchemesListScreen();
        break;
      case 6:
        screen = const CropCalendarScreen();
        break;
      case 7:
        screen = FarmDiaryScreen();
        break;
    }
    if (screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
    }
  }
}

class _FeatureCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmartInsightCard extends ConsumerStatefulWidget {
  const _SmartInsightCard();

  @override
  ConsumerState<_SmartInsightCard> createState() => _SmartInsightCardState();
}

class _SmartInsightCardState extends ConsumerState<_SmartInsightCard> {
  Future<String>? _adviceFuture;

  @override
  void initState() {
    super.initState();
    // Delay AI call slightly to let other providers load first
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          final contextData = ref.read(ubiquitousContextProvider);
          _adviceFuture = AIService().getPersonalizedAdvice(contextData);
        });
      }
    });
  }

  void refreshAdvice() {
    setState(() {
      final contextData = ref.read(ubiquitousContextProvider);
      _adviceFuture = AIService().getPersonalizedAdvice(contextData);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_adviceFuture == null) return _buildLoadingCard();

    return FutureBuilder<String>(
      future: _adviceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: refreshAdvice,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceObsidian,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                  color: AppColors.primaryEmerald.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryEmerald.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('🧠', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'AI SMART ADVICE',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryEmerald,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.refresh_rounded,
                              size: 14, color: AppColors.textSecondary),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        snapshot.data!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.surfaceObsidian,
        borderRadius: BorderRadius.circular(28),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primaryEmerald)),
            const SizedBox(width: 12),
            Text('Getting smart insights...',
                style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
