# 🌾 Krushi Mitra — कृषि मित्र
### *Your AI-Powered Farmer's Friend*

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/Firebase-Enabled-FFCA28?style=for-the-badge&logo=firebase&logoColor=black"/>
  <img src="https://img.shields.io/badge/AI-Claude%20API-6B4EFF?style=for-the-badge&logo=anthropic&logoColor=white"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=for-the-badge"/>
</p>

---

### [🚀 Live Preview Interface](https://adityaloharr0030.github.io/Krushi-Mitra/) | [🎨 Stitch Design Project](https://stitch.google.com/projects/4491219888089917293)

---

**Krushi Mitra** (meaning *Farmer's Friend* in Hindi/Marathi) is a comprehensive AI-powered mobile application built with Flutter, designed to empower Indian farmers with smart agricultural tools, real-time data, and intelligent assistance — all in their local language.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🤖 **AI Crop Doctor** | Upload a photo of your crop and get instant AI diagnosis using Claude Vision API |
| 💬 **AI Chatbot** | Ask farming questions in Hindi, Marathi, or English and get intelligent answers |
| 🌦️ **Weather Updates** | Real-time hyperlocal weather forecasts tailored for farming decisions |
| 📈 **Market Prices** | Live mandi (market) prices for crops across India |
| 🏛️ **Government Schemes** | Browse and apply for relevant government agricultural schemes |
| 🌱 **Soil Advisor** | AI-based soil health analysis and fertilizer recommendations |
| 📅 **Crop Calendar** | Personalized planting and harvesting schedule based on your location |
| 📓 **Farm Diary** | Log daily farm activities, expenses, and observations |
| 🧮 **Input Calculator** | Calculate seed, fertilizer, and pesticide quantities per acre |
| 👥 **Community** | Connect with other farmers, share knowledge and experiences |
| 👤 **Profile & Settings** | Manage your farm profile, preferred language, and crop preferences |

---

## 📱 Screenshots

> Coming soon — App is actively in development.

---

## 🏗️ Project Architecture

```
krushi_mitra/
├── lib/
│   ├── app.dart                    # App entry point & routing
│   ├── main.dart                   # Firebase & app initialization
│   ├── core/
│   │   ├── constants/              # App colors, strings, API constants
│   │   ├── services/               # AI, Weather, Firebase services
│   │   ├── theme/                  # App theme & typography
│   │   └── utils/                  # Helper functions & extensions
│   ├── data/
│   │   └── models/                 # Data models (Weather, Post, etc.)
│   ├── features/
│   │   ├── ai_doctor/              # AI crop diagnosis feature
│   │   ├── auth/                   # Firebase authentication
│   │   ├── chatbot/                # AI chatbot interface
│   │   ├── community/              # Farmer community feed
│   │   ├── crop_calendar/          # Crop planting calendar
│   │   ├── crop_doctor/            # Crop disease detection
│   │   ├── farm_diary/             # Farm activity logger
│   │   ├── govt_schemes/           # Government schemes browser
│   │   ├── home/                   # Dashboard & home screens
│   │   ├── input_calculator/       # Agricultural input calculator
│   │   ├── market_prices/          # Live mandi price tracker
│   │   ├── onboarding/             # First-run onboarding flow
│   │   ├── profile/                # User profile & settings
│   │   ├── soil_advisor/           # Soil health AI advisor
│   │   └── weather/                # Weather forecast feature
│   └── shared/
│       └── widgets/                # Reusable UI components
├── assets/
│   └── fonts/                      # Poppins font family
└── web/                            # Flutter web support
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>=3.0.0`
- [Dart SDK](https://dart.dev/get-dart) `>=3.0.0`
- [Firebase CLI](https://firebase.google.com/docs/cli)
- An [Anthropic API key](https://www.anthropic.com/) for Claude AI features
- A [OpenWeather API key](https://openweathermap.org/api) for weather data

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Adityaloharr0030/Krushi-Mitra.git
   cd Krushi-Mitra/krushi_mitra
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   ```bash
   firebase login
   flutterfire configure
   ```
   This will generate `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).

4. **Set up API Keys**

   Create `lib/core/constants/api_constants.dart` and add:
   ```dart
   class ApiConstants {
     static const String anthropicApiKey = 'YOUR_CLAUDE_API_KEY';
     static const String weatherApiKey = 'YOUR_OPENWEATHER_API_KEY';
   }
   ```

   > ⚠️ **Never commit your API keys to version control!** Add to `.gitignore`.

5. **Run the app**
   ```bash
   flutter run
   ```

---

## 🔑 Environment Variables / API Keys Required

| Key | Service | Purpose |
|---|---|---|
| `ANTHROPIC_API_KEY` | [Anthropic Claude](https://www.anthropic.com/) | AI crop diagnosis & chatbot |
| `OPENWEATHER_API_KEY` | [OpenWeatherMap](https://openweathermap.org/) | Weather forecasting |
| Firebase config | [Firebase Console](https://console.firebase.google.com/) | Auth, Firestore, Storage |

---

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x (Dart)
- **Backend**: Firebase (Auth, Firestore, Storage)
- **AI**: Anthropic Claude API (Vision + Text)
- **Weather**: OpenWeatherMap API
- **Fonts**: Poppins (Google Fonts)
- **State Management**: setState + FutureBuilder (lightweight)
- **Image Handling**: `image_picker`, `cached_network_image`

---

## 🌐 Supported Languages

- 🇮🇳 Hindi (हिंदी)
- 🇮🇳 Marathi (मराठी)  
- 🇬🇧 English

---

## 🤝 Contributing

Contributions are welcome! Here's how to get started:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'feat: add amazing feature'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a Pull Request

Please follow the [Conventional Commits](https://www.conventionalcommits.org/) format.

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Developer

**Aditya Lohar**  
GitHub: [@Adityaloharr0030](https://github.com/Adityaloharr0030)
**Hitesh More**
GitHub: [@hiteshmore3636](https://github.com/hiteshmore3636)


---

<p align="center">
  Made with ❤️ for Indian Farmers 🌾
</p>
