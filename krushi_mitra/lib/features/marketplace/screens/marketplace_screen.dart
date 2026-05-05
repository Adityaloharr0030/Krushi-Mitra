import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/marketplace_provider.dart';
import '../models/listing_model.dart';
import 'create_listing_screen.dart';

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(marketplaceStreamProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Farmer Marketplace',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 18)),
            Text('Version 2.0 - UPDATED TODAY',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: AppColors.primaryEmerald, fontSize: 10)),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppTheme.celestialGradient)),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryEmerald,
        onRefresh: () async => ref.invalidate(marketplaceStreamProvider),
        child: listingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryEmerald)),
          error: (e, _) => _buildErrorState(ref),
          data: (listings) => listings.isEmpty ? _buildEmptyState(context) : _buildListView(context, ref, listings, currentUserId),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'marketplace_fab',
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateListingScreen())),
        label: Text('Sell Produce', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white)),
        icon: const Icon(Icons.add_business_rounded, color: Colors.white),
        backgroundColor: AppColors.primaryEmerald,
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text('Could not load listings', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(marketplaceStreamProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryEmerald, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryEmerald.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Text('🏪', style: TextStyle(fontSize: 56))),
              ),
              const SizedBox(height: 24),
              Text('No Listings Yet', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  'Be the first to list your produce!\nSell directly to buyers at premium rates.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListView(BuildContext context, WidgetRef ref, List<MarketplaceListing> listings, String? currentUserId) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMarketHero(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text('${listings.length} Listings', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text('LIVE', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.success, letterSpacing: 1)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildListingCard(context, ref, listings[index], currentUserId),
              childCount: listings.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildMarketHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primaryEmerald.withValues(alpha: 0.08), AppColors.neonCyan.withValues(alpha: 0.05)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryEmerald.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Text('✨', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI MARKET INSIGHT', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryEmerald, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text('Organic produce demand is up 15%. List now for premium rates!',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingCard(BuildContext context, WidgetRef ref, MarketplaceListing listing, String? currentUserId) {
    final isOwner = listing.sellerId == currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with emoji + commodity
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryEmerald.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(child: Text(listing.cropEmoji, style: const TextStyle(fontSize: 28))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(listing.commodity, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text('${listing.farmerName} • ${listing.location}',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.primaryEmerald.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text('Grade ${listing.quality}', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primaryEmerald)),
                    ),
                    const SizedBox(height: 4),
                    Text(listing.timeAgo, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          // Description if available
          if (listing.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(listing.description,
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
            ),
          // Price row
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${listing.quantity} ${listing.unit} available',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    Text('₹${listing.pricePerUnit.toStringAsFixed(0)}/${listing.unit}',
                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryEmerald)),
                  ],
                ),
                const Spacer(),
                if (isOwner) ...[
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateListingScreen(existingListing: listing))),
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: Text('Edit', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryEmerald,
                          side: BorderSide(color: AppColors.primaryEmerald.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _confirmDelete(context, ref, listing.id),
                        icon: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: () => _showContactDialog(context, listing),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryEmerald,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    ),
                    icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 18),
                    label: Text('Buy / Contact', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String listingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Remove Listing?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        content: Text('This listing will be permanently deleted.', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(marketplaceActionsProvider).deleteListing(listingId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Listing removed', style: GoogleFonts.plusJakartaSans()), backgroundColor: AppColors.primaryEmerald),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context, MarketplaceListing listing) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outline, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text(listing.cropEmoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(listing.farmerName, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            Text('${listing.commodity} • ${listing.location}', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            if (listing.phoneNumber != null && listing.phoneNumber!.isNotEmpty) ...[
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => launchUrl(Uri.parse('tel:${listing.phoneNumber}')),
                          icon: const Icon(Icons.call_rounded),
                          label: Text('Call', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryEmerald, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final phone = listing.phoneNumber!.replaceAll(RegExp(r'[^0-9]'), '');
                            launchUrl(Uri.parse('sms:$phone?body=Hi, I am interested in your ${listing.commodity} listing on Krushi Mitra.'));
                          },
                          icon: const Icon(Icons.message_rounded),
                          label: Text('Message', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonCyan, foregroundColor: AppColors.surface, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final phone = listing.phoneNumber!.replaceAll(RegExp(r'[^0-9]'), '');
                        launchUrl(Uri.parse('https://wa.me/91$phone?text=Hi,%20I%20am%20interested%20in%20your%20${listing.commodity}%20listing%20on%20Krushi%20Mitra.'));
                      },
                      icon: const Icon(Icons.chat_rounded),
                      label: Text('WhatsApp', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Seller has not shared their phone number.', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
