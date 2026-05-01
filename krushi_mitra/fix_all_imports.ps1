$dartFiles = Get-ChildItem -Path lib -Filter *.dart -Recurse
foreach ($file in $dartFiles) {
    $fileName = $file.Name
    $content = Get-Content $file.FullName
    $usesAppTheme = $content -match "AppTheme\."
    $hasAppThemeImport = $content -match "app_theme\.dart"
    $usesGoogleFonts = $content -match "GoogleFonts\."
    $hasGoogleFontsImport = $content -match "google_fonts\.dart"
    $usesAppColors = $content -match "AppColors\."
    $hasAppColorsImport = $content -match "app_colors\.dart"

    if (($usesAppTheme -and -not $hasAppThemeImport -and ($fileName -ne "app_theme.dart")) -or 
        ($usesGoogleFonts -and -not $hasGoogleFontsImport) -or 
        ($usesAppColors -and -not $hasAppColorsImport -and ($fileName -ne "app_colors.dart"))) {
        
        $newContent = @()
        $lastImportIndex = -1
        for ($i = 0; $i -lt $content.Length; $i++) {
            if ($content[$i] -match "^import ") { $lastImportIndex = $i }
        }
        if ($lastImportIndex -eq -1) { $lastImportIndex = 0 }

        # Determine relative path
        $rel = $file.FullName.ToLower().Replace("c:\krushi mitra\krushi_mitra\lib\", "")
        $parts = $rel -split "\\"
        $depth = $parts.Length - 1
        $prefix = "../" * $depth
        if ($depth -eq 0) { $prefix = "./" }

        for ($i = 0; $i -lt $content.Length; $i++) {
            $newContent += $content[$i]
            if ($i -eq $lastImportIndex) {
                if ($usesGoogleFonts -and -not $hasGoogleFontsImport) {
                    $newContent += "import 'package:google_fonts/google_fonts.dart';"
                    $hasGoogleFontsImport = $true
                }
                if ($usesAppColors -and -not $hasAppColorsImport -and ($fileName -ne "app_colors.dart")) {
                    $newContent += "import '${prefix}core/theme/app_colors.dart';"
                    $hasAppColorsImport = $true
                }
                if ($usesAppTheme -and -not $hasAppThemeImport -and ($fileName -ne "app_theme.dart")) {
                    $newContent += "import '${prefix}core/theme/app_theme.dart';"
                    $hasAppThemeImport = $true
                }
            }
        }
        
        $newContent | Set-Content $file.FullName
        Write-Host "Fixed imports in $($file.FullName)"
    }
}
