import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../core/config/app_config.dart';

/// OpenStreetMap tiles, auto-inverted in dark mode.
/// Tile policy: https://operations.osmfoundation.org/policies/tiles/
/// For heavy production traffic use a tile provider you have an account with.
class OsmTileLayer extends StatelessWidget {
  const OsmTileLayer({super.key});

  static Widget _darkTile(BuildContext context, Widget tileWidget, TileImage tile) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        -0.2126, -0.7152, -0.0722, 0, 255, //
        -0.2126, -0.7152, -0.0722, 0, 255,
        -0.2126, -0.7152, -0.0722, 0, 255,
        0, 0, 0, 1, 0,
      ]),
      child: tileWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return TileLayer(
      urlTemplate: AppConfig.tileUrl,
      userAgentPackageName: AppConfig.tilePackage,
      tileBuilder: dark ? _darkTile : null,
    );
  }
}

class OsmAttribution extends StatelessWidget {
  const OsmAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    return const RichAttributionWidget(
      attributions: [TextSourceAttribution('OpenStreetMap contributors')],
    );
  }
}
