import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../crop_doctor/screens/crop_doctor_screen.dart';
import '../../market_prices/screens/market_screen.dart';
import '../../weather/screens/weather_screen.dart';
import '../../govt_schemes/screens/schemes_list_screen.dart';
import '../../soil_advisor/screens/soil_input_screen.dart';
import '../../crop_calendar/screens/crop_calendar_screen.dart';
import '../../farm_diary/screens/farm_diary_screen.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'title': 'Crop Doctor', 'emoji': '🩺', 'color': const Color(0xFFEF5350)},
      {'title': 'Mandi Prices', 'emoji': '📈', 'color': const Color(0xFF42A5F5)},
      {'title': 'Weather', 'emoji': '🌤️', 'color': const Color(0xFF26C6DA)},
      {'title': 'Schemes', 'emoji': '🏛️', 'color': const Color(0xFFFF7043)},
      {'title': 'Soil Advisor', 'emoji': '🌎', 'color': const Color(0xFFAB47BC)},
      {'title': 'Farm Diary', 'emoji': '📔', 'color': const Color(0xFF26A69A)},
      {'title': 'Crop Calendar', 'emoji': '📅', 'color': const Color(0xFF66BB6A)},
      {'title': 'Community', 'emoji': '👥', 'color': const Color(0xFF8D6E63)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        final color = action['color'] as Color;
        return GestureDetector(
          onTap: () {
            Widget? destination;
            switch (action['title']) {
              case 'Crop Doctor':
                destination = const CropDoctorScreen();
                break;
              case 'Mandi Prices':
                destination = const MarketScreen();
                break;
              case 'Weather':
                destination = const WeatherScreen();
                break;
              case 'Schemes':
                destination = const SchemesListScreen();
                break;
              case 'Soil Advisor':
                destination = const SoilInputScreen();
                break;
              case 'Farm Diary':
                destination = const FarmDiaryScreen();
                break;
              case 'Crop Calendar':
                destination = const CropCalendarScreen();
                break;
            }
            if (destination != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => destination!),
              );
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.25)),
                ),
                child: Center(
                  child: Text(
                    action['emoji'] as String,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                action['title'] as String,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

