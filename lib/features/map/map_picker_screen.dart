import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/config/app_config.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/cova_chip.dart';
import '../../core/widgets/round_icon_button.dart';
import '../../core/widgets/snack.dart';
import '../../data/models/address.dart';
import '../../data/services/location_service.dart';
import '../../data/services/nominatim_service.dart';
import 'address_ui.dart';
import 'osm_tile_layer.dart';

class MapPickerArgs {
  const MapPickerArgs({this.initial, this.details, this.label = AddressLabel.home});

  final LatLng? initial;
  final String? details;
  final AddressLabel label;
}

class PickedLocation {
  const PickedLocation({required this.point, required this.details, required this.label});

  final LatLng point;
  final String details;
  final AddressLabel label;
}

/// Full-screen OpenStreetMap picker: drag the map under the centre pin,
/// search an address, or jump to the GPS position.
class MapPickerScreen extends ConsumerStatefulWidget {
  const MapPickerScreen({super.key, this.args});

  final MapPickerArgs? args;

  @override
  ConsumerState<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends ConsumerState<MapPickerScreen> {
  final _map = MapController();
  final _details = TextEditingController();
  final _search = TextEditingController();
  late LatLng _center;
  late AddressLabel _label;
  Timer? _debounce;
  bool _dragging = false;
  bool _resolving = false;
  bool _dirty = false;
  bool _searching = false;
  List<PlaceResult> _results = const [];

  @override
  void initState() {
    super.initState();
    final args = widget.args;
    _center = args?.initial ?? AppConfig.defaultCenter;
    _label = args?.label ?? AddressLabel.home;
    _details.text = args?.details ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (args?.initial == null) {
        _locate(silent: true);
      } else if (_details.text.isEmpty) {
        _scheduleReverse(immediate: true);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _details.dispose();
    _search.dispose();
    _map.dispose();
    super.dispose();
  }

  void _scheduleReverse({bool immediate = false}) {
    _debounce?.cancel();
    _debounce = Timer(immediate ? Duration.zero : const Duration(milliseconds: 700), () async {
      if (!mounted) return;
      setState(() {
        _dragging = false;
        _resolving = true;
      });
      final name = await ref.read(nominatimProvider).reverse(_center, lang: context.lang);
      if (!mounted) return;
      setState(() {
        _resolving = false;
        if (name != null && !_dirty) _details.text = name;
      });
    });
  }

  Future<void> _locate({bool silent = false}) async {
    final service = ref.read(locationServiceProvider);
    final result = await service.current();
    if (!mounted) return;
    final point = result.point;
    if (point == null) {
      if (!silent) _explain(service, result.failure!);
      return;
    }
    _map.move(point, 17);
    _center = point;
    _dirty = false;
    _scheduleReverse(immediate: true);
  }

  void _explain(LocationService service, LocationFailure failure) {
    final l10n = context.l10n;
    final message = switch (failure) {
      LocationFailure.serviceDisabled => l10n.locationServiceOff,
      LocationFailure.denied => l10n.locationDenied,
      LocationFailure.deniedForever => l10n.locationDeniedForever,
      LocationFailure.notConfigured => l10n.locationNotConfigured,
      LocationFailure.unavailable => l10n.locationUnavailable,
    };
    final canFix = failure == LocationFailure.serviceDisabled || failure == LocationFailure.deniedForever;
    showCovaSnack(
      context,
      message,
      actionLabel: canFix ? l10n.openSettings : null,
      onAction: canFix ? () => service.openSettings(failure) : null,
    );
  }

  Future<void> _runSearch(String q) async {
    if (q.trim().length < 3) return;
    setState(() => _searching = true);
    final results = await ref.read(nominatimProvider).search(q, lang: context.lang);
    if (!mounted) return;
    setState(() {
      _results = results;
      _searching = false;
    });
    if (results.isEmpty) showCovaSnack(context, context.l10n.noResults);
  }

  void _pick(PlaceResult r) {
    FocusScope.of(context).unfocus();
    _map.move(r.point, 17);
    setState(() {
      _center = r.point;
      _results = const [];
      _dirty = false;
      _details.text = r.name;
      _search.clear();
    });
  }

  void _confirm() {
    final text = _details.text.trim();
    if (text.isEmpty) {
      showCovaSnack(context, context.l10n.errRequired);
      return;
    }
    context.pop(PickedLocation(point: _center, details: text, label: _label));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox.expand(
       child: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 16,
              minZoom: 4,
              maxZoom: 19,
              onPositionChanged: (camera, hasGesture) {
                _center = camera.center;
                if (hasGesture) {
                  _dirty = false;
                  if (!_dragging) setState(() => _dragging = true);
                  _scheduleReverse();
                }
              },
            ),
            children: const [OsmTileLayer(), OsmAttribution()],
          ),
          // Centre pin: the map moves underneath it.
          Center(
            child: IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 56),
                child: AnimatedSlide(
                  offset: Offset(0, _dragging ? -0.18 : 0),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: Icon(Icons.location_on_rounded, size: 56, color: dark ? AppColors.cyan : AppColors.black),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const AppBackButton(),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Material(
                          elevation: 6,
                          shadowColor: Colors.black38,
                          borderRadius: BorderRadius.circular(16),
                          color: c.card,
                          child: TextField(
                            controller: _search,
                            textInputAction: TextInputAction.search,
                            onSubmitted: _runSearch,
                            decoration: InputDecoration(
                              hintText: l10n.searchAddress,
                              filled: false,
                              prefixIcon: Icon(Icons.search_rounded, color: c.muted),
                              suffixIcon: _searching
                                  ? const Padding(
                                      padding: EdgeInsets.all(14),
                                      child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_results.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      constraints: const BoxConstraints(maxHeight: 260),
                      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)]),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, i) => ListTile(
                          leading: const Icon(Icons.place_outlined),
                          title: Text(_results[i].name, maxLines: 2, overflow: TextOverflow.ellipsis),
                          onTap: () => _pick(_results[i]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            end: 16,
            bottom: 300 + keyboard,
            child: RoundIconButton(icon: Icons.my_location_rounded, size: 52, onTap: _locate),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: keyboard,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 16 + (keyboard > 0 ? 0 : MediaQuery.paddingOf(context).bottom)),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 24)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.confirmLocation, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (final l in AddressLabel.values) ...[
                        CovaChip(label: l.text(l10n), icon: l.icon, selected: _label == l, onTap: () => setState(() => _label = l)),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _details,
                    maxLines: 2,
                    minLines: 1,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    onChanged: (_) => _dirty = true,
                    decoration: InputDecoration(
                      labelText: l10n.addressDetails,
                      prefixIcon: const Icon(Icons.edit_location_alt_outlined),
                      suffixIcon: _resolving
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(label: l10n.confirmLocation, icon: Icons.check_rounded, onPressed: _confirm),
                ],
              ),
            ),
          ),
        ],
       ),
      ),
    );
  }
}
