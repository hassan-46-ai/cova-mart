import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../core/config/app_config.dart';

class PlaceResult {
  const PlaceResult({required this.name, required this.point});

  final String name;
  final LatLng point;
}

/// OpenStreetMap geocoding (Nominatim).
/// Usage policy: identify the app, max 1 request/second, no bulk use.
/// For production traffic host your own instance or use a commercial provider.
class NominatimService {
  NominatimService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _headers = {'User-Agent': AppConfig.userAgent};
  static const _timeout = Duration(seconds: 10);

  Future<List<PlaceResult>> search(String query, {required String lang}) async {
    final uri = Uri.https(AppConfig.nominatimHost, '/search', {
      'q': query,
      'format': 'jsonv2',
      'limit': '6',
      'accept-language': lang,
      'countrycodes': AppConfig.countryCodes,
    });
    try {
      final res = await _client.get(uri, headers: _headers).timeout(_timeout);
      if (res.statusCode != 200) return const [];
      final data = jsonDecode(res.body) as List<dynamic>;
      return [
        for (final r in data)
          PlaceResult(
            name: _shorten(r['display_name'] as String),
            point: LatLng(double.parse(r['lat'] as String), double.parse(r['lon'] as String)),
          ),
      ];
    } catch (_) {
      return const [];
    }
  }

  Future<String?> reverse(LatLng point, {required String lang}) async {
    final uri = Uri.https(AppConfig.nominatimHost, '/reverse', {
      'lat': point.latitude.toString(),
      'lon': point.longitude.toString(),
      'format': 'jsonv2',
      'accept-language': lang,
    });
    try {
      final res = await _client.get(uri, headers: _headers).timeout(_timeout);
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final name = data['display_name'] as String?;
      return name == null ? null : _shorten(name);
    } catch (_) {
      return null;
    }
  }

  String _shorten(String s) => s.split(',').take(4).map((e) => e.trim()).join(', ');
}
