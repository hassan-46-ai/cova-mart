import 'package:flutter/material.dart';

/// The Cova Mart logo (white on black). Use it on black backgrounds only.
class CovaLogo extends StatelessWidget {
  const CovaLogo({super.key, this.height = 120});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/logo.png', height: height, fit: BoxFit.contain);
  }
}
