import 'package:flutter/painting.dart';

class Category {
  const Category({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.subtitleEn,
    required this.subtitleAr,
    required this.tint,
    required this.icon,
    required this.storageEn,
    required this.storageAr,
  });

  factory Category.fromJson(Map<String, dynamic> j) => Category(
        id: j['id'] as String,
        nameEn: j['nameEn'] as String,
        nameAr: j['nameAr'] as String,
        subtitleEn: j['subtitleEn'] as String,
        subtitleAr: j['subtitleAr'] as String,
        tint: Color(int.parse('FF${j['tint']}', radix: 16)),
        icon: j['icon'] as String,
        storageEn: j['storageEn'] as String,
        storageAr: j['storageAr'] as String,
      );

  final String id;
  final String nameEn;
  final String nameAr;
  final String subtitleEn;
  final String subtitleAr;
  final Color tint;
  final String icon;
  final String storageEn;
  final String storageAr;

  String name(String lang) => lang == 'ar' ? nameAr : nameEn;
  String subtitle(String lang) => lang == 'ar' ? subtitleAr : subtitleEn;
  String storage(String lang) => lang == 'ar' ? storageAr : storageEn;
}
