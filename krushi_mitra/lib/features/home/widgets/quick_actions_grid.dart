import 'package:flutter/material.dart';
import '../../crop_doctor/screens/crop_doctor_screen.dart';
import '../../market_prices/screens/market_screen.dart';
import '../../weather/screens/weather_screen.dart';
import '../../govt_schemes/screens/schemes_list_screen.dart';
import '../../soil_advisor/screens/soil_input_screen.dart';
import '../../crop_calendar/screens/crop_calendar_screen.dart';
import '../../farm_diary/screens/farm_diary_screen.dart';
// import '../../chatbot/screens/chatbot_screen.dart'; (Already in bottom nav, but can add)

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'title': 'Crop Doctor', 'icon': Icons.healing, 'color': Colors.red.shade400},
      {'title': 'Mandi Prices', 'icon': Icons.trending_up, 'color': Colors.blue.shade400},
      {'title': 'AI Chat', 'icon': Icons.chat, 'color': Colors.green.shade400},
      {'title': 'Schemes', 'icon': Icons.account_balance, 'color': Colors.orange.shade400},
      {'title': 'Weather', 'icon': Icons.wb_sunny, 'color': Colors.amber.shade400},
      {'title': 'Soil Advisor', 'icon': Icons.science, 'color': Colors.purple.shade400},
      {'title': 'Farm Diary', 'icon': Icons.book, 'color': Colors.brown.shade400},
      {'title': 'Community', 'icon': Icons.people, 'color': Colors.teal.shade400},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return InkWell(
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
              case 'Soil Advisor': // Assuming you'll change 'Calculator' to 'Soil Advisor' or add it
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => destination!));
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: (action['color'] as Color).withOpacity(0.2),
                radius: 28,
                child: Icon(
                  action['icon'] as IconData,
                  color: action['color'] as Color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                action['title'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
              ),
            ],
          ),
        );
      },
    );
  }
}
