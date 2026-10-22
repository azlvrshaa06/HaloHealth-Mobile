import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/colors.dart';

// DeviceCardWidget — otomatis listen realtime ke:
// users/{uid}/alat/{namaAlat}  →  field: baterai (int 0–100)
class DeviceCardWidget extends StatefulWidget {
  final String nama;
  final VoidCallback? onTap;

  const DeviceCardWidget({
    super.key,
    required this.nama,
    this.onTap,
  });

  @override
  State<DeviceCardWidget> createState() => _DeviceCardWidgetState();
}

class _DeviceCardWidgetState extends State<DeviceCardWidget> {
  Stream<DocumentSnapshot>? _stream;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isNotEmpty) {
      // Listen ke dokumen alat — field 'baterai' akan update realtime
      // Struktur: users/{uid}/alat/{namaAlat}
      _stream = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('alat')
          .doc(widget.nama)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_stream == null) {
      return _buildCard(persenBaterai: 0, isLoading: false);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCard(persenBaterai: 0, isLoading: true);
        }

        // Dokumen belum ada di Firestore (alat belum pernah terhubung)
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildCard(persenBaterai: 0, isLoading: false);
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final int baterai = (data['baterai'] as num?)?.toInt() ?? 0;

        return _buildCard(persenBaterai: baterai, isLoading: false);
      },
    );
  }

  Widget _buildCard({required int persenBaterai, required bool isLoading}) {
    final double nilaiBaterai = persenBaterai.clamp(0, 100) / 100.0;
    final bool bateraiRendah = persenBaterai <= 20;

    // Warna bar baterai: merah kalau ≤20%, pink kalau >20%
    final Color warnaBaterai =
        bateraiRendah ? const Color(0xFFEF4444) : AppColors.primaryPink;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: icon + nama alat ──────────────────────────
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDBEAFE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.monitor_heart_outlined,
                    color: Color(0xFF2563EB),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.nama,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            
            const SizedBox(height: 16),

            // ── Label baterai ─────────────────────────────────────
            const Text(
              'LEVEL BATERAI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B8794),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),

            // ── Progress bar + persentase ─────────────────────────
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: isLoading
                        ? LinearProgressIndicator(
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryPink.withOpacity(0.4),
                            ),
                            minHeight: 10,
                          )
                        : LinearProgressIndicator(
                            value: nilaiBaterai,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(warnaBaterai),
                            minHeight: 10,
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                isLoading
                    ? const SizedBox(
                        width: 32,
                        height: 14,
                        child: LinearProgressIndicator(
                          backgroundColor: Color(0xFFE2E8F0),
                        ),
                      )
                    : Text(
                        '$persenBaterai%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: bateraiRendah
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF0E1B2A),
                        ),
                      ),
              ],
            ),

            // ── Peringatan baterai rendah ─────────────────────────
            if (!isLoading && bateraiRendah && persenBaterai > 0) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 14, color: Color(0xFFEF4444)),
                  const SizedBox(width: 4),
                  Text(
                    'Baterai hampir habis',
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 14),
            
          ],
        ),
      ),
    );
  }

  VoidCallback? get onTap => widget.onTap;
}