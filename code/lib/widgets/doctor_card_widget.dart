import 'package:flutter/material.dart';
import '../theme/colors.dart';

class DoctorCardWidget extends StatelessWidget {
  final String name;
  final String speciality;
  final IconData icon;
  final VoidCallback? onKonsultasi; // null = tombol nonaktif

  const DoctorCardWidget({
    super.key,
    required this.name,
    required this.speciality,
    required this.icon,
    this.onKonsultasi,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon dokter
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primaryPink, size: 30),
            ),
            const SizedBox(width: 14),

            // Nama & spesialisasi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    speciality,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Tombol konsultasi
            GestureDetector(
              onTap: onKonsultasi,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: onKonsultasi != null
                      ? AppColors.primaryPink
                      : const Color(0xFFE91E8C),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Konsultasi',
                  style: TextStyle(
                    color: onKonsultasi != null
                        ? Colors.white
                        : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}