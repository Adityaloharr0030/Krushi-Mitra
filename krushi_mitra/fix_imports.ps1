$files = @(
    "lib/features/weather/screens/weather_screen.dart",
    "lib/features/soil_advisor/screens/soil_input_screen.dart",
    "lib/features/profile/screens/profile_screen.dart",
    "lib/features/onboarding/screens/profile_setup_screen.dart",
    "lib/features/onboarding/screens/language_selection_screen.dart",
    "lib/features/market_prices/screens/mandi_prices_screen.dart",
    "lib/features/market_prices/screens/market_screen.dart",
    "lib/features/input_calculator/screens/calculator_screen.dart",
    "lib/features/govt_schemes/screens/scheme_detail_screen.dart",
    "lib/features/govt_schemes/screens/schemes_list_screen.dart",
    "lib/features/farm_diary/screens/farm_diary_screen.dart",
    "lib/features/crop_calendar/screens/crop_calendar_screen.dart",
    "lib/features/chatbot/screens/chatbot_screen.dart",
    "lib/features/community/screens/create_post_screen.dart",
    "lib/features/community/screens/community_screen.dart",
    "lib/features/ai_doctor/screens/ai_doctor_screen.dart",
    "lib/features/auth/screens/login_screen.dart",
    "lib/features/auth/screens/auth_screens.dart"
)

foreach ($file in $files) {
    $path = "c:/krushi mitra/krushi_mitra/$file"
    if (Test-Path $path) {
        $content = Get-Content $path
        
        $hasAppTheme = $false
        $hasGoogleFonts = $false
        foreach ($line in $content) {
            if ($line -match "app_theme.dart") { $hasAppTheme = $true }
            if ($line -match "google_fonts.dart") { $hasGoogleFonts = $true }
        }
        
        $newContent = @()
        $addedAppTheme = $false
        $addedGoogleFonts = $false
        $changed = $false

        foreach ($line in $content) {
            $newContent += $line
            if (($line -match "import 'package:flutter/material.dart';") -and (-not $hasGoogleFonts) -and (-not $addedGoogleFonts)) {
                $newContent += "import 'package:google_fonts/google_fonts.dart';"
                $addedGoogleFonts = $true
                $changed = $true
            }
            if (($line -match "app_colors.dart") -and (-not $hasAppTheme) -and (-not $addedAppTheme)) {
                $prefix = "../../../"
                if ($file -match "lib/features/onboarding") { $prefix = "../../../" }
                if ($file -match "lib/features/auth") { $prefix = "../../../" }
                $newContent += "import '${prefix}core/theme/app_theme.dart';"
                $addedAppTheme = $true
                $changed = $true
            }
        }
        
        if ($changed) {
            $newContent | Set-Content $path
            Write-Host "Updated imports in $file"
        } else {
            # Write-Host "No changes needed for $file"
        }
    } else {
        Write-Host "File not found: $path"
    }
}
