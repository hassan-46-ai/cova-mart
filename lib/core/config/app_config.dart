import 'package:latlong2/latlong.dart';

/// App-wide constants. Change store rules (fees, minimum order…) here only.
abstract final class AppConfig {
  static const appName = 'Cova Mart';

  // Delivery rules for a neighbourhood mart.
  static const deliveryFee = 15.0;
  static const freeDeliveryFrom = 300.0;
  static const minOrder = 50.0;
  static const deliveryMinutes = 30;

  // OpenStreetMap / Nominatim. Both services require an identifying user agent.
  static const userAgent = 'CovaMart/1.0 (com.cova.mart)';
  static const tilePackage = 'com.cova.mart';
  static const tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const nominatimHost = 'nominatim.openstreetmap.org';
  static const countryCodes = 'eg';

  /// Map starts here when the user has no saved location (Alexandria, Egypt).
  static const defaultCenter = LatLng(31.2001, 29.9187);
}
