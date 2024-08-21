import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme createTextTheme(
    BuildContext context, String bodyFontString, String displayFontString) {
  TextTheme baseTextTheme = Theme.of(context).textTheme;
  TextTheme bodyTextTheme = GoogleFonts.getTextTheme(bodyFontString, baseTextTheme);
  TextTheme displayTextTheme =
      GoogleFonts.getTextTheme(displayFontString, baseTextTheme);
  TextTheme textTheme = displayTextTheme.copyWith(
    bodyLarge: bodyTextTheme.bodyLarge?.copyWith(
      fontFamily: 'Raleway',
      fontSize: 20, // Adjusted font size
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
    ),
    bodyMedium: bodyTextTheme.bodyMedium?.copyWith(
      fontFamily: 'Raleway',
      fontSize: 16, // Adjusted font size
      fontWeight: FontWeight.w800,
      letterSpacing: 1.25,
    ),
    bodySmall: bodyTextTheme.bodySmall?.copyWith(
      fontFamily: 'Raleway',
      fontSize: 14, // Adjusted font size
      fontWeight: FontWeight.w800,
      letterSpacing: 1.25,
    ),
    labelLarge: bodyTextTheme.labelLarge?.copyWith(
      fontFamily: 'Raleway',
      fontSize: 16, // Adjusted font size
      fontWeight: FontWeight.w800,
      letterSpacing: 1.25,
    ),
    labelMedium: bodyTextTheme.labelMedium?.copyWith(
      fontFamily: 'Raleway',
      fontSize: 14, // Adjusted font size
      fontWeight: FontWeight.w800,
      letterSpacing: 1.25,
    ),
    labelSmall: bodyTextTheme.labelSmall?.copyWith(
      fontFamily: 'Raleway',
      fontSize: 12, // Adjusted font size
      fontWeight: FontWeight.w800,
      letterSpacing: 1.25,
    ),
  );
  return textTheme;
}