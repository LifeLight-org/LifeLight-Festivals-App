import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFFFD000), // #ffd000
      surfaceTint: Color(0xFFFFD000), // #ffd000
      onPrimary: Color(0xFFFFFFFF), // #ffffff
      primaryContainer: Color(0xFFB8A87B), // #b8a87b
      onPrimaryContainer: Color(0xFFFFD000), // #ffd000
      secondary: Color(0xFFB8A87B), // #b8a87b
      onSecondary: Color(0xFF1B1B1B), // #1b1b1b
      secondaryContainer: Color(0xFFE1E1E1), // #e1e1e1
      onSecondaryContainer: Color(0xFF1B1B1B), // #1b1b1b
      tertiary: Color(0xFFFFD000), // #ffd000
      onTertiary: Color(0xFFFFFFFF), // #ffffff
      tertiaryContainer: Color(0xFFB8A87B), // #b8a87b
      onTertiaryContainer: Color(0xFFFFD000), // #ffd000
      error: Color(0xFFFFCDD2), // Light red
      onError: Color(0xFF000000), // Black
      errorContainer: Color(0xFFFFEBEE), // Very light red
      onErrorContainer: Color(0xFF000000), // Black
      surface: Color(0xFF1B1B1B), // #1b1b1b
      onSurface: Color(0xFFFFFFFF), // #ffffff
      onSurfaceVariant: Color(0xFFE1E1E1), // #e1e1e1
      outline: Color(0xFF5F5F5F), // #5f5f5f
      outlineVariant: Color(0xFFE1E1E1), // #e1e1e1
      shadow: Color(0xFF000000), // Black
      scrim: Color(0xFF000000), // Black
      inverseSurface: Color(0xFFFFFFFF), // #ffffff
      inversePrimary: Color(0xFFB8A87B), // #b8a87b
      primaryFixed: Color(0xFFFFD000), // #ffd000
      onPrimaryFixed: Color(0xFF1B1B1B), // #1b1b1b
      primaryFixedDim: Color(0xFFFFD000), // #ffd000
      onPrimaryFixedVariant: Color(0xFFB8A87B), // #b8a87b
      secondaryFixed: Color(0xFFB8A87B), // #b8a87b
      onSecondaryFixed: Color(0xFF1B1B1B), // #1b1b1b
      secondaryFixedDim: Color(0xFFB8A87B), // #b8a87b
      onSecondaryFixedVariant: Color(0xFFE1E1E1), // #e1e1e1
      tertiaryFixed: Color(0xFFFFD000), // #ffd000
      onTertiaryFixed: Color(0xFF1B1B1B), // #1b1b1b
      tertiaryFixedDim: Color(0xFFFFD000), // #ffd000
      onTertiaryFixedVariant: Color(0xFFB8A87B), // #b8a87b
      surfaceDim: Color(0xFF2C2C2C), // #2c2c2c
      surfaceBright: Color(0xFF5F5F5F), // #5f5f5f
      surfaceContainerLowest: Color(0xFF1B1B1B), // #1b1b1b
      surfaceContainerLow: Color(0xFF2C2C2C), // #2c2c2c
      surfaceContainer: Color(0xFF5F5F5F), // #5f5f5f
      surfaceContainerHigh: Color(0xFFE1E1E1), // #e1e1e1
      surfaceContainerHighest: Color(0xFFF2F2F2), // #f2f2f2
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.background,
        canvasColor: colorScheme.surface,
        appBarTheme: AppBarTheme(
          centerTitle: true, // Center the title text
          titleTextStyle: TextStyle(
            fontSize: 25, // Adjusted font size for app bar title
            fontWeight: FontWeight.w900, // Ensure this is applied
            letterSpacing: 1.25,
            color: colorScheme.onSurface,
          ),
          backgroundColor: Color(0xFF1C1C1C), // Explicitly set the background color to #1c1c1c
        ),
      );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}