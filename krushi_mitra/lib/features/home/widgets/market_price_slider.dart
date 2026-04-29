import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class MarketPriceSlider extends StatelessWidget {
  const MarketPriceSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final prices = [
      {'crop': 'Wheat (Kanak)', 'price': '₹2,275', 'trend': '+₹25', 'up': true},
      {'crop': 'Cotton (Kapas)', 'price': '₹7,100', 'trend': '-₹50', 'up': false},
      {'crop': 'Soybean', 'price': '₹4,650', 'trend': '+₹110', 'up': true},
      {'crop': 'Gram (Chana)', 'price': '₹5,300', 'trend': '+₹15', 'up': true},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📊 Market Prices',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: GoogleFonts.manrope(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 116,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: prices.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = prices[index];
              final isUp = item['up'] as bool;
              final trendColor = isUp ? AppColors.primary : AppColors.error;

              return Container(
                width: 160,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: trendColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['crop'] as String,
                      style: GoogleFonts.manrope(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['price'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                          size: 14,
                          color: trendColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item['trend'] as String,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: trendColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
