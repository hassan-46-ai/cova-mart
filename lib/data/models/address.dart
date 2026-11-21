import 'package:latlong2/latlong.dart';

class Address {
  const Address({
    required this.id,
    required this.label,
    required this.details,
    required this.lat,
    required this.lng,
  });

  factory Address.fromJson(Map<String, dynamic> j) => Address(
        id: j['id'] as String,
        label: AddressLabel.values.byName(j['label'] as String),
        details: j['details'] as String,
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
      );

  final String id;
  final AddressLabel label;
  final String details;
  final double lat;
  final double lng;

  LatLng get point => LatLng(lat, lng);

  Address copyWith({AddressLabel? label, String? details, double? lat, double? lng}) => Address(
        id: id,
        label: label ?? this.label,
        details: details ?? this.details,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label.name,
        'details': details,
        'lat': lat,
        'lng': lng,
      };
}

enum AddressLabel { home, work, other }
