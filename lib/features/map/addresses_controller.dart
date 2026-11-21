import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../data/models/address.dart';
import '../../data/services/local_store.dart';
import '../auth/auth_controller.dart';

class AddressesState {
  const AddressesState({this.items = const [], this.selectedId});

  final List<Address> items;
  final String? selectedId;

  /// The delivery address in use (explicit choice, else the first saved).
  Address? get selected {
    if (items.isEmpty) return null;
    return items.firstWhere((a) => a.id == selectedId, orElse: () => items.first);
  }
}

class AddressesController extends Notifier<AddressesState> {
  late String _key;

  @override
  AddressesState build() {
    _key = StoreKeys.addresses(ref.watch(userIdProvider));
    final raw = ref.read(localStoreProvider).readJson(_key);
    if (raw is! Map) return const AddressesState();
    return AddressesState(
      items: [for (final a in raw['items'] as List) Address.fromJson(Map<String, dynamic>.from(a as Map))],
      selectedId: raw['selected'] as String?,
    );
  }

  Address add({
    required AddressLabel label,
    required String details,
    required double lat,
    required double lng,
  }) {
    final address = Address(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      label: label,
      details: details,
      lat: lat,
      lng: lng,
    );
    _save(AddressesState(items: [...state.items, address], selectedId: address.id));
    return address;
  }

  void update(Address address) => _save(AddressesState(
        items: [for (final a in state.items) a.id == address.id ? address : a],
        selectedId: state.selectedId,
      ));

  void select(String id) => _save(AddressesState(items: state.items, selectedId: id));

  void remove(String id) {
    final items = state.items.where((a) => a.id != id).toList();
    _save(AddressesState(items: items, selectedId: state.selectedId == id ? null : state.selectedId));
  }

  void _save(AddressesState next) {
    state = next;
    ref.read(localStoreProvider).writeJson(_key, {
      'items': [for (final a in next.items) a.toJson()],
      'selected': next.selectedId,
    });
  }
}

final addressesProvider = NotifierProvider<AddressesController, AddressesState>(AddressesController.new);

final selectedAddressProvider = Provider<Address?>((ref) => ref.watch(addressesProvider).selected);
