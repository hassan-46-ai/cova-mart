import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum LocationFailure {
  /// GPS / location switch is off on the device.
  serviceDisabled,

  /// User declined this time (can be asked again).
  denied,

  /// User chose "don't ask again" - only the system settings can change it.
  deniedForever,

  /// Permission entries are missing from AndroidManifest.xml / Info.plist.
  notConfigured,

  /// Permission is fine but no position arrived (indoors, emulator without a mock location…).
  unavailable,
}

class LocationResult {
  const LocationResult.ok(LatLng this.point) : failure = null;
  const LocationResult.fail(LocationFailure this.failure) : point = null;

  final LatLng? point;
  final LocationFailure? failure;
}

/// Device GPS position with a precise failure reason.
class LocationService {
  Future<LocationResult> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationResult.fail(LocationFailure.serviceDisabled);
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.fail(LocationFailure.deniedForever);
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.unableToDetermine) {
        return const LocationResult.fail(LocationFailure.denied);
      }

      // Fast answer first (last known fix), then a fresh high-accuracy reading.
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 20),
          ),
        );
        return LocationResult.ok(LatLng(pos.latitude, pos.longitude));
      } on TimeoutException {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) return LocationResult.ok(LatLng(last.latitude, last.longitude));
        return const LocationResult.fail(LocationFailure.unavailable);
      }
    } on PermissionDefinitionsNotFoundException {
      return const LocationResult.fail(LocationFailure.notConfigured);
    } catch (_) {
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) return LocationResult.ok(LatLng(last.latitude, last.longitude));
      } catch (_) {}
      return const LocationResult.fail(LocationFailure.unavailable);
    }
  }

  /// Opens the screen where the user can fix [failure].
  Future<void> openSettings(LocationFailure failure) async {
    if (failure == LocationFailure.serviceDisabled) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  }
}
