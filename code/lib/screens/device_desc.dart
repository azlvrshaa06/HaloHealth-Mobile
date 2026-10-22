// =============================================================
// FITUR: Screen informasi detail alat kesehatan
// Menampilkan: tentang alat, rentang normal (pria/wanita), tips
// Menerima deviceName → ambil data dari deviceContentData
// Navigasi dari: HomeScreen (tap card alat kesehatan)
// =============================================================

import 'package:finpromade/theme/colors.dart';
import 'package:flutter/material.dart';
import '../data/dummy_info_device.dart';
import '../widgets/device_desc_components.dart';

class DeviceDesc extends StatelessWidget {
  final String deviceName;

  const DeviceDesc({super.key, required this.deviceName});

  @override
  Widget build(BuildContext context) {
    // Ambil data device; fallback ke TENSIMETER jika tidak ditemukan
    final data = deviceContentData[deviceName.toUpperCase()] ?? deviceContentData["TENSIMETER"]!;

    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('HaloHealth', style: TextStyle(fontSize: 18, color: AppColors.primaryPink, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // Konten scrollable
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama alat
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        deviceName.toUpperCase(),
                        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: AppColors.primaryPink),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Section: Tentang Alat Ini
                    buildSectionHeader('TENTANG ALAT INI'),
                    const SizedBox(height: 6),
                    buildInfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline, color: AppColors.primaryPink, size: 20),
                              SizedBox(width: 8),
                              Text('Apa yang diukur?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(data["tentang"], style: const TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.4)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section: Rentang Normal
                    buildSectionHeader('RENTANG NORMAL'),
                    const SizedBox(height: 6),
                    // Card Pria
                    buildInfoCard(child: _buildCardGender(data, isPria: true)),
                    const SizedBox(height: 10),
                    // Card Wanita
                    buildInfoCard(child: _buildCardGender(data, isPria: false)),
                    const SizedBox(height: 16),

                    // Section: Tips Pengukuran
                    buildSectionHeader('TIPS PENGUKURAN'),
                    const SizedBox(height: 6),
                    buildInfoCard(
                      child: Column(
                        children: List.generate((data["tips"] as List).length, (index) {
                          final tip = data["tips"][index];
                          return Column(
                            children: [
                              buildTipsRow(icon: tip["icon"], text: tip["text"]),
                              if (index < (data["tips"] as List).length - 1)
                                const Divider(height: 20, thickness: 1, color: Color(0xFFF0F0F0)),
                            ],
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card rentang normal untuk satu gender (pria/wanita)
  Widget _buildCardGender(Map<String, dynamic> data, {required bool isPria}) {
    final prefix = isPria ? 'pria' : 'wanita';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(isPria ? Icons.male : Icons.female, color: AppColors.primaryPink, size: 22),
            const SizedBox(width: 6),
            Text(isPria ? 'Pria' : 'Wanita', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
        const SizedBox(height: 8),
        Text(data["${prefix}_desc"], style: const TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.4)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: buildStatusIndicatorBox(
                icon: Icons.check,
                title: data["${prefix}_status1"]["title"],
                value: data["${prefix}_status1"]["value"],
                isAlert: data["${prefix}_status1"]["isAlert"],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: buildStatusIndicatorBox(
                icon: Icons.error_outline,
                title: data["${prefix}_status2"]["title"],
                value: data["${prefix}_status2"]["value"],
                isAlert: data["${prefix}_status2"]["isAlert"],
              ),
            ),
          ],
        ),
      ],
    );
  }
}