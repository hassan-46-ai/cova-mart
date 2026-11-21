import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/catalog.dart';
import '../notifications/notification_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/local_store.dart';
import '../../data/services/location_service.dart';
import '../../data/services/nominatim_service.dart';

/// Overridden in `main()` with the real instances loaded before `runApp`.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider must be overridden'),
);

final catalogProvider = Provider<Catalog>(
  (ref) => throw UnimplementedError('catalogProvider must be overridden'),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => throw UnimplementedError('notificationServiceProvider must be overridden'),
);

final localStoreProvider = Provider<LocalStore>((ref) => LocalStore(ref.watch(sharedPrefsProvider)));

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(localStoreProvider)));

final nominatimProvider = Provider<NominatimService>((ref) => NominatimService());

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());
