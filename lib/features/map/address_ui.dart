import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/address.dart';

extension AddressLabelUi on AddressLabel {
  String text(AppLocalizations l10n) {
    switch (this) {
      case AddressLabel.home:
        return l10n.addressHome;
      case AddressLabel.work:
        return l10n.addressWork;
      case AddressLabel.other:
        return l10n.addressOther;
    }
  }

  IconData get icon {
    switch (this) {
      case AddressLabel.home:
        return Icons.home_rounded;
      case AddressLabel.work:
        return Icons.work_rounded;
      case AddressLabel.other:
        return Icons.place_rounded;
    }
  }
}

/// Address summary card. Highlighted with a cyan border when [selected].
class AddressCard extends StatelessWidget {
  const AddressCard({super.key, required this.address, this.selected = false, this.trailing});

  final Address address;
  final bool selected;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? AppColors.cyan : c.line, width: selected ? 1.8 : 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c.fab),
            child: Icon(address.label.icon, color: c.onFab, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(address.label.text(context.l10n), style: TextStyle(color: c.muted, fontSize: 12.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(address.details, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
