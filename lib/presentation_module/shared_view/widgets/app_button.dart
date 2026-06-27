import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isExpanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? ElevatedButton(
            onPressed: onPressed,
            child: Text(label, style: TextStyle(fontSize: 16.r)),
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label, style: TextStyle(fontSize: 16.r)),
          );

    if (!isExpanded) return child;
    return SizedBox(width: double.infinity, child: child);
  }
}
