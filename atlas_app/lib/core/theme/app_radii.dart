import 'package:flutter/material.dart';

/// Centralized border radius constants.
class AppRadii {
  AppRadii._();

  static const double small = 8;
  static const double medium = 12;
  static const double card = 16;
  static const double large = 20;
  static const double pill = 999;

  // Button
  static const double button = 14;
  static const double buttonHeight = 48;

  // Pre-built BorderRadius for convenience
  static final BorderRadius smallRadius = BorderRadius.circular(small);
  static final BorderRadius mediumRadius = BorderRadius.circular(medium);
  static final BorderRadius cardRadius = BorderRadius.circular(card);
  static final BorderRadius largeRadius = BorderRadius.circular(large);
  static final BorderRadius pillRadius = BorderRadius.circular(pill);
  static final BorderRadius buttonRadius = BorderRadius.circular(button);
}
