import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

String _appTheme = "primary";
ThemeData get theme => ThemeHelper().themeData();
PrimaryColors get appTheme => ThemeHelper().themeColor();

class ThemeHelper {
  // A map of custom color themes supported by the app
  final Map<String, PrimaryColors> _supportedCustomColor = {
    'primary': PrimaryColors()
  };

  // A map of color schemes supported by the app
  final Map<String, ColorScheme> _supportedColorScheme = {
    'primary': ColorSchemes.primaryColorScheme
  };

  PrimaryColors _getThemeColors() {
    return _supportedCustomColor[_appTheme] ?? PrimaryColors();
  }

  ThemeData _getThemeData() {
    var colorScheme =
        _supportedColorScheme[_appTheme] ?? ColorSchemes.primaryColorScheme;
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
      textTheme: TextThemes.textTheme(colorScheme),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
          surfaceTintColor: Colors.transparent,
          elevation: 5,
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
          ),
      ),
      )

    );
  }
  ThemeData themeData() => _getThemeData();
  PrimaryColors themeColor() => _getThemeColors();
}

class ColorSchemes {
  static const primaryColorScheme = ColorScheme.light(
    primary: Color(0XFF800020),
    secondaryContainer: Color(0XFF1E1D1D),
    errorContainer: Color(0XFF32343E),
    onErrorContainer: Color(0XE5FFFFFF),
  );
}

/// Class containing custom colors for a primary theme.
class PrimaryColors {

   Color whiteColor = Colors.white;
   Color blackColor = Colors.black;
   Color greenColor = Color(0xff30B900);
    Color blueColor = Color(0xff28B1F1);
}

/// Class containing the supported text theme styles.
class TextThemes {

  static TextTheme textTheme(ColorScheme colorScheme) => TextTheme(

    bodyMedium: GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w400,
    ),


    bodySmall: GoogleFonts.poppins(
      fontWeight: FontWeight.w400,
    ),

    headlineLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 20
    ),

    headlineSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),

    headlineMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),

    labelLarge: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),

    labelMedium: GoogleFonts.poppins(
      fontSize: 10,
      fontWeight: FontWeight.w500,
    ),

    titleLarge: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w500,
    ),

    titleMedium: GoogleFonts.poppins(
      fontSize: 17,
      fontWeight: FontWeight.w600,
    ),

    titleSmall: GoogleFonts.poppins(
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),

  );
}
