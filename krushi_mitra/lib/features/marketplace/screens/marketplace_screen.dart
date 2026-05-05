import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/marketplace_provider.dart';
import '../models/listing_model.dart';
import 'create_listing_screen.dart';
import 'listing_detail_screen.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});
  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  String _search = '';
  String _selectedCrop = 'All';
  static const _cropFilters = ['All','Wheat','Rice','Onion','Tomato','Potato','Cotton','Soybean','Mango','Banana'];

  List<MarketplaceListing> _filter(List<MarketplaceListing> all) {
    var list = all.where((l) => !l.isSold).toList();
    if (_selectedCrop != 'All') list = list.where((l) => l.commodity.toLowerCase() == _selectedCrop.toLowerCase()).toList();
    if (_search.isNotEmpty) list = list.where((l) => l.commodity.toLowerCase().contains(_search.toLowerCase()) || l.farmerName.toLowerCase().contains(_search.toLowerCase()) || l.location.toLowerCase().contains(_search.toLowerCase())).toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(marketplaceStreamProvider);
    final uid = ref.watch(currentUserIdProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primaryEmerald,
        onRefresh: () async => ref.invalidate(marketplaceStreamProvider),
        child: listingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryEmerald)),
          error: (e, _) => _errState(),
          data: (all) => _body(all, uid),
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

  Widget _errState() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.textSecondary),
    const SizedBox(height: 16),
    Text('Could not load listings', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
    const SizedBox(height: 16),
    ElevatedButton.icon(onPressed: () => ref.invalidate(marketplaceStreamProvider), icon: const Icon(Icons.refresh_rounded), label: const Text('Retry'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryEmerald, foregroundColor: Colors.white)),
  ]));

  Widget _body(List<MarketplaceListing> all, String? uid) {
    final filtered = _filter(all);
    final totalVal = all.fold(0.0, (s, l) => s + l.totalValue);
    final organicCount = all.where((l) => l.isOrganic).length;
    return CustomScrollView(slivers: [
      // App bar
      SliverAppBar(
        expandedHeight: 110, pinned: true, floating: false,
        backgroundColor: AppColors.background,
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            decoration: BoxDecoration(gradient: AppTheme.celestialGradient),
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
            child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Farmer Marketplace', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 20)),
              Text('Buy & Sell Farm Produce Directly', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: AppColors.primaryEmerald, fontSize: 11)),
            ]),
          ),
        ),
      ),
      // Search + stats
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Search bar
        Container(
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.outline.withValues(alpha: 0.3))),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search crops, farmers, location...',
              hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 14),
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
              border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Stats row
        Row(children: [
          _statChip('${all.length}', 'Listings', Icons.storefront_rounded, AppColors.primaryEmerald),
          const SizedBox(width: 10),
          _statChip('₹${(totalVal / 1000).toStringAsFixed(0)}K', 'Value', Icons.currency_rupee_rounded, AppColors.accentAmber),
          const SizedBox(width: 10),
          _statChip('$organicCount', 'Organic', Icons.eco_rounded, const Color(0xFF22C55E)),
        ]),
        const SizedBox(height: 16),
        // Crop filter chips
        SizedBox(height: 38, child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _cropFilters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final c = _cropFilters[i];
            final sel = c == _selectedCrop;
            return GestureDetector(
              onTap: () => setState(() => _selectedCrop = c),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primaryEmerald : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? AppColors.primaryEmerald : AppColors.outline.withValues(alpha: 0.3)),
                ),
                alignment: Alignment.center,
                child: Text(c, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: sel ? Colors.white : AppColors.textSecondary)),
              ),
            );
          },
        )),
        const SizedBox(height: 16),
        // Results header
        Row(children: [
          Text('${filtered.length} Results', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text('LIVE', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.success, letterSpacing: 1))),
        ]),
        const SizedBox(height: 8),
      ]))),
      // Listings
      if (filtered.isEmpty)
        SliverToBoxAdapter(child: _emptyState())
      else
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(delegate: SliverChildBuilderDelegate(
            (ctx, i) => _card(filtered[i], uid),
            childCount: filtered.length,
          )),
        ),
      const SliverToBoxAdapter(child: SizedBox(height: 100)),
    ]);
  }

  Widget _statChip(String val, String label, IconData icon, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.15))),
      child: Column(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(val, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
      ]),
    ));
  }

  Widget _emptyState() => Padding(padding: const EdgeInsets.all(40), child: Center(child: Column(children: [
    const SizedBox(height: 40),
    Container(width: 100, height: 100, decoration: BoxDecoration(color: AppColors.primaryEmerald.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: const Center(child: Text('🏪', style: TextStyle(fontSize: 48)))),
    const SizedBox(height: 20),
    Text('No Listings Found', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
    const SizedBox(height: 8),
    Text(_search.isNotEmpty || _selectedCrop != 'All' ? 'Try a different search or filter' : 'Be the first to list your produce!',
      textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary)),
  ])));

  Widget _card(MarketplaceListing listing, String? uid) {
    final isOwner = listing.sellerId == uid;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listing, isOwner: isOwner))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 12), child: Row(children: [
            Container(width: 52, height: 52,
              decoration: BoxDecoration(color: AppColors.primaryEmerald.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text(listing.cropEmoji, style: const TextStyle(fontSize: 28)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(listing.commodity, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text('${listing.farmerName} • ${listing.location}',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.primaryEmerald.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text('Grade ${listing.quality}', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primaryEmerald))),
              const SizedBox(height: 4),
              Text(listing.timeAgo, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textSecondary)),
            ]),
          ])),
          // Badges
          if (listing.isOrganic || listing.deliveryAvailable || listing.isNegotiable)
            Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 10), child: Wrap(spacing: 6, children: [
              if (listing.isOrganic) _miniBadge('🌿 Organic', const Color(0xFF22C55E)),
              if (listing.deliveryAvailable) _miniBadge('🚚 Delivery', AppColors.neonCyan),
              if (listing.isNegotiable) _miniBadge('💬 Negotiable', AppColors.accentAmber),
            ])),
          // Description
          if (listing.description.isNotEmpty)
            Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(listing.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary, height: 1.4))),
          // Footer
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: BoxDecoration(color: AppColors.surfaceVariant.withValues(alpha: 0.3), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24))),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${listing.quantity} ${listing.unit} available', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                Text('₹${listing.pricePerUnit.toStringAsFixed(0)}/${listing.unit}', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryEmerald)),
              ]),
              const Spacer(),
              if (isOwner) ...[
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateListingScreen(existingListing: listing))),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: Text('Edit', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryEmerald, side: BorderSide(color: AppColors.primaryEmerald.withValues(alpha: 0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: () => _confirmDelete(listing.id), icon: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22), tooltip: 'Delete'),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: () => _showContactSheet(listing),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryEmerald, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10)),
                  icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 18),
                  label: Text('Buy / Contact', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13)),
                ),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _miniBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }

  void _confirmDelete(String id) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text('Remove Listing?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      content: Text('This listing will be permanently deleted.', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
        ElevatedButton(onPressed: () { Navigator.pop(ctx); ref.read(marketplaceActionsProvider).deleteListing(id); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white), child: const Text('Delete')),
      ],
    ));
  }

  void _showContactSheet(MarketplaceListing listing) {
    final hasPhone = listing.phoneNumber != null && listing.phoneNumber!.isNotEmpty;
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (ctx) => Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outline, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        // Seller info
        Row(children: [
          CircleAvatar(radius: 24, backgroundColor: AppColors.primaryEmerald.withValues(alpha: 0.1),
            child: Text(listing.farmerName.isNotEmpty ? listing.farmerName[0] : 'F', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primaryEmerald))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(listing.farmerName, style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            Text('${listing.commodity} • ${listing.quantity} ${listing.unit}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primaryEmerald, AppColors.neonCyan]), borderRadius: BorderRadius.circular(10)),
            child: Text('₹${listing.pricePerUnit.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white))),
        ]),
        const SizedBox(height: 20),
        // Badges row
        if (listing.isOrganic || listing.deliveryAvailable || listing.isNegotiable)
          Padding(padding: const EdgeInsets.only(bottom: 16), child: Row(children: [
            if (listing.isOrganic) Expanded(child: _contactBadge('🌿 Organic', const Color(0xFF22C55E))),
            if (listing.deliveryAvailable) Expanded(child: _contactBadge('🚚 Delivery', AppColors.neonCyan)),
            if (listing.isNegotiable) Expanded(child: _contactBadge('💬 Negotiable', AppColors.accentAmber)),
          ])),
        if (hasPhone) ...[
          // Call
          SizedBox(width: double.infinity, height: 54, child: ElevatedButton.icon(
            onPressed: () => launchUrl(Uri.parse('tel:${listing.phoneNumber}')),
            icon: const Icon(Icons.call_rounded), label: Text('Call Farmer', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryEmerald, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
          )),
          const SizedBox(height: 10),
          // WhatsApp + SMS
          Row(children: [
            Expanded(child: SizedBox(height: 50, child: ElevatedButton.icon(
              onPressed: () {
                final p = listing.phoneNumber!.replaceAll(RegExp(r'[^0-9]'), '');
                final msg = listing.isNegotiable
                    ? 'Hi, I saw your ${listing.commodity} (₹${listing.pricePerUnit.toStringAsFixed(0)}/${listing.unit}) on Krushi Mitra Pro. Can we discuss the price?'
                    : 'Hi, I want to buy your ${listing.commodity} on Krushi Mitra Pro.';
                launchUrl(Uri.parse('https://wa.me/91$p?text=${Uri.encodeComponent(msg)}'));
              },
              icon: const Icon(Icons.chat_rounded, size: 18),
              label: Text('WhatsApp', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
            ))),
            const SizedBox(width: 10),
            Expanded(child: SizedBox(height: 50, child: ElevatedButton.icon(
              onPressed: () {
                final p = listing.phoneNumber!.replaceAll(RegExp(r'[^0-9]'), '');
                launchUrl(Uri.parse('sms:$p?body=Hi, I want to buy your ${listing.commodity} from Krushi Mitra Pro.'));
              },
              icon: const Icon(Icons.message_rounded, size: 18),
              label: Text('SMS', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonCyan, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
            ))),
          ]),
          const SizedBox(height: 10),
          // Copy + Share
          Row(children: [
            Expanded(child: SizedBox(height: 46, child: OutlinedButton.icon(
              onPressed: () { Clipboard.setData(ClipboardData(text: listing.phoneNumber!)); Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Number copied!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)), backgroundColor: AppColors.primaryEmerald, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
              },
              icon: const Icon(Icons.copy_rounded, size: 16), label: Text('Copy Number', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12)),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.textPrimary, side: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ))),
            const SizedBox(width: 10),
            Expanded(child: SizedBox(height: 46, child: OutlinedButton.icon(
              onPressed: () { Navigator.pop(ctx); _share(listing); },
              icon: const Icon(Icons.share_rounded, size: 16), label: Text('Share', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12)),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.textPrimary, side: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ))),
          ]),
        ] else ...[
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(16)),
            child: Row(children: [Icon(Icons.info_outline_rounded, color: AppColors.textSecondary), const SizedBox(width: 12),
              Expanded(child: Text('Seller has not shared their phone number.', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13)))])),
        ],
      ]),
    ));
  }

  Widget _contactBadge(String label, Color c) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 3), padding: const EdgeInsets.symmetric(vertical: 6),
    decoration: BoxDecoration(color: c.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
    child: Center(child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: c))),
  );

  void _share(MarketplaceListing l) {
    Share.share('🌾 ${l.commodity} — ₹${l.pricePerUnit.toStringAsFixed(0)}/${l.unit}\n📦 ${l.quantity} ${l.unit}\n📍 ${l.location}\n👨‍🌾 ${l.farmerName}\n\nFound on Krushi Mitra Pro 🚀');
  }
}
