import 'package:flutter/material.dart';

// Widget tombol capsule untuk HaloHealth Kit Box
class KitBoxButtonWidget extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const KitBoxButtonWidget({
    super.key,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFCE4EC) : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isActive ? const Color(0xFFF48FB1) : const Color(0xFFDDDDDD),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            isActive ? 'HaloHealth Kit Box Aktif ✓' : 'Akses HaloHealth Kit Box',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isActive ? const Color(0xFFC2185B) : const Color(0xFF333333),
            ),
          ),
        ),
      ),
    );
  }
}