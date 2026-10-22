

import 'package:flutter/material.dart';
import 'package:finpromade/theme/colors.dart';

/// Header teks section (contoh: "TENTANG ALAT INI", "RENTANG NORMAL")
Widget buildSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
        letterSpacing: 0.5,
      ),
    ),
  );
}

/// Card putih
Widget buildInfoCard({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
      ],
    ),
    child: child,
  );
}

/// Box indikator status Normal / Alert (warna hijau / merah muda)
Widget buildStatusIndicatorBox({
  required IconData icon,
  required String title,
  required String value,
  required bool isAlert,
}) {
  final Color bgColor = isAlert ? const Color(0xFFFFF0F2) : const Color(0xFFF0F9F4);
  final Color contentColor = isAlert ? AppColors.primaryPink : const Color(0xFF2E7D32);

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: contentColor),
            const SizedBox(width: 4),
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: contentColor)),
          ],
        ),
        const SizedBox(height: 6),
        Text(value, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
      ],
    ),
  );
}

/// Row satu poin tips pengukuran (icon bulat + teks)
Widget buildTipsRow({required IconData icon, required String text}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(color: Color(0xFFFFF0F2), shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.primaryPink, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.4)),
      ),
    ],
  );
}