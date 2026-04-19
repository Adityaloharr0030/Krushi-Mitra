import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MarketPriceSlider extends StatelessWidget {
  const MarketPriceSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final prices = [
      {'crop': 'Wheat (Kanak)', 'price': '₹2,275', 'trend': '+₹25', 'up': true},
      {'crop': 'Cotton (Kapas)', 'price': '₹7,100', 'trend': '-₹50', 'up': false},
      {'crop': 'Soybean', 'price': '4,650', 'trend': '+₹110', 'up': true},
      {'crop': 'Gram (Chana)', 'price': '5,300', 'trend': '+₹15', 'up': true},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Market Prices (Mandi)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 110,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: prices.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = prices[index];
              final isUp = item['up'] as bool;
              
              return Container(
                width: 160,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.textHint.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['crop'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          item['price'] as String,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          isUp ? Icons.trending_up : Icons.trending_down,
                          size: 16,
                          color: isUp ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                    Text(
                      item['trend'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: isUp ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
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
