import 'package:flutter/material.dart';

IconData categoryIcon(String key) {
  switch (key) {
    case 'produce':
      return Icons.eco_rounded;
    case 'dairy':
      return Icons.egg_alt_rounded;
    case 'bakery':
      return Icons.bakery_dining_rounded;
    case 'coffee':
      return Icons.coffee_rounded;
    case 'drinks':
      return Icons.local_drink_rounded;
    case 'snacks':
      return Icons.cookie_rounded;
    case 'pantry':
      return Icons.rice_bowl_rounded;
    case 'frozen':
      return Icons.ac_unit_rounded;
    case 'care':
      return Icons.spa_rounded;
    case 'home':
      return Icons.cleaning_services_rounded;
    default:
      return Icons.shopping_basket_rounded;
  }
}
