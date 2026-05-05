import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/listing_model.dart';

class ListingDetailScreen extends StatelessWidget {
  final MarketplaceListing listing;
  final bool isOwner;

  const ListingDetailScreen({
    super.key,
    required this.listing,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceHeader(),
                  const SizedBox(height: 20),
                  _buildBadgesRow(),
                  const SizedBox(height: 24),
                  _buildSellerCard(context),
                  const SizedBox(height: 20),
                  _buildDetailsGrid(),
                  if (listing.description.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildDescriptionCard(),
                  ],
                  const SizedBox(height: 24),
                  if (!isOwner) _buildContactActions(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _shareListing(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryEmerald.withValues(alpha: 0.15),
                AppColors.neonCyan.withValues(alpha: 0.08),
                AppColors.background,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primaryEmerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.primaryEmerald.withValues(alpha: 0.25), width: 2),
                  ),
                  child: Center(child: Text(listing.cropEmoji, style: const TextStyle(fontSize: 48))),
                ),
                const SizedBox(height: 16),
                Text(
                  listing.commodity,
                  style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  listing.freshnessLabel,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryEmerald.withValues(alpha: 0.1), AppColors.neonCyan.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryEmerald.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PRICE PER ${listing.unit.toUpperCase()}',
                    style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primaryEmerald, letterSpacing: 1.5)),
                const SizedBox(height: 6),
                Text('₹${listing.pricePerUnit.toStringAsFixed(0)}',
                    style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.primaryEmerald)),
                if (listing.isNegotiable)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.accentAmber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                    child: Text('Negotiable', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.accentAmber)),
                  ),
              ],
            ),
          ),
          Container(width: 1, height: 60, color: AppColors.outline.withValues(alpha: 0.3)),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TOTAL VALUE',
                    style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1.5)),
                const SizedBox(height: 6),
                Text('₹${listing.totalValue.toStringAsFixed(0)}',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('${listing.quantity} ${listing.unit}',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildBadge('Grade ${listing.quality}', Icons.verified_rounded, AppColors.primaryEmerald),
        if (listing.isOrganic)
          _buildBadge('Organic', Icons.eco_rounded, const Color(0xFF22C55E)),
        if (listing.deliveryAvailable)
          _buildBadge('Delivery', Icons.local_shipping_rounded, AppColors.neonCyan),
        if (listing.isVerified)
          _buildBadge('Verified', Icons.shield_rounded, AppColors.accentAmber),
        if (listing.minimumOrder > 0)
          _buildBadge('Min ${listing.minimumOrder.toStringAsFixed(0)} ${listing.unit}', Icons.shopping_basket_rounded, AppColors.textSecondary),
      ],
    );
  }

  Widget _buildBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _buildSellerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primaryEmerald.withValues(alpha: 0.1),
            child: Text(listing.farmerName.isNotEmpty ? listing.farmerName[0].toUpperCase() : 'F',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryEmerald)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(listing.farmerName,
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    if (listing.isVerified) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.verified_rounded, size: 16, color: AppColors.primaryEmerald),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(listing.location,
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(listing.timeAgo, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LISTING DETAILS', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDetailTile('Quantity', '${listing.quantity} ${listing.unit}', Icons.scale_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _buildDetailTile('Quality', 'Grade ${listing.quality}', Icons.diamond_rounded)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDetailTile('Type', listing.isOrganic ? 'Organic' : 'Conventional', Icons.eco_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _buildDetailTile('Delivery', listing.deliveryAvailable ? 'Available' : 'Pickup Only', Icons.local_shipping_rounded)),
            ],
          ),
          if (listing.minimumOrder > 0) ...[
            const SizedBox(height: 12),
            _buildDetailTile('Minimum Order', '${listing.minimumOrder.toStringAsFixed(0)} ${listing.unit}', Icons.shopping_cart_rounded),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryEmerald),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📝', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text('DESCRIPTION', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            listing.description,
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary, height: 1.6, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildContactActions(BuildContext context) {
    final hasPhone = listing.phoneNumber != null && listing.phoneNumber!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CONTACT SELLER', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1.2)),
        const SizedBox(height: 16),

        if (hasPhone) ...[
          // Primary action — Call
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton.icon(
              onPressed: () => launchUrl(Uri.parse('tel:${listing.phoneNumber}')),
              icon: const Icon(Icons.call_rounded, size: 22),
              label: Text('Call Farmer', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryEmerald,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Secondary row — WhatsApp + SMS
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final phone = listing.phoneNumber!.replaceAll(RegExp(r'[^0-9]'), '');
                      final message = listing.isNegotiable
                          ? 'Hi, I saw your ${listing.commodity} listing (₹${listing.pricePerUnit.toStringAsFixed(0)}/${listing.unit}) on Krushi Mitra Pro. I\'m interested! Can we negotiate the price?'
                          : 'Hi, I saw your ${listing.commodity} listing (₹${listing.pricePerUnit.toStringAsFixed(0)}/${listing.unit}) on Krushi Mitra Pro. I want to buy ${listing.quantity} ${listing.unit}.';
                      launchUrl(Uri.parse('https://wa.me/91$phone?text=${Uri.encodeComponent(message)}'));
                    },
                    icon: const Icon(Icons.chat_rounded, size: 18),
                    label: Text('WhatsApp', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final phone = listing.phoneNumber!.replaceAll(RegExp(r'[^0-9]'), '');
                      launchUrl(Uri.parse('sms:$phone?body=Hi, I want to buy your ${listing.commodity} from Krushi Mitra Pro.'));
                    },
                    icon: const Icon(Icons.message_rounded, size: 18),
                    label: Text('SMS', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonCyan,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Utility row — Copy number + Share
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: listing.phoneNumber!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Phone number copied!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                          backgroundColor: AppColors.primaryEmerald,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: Text('Copy Number', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => _shareListing(),
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: Text('Share Listing', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Seller has not shared their contact number.',
                      style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _shareListing() {
    final text = '''🌾 *${listing.commodity}* — ₹${listing.pricePerUnit.toStringAsFixed(0)}/${listing.unit}
📦 Qty: ${listing.quantity} ${listing.unit}
📍 ${listing.location}
👨‍🌾 ${listing.farmerName}
${listing.isOrganic ? '🌿 Organic Certified' : ''}${listing.deliveryAvailable ? '🚚 Delivery Available' : ''}
${listing.isNegotiable ? '💬 Price Negotiable' : ''}

Found on *Krushi Mitra Pro* 🚀''';

    Share.share(text);
  }
}
