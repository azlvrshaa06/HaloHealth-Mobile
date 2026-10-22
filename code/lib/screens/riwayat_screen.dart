// =============================================================
// FITUR: Screen daftar riwayat pengukuran per alat kesehatan
// Menerima namaAlat → menampilkan list riwayat dari Firestore
// Navigasi dari: HomeScreen (tap card riwayat)
// =============================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Struktur data internal untuk menampung baris informasi yang akan ditampilkan
class CardRowData {
  final String label;
  final String nilai;

  CardRowData({required this.label, required this.nilai});
}

class RiwayatScreen extends StatefulWidget {
  final String namaAlat;

  const RiwayatScreen({super.key, required this.namaAlat});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  Stream<QuerySnapshot>? _stream;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isNotEmpty) {
      // Stream mengambil seluruh data dari sub-koleksi 'riwayat' sesuai alat yang dipilih
      _stream = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('alat')
          .doc(widget.namaAlat)
          .collection('riwayat')
          .snapshots();
    }
  }

  // Mapping dokumen Firestore ke List<CardRowData> secara dinamis beserta satuannya
  List<CardRowData> _mapFirestoreToRows(String alat, Map<String, dynamic> data) {
    String formatWaktu = '-';
    if (data['waktu'] != null) {
      if (data['waktu'] is Timestamp) {
        final date = (data['waktu'] as Timestamp).toDate();
        formatWaktu =
            "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year} "
            "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
      } else if (data['waktu'] is String) {
        formatWaktu = data['waktu'];
      }
    }

    switch (alat) {
      case 'Tensimeter':
        return [
          CardRowData(label: 'Sistol', nilai: "${data['sistol'] ?? '-'} mmHg"),
          CardRowData(label: 'Diastol', nilai: "${data['diastol'] ?? '-'} mmHg"),
          CardRowData(label: 'Denyut Jantung', nilai: "${data['denyutJantung'] ?? '-'} bpm"),
          CardRowData(label: 'Waktu', nilai: formatWaktu),
        ];
      case 'Heart Rate Monitor':
        return [
          CardRowData(label: 'Detak Jantung', nilai: "${data['bpm'] ?? '-'} bpm"),
          CardRowData(label: 'Status', nilai: (data['status'] ?? '-').toString()),
          CardRowData(label: 'Waktu', nilai: formatWaktu),
        ];
      case 'Oximeter':
        return [
          CardRowData(label: 'Saturasi Oksigen (SpO₂)', nilai: "${data['saturasi'] ?? '-'}%"),
          CardRowData(label: 'Detak Jantung', nilai: "${data['bpm'] ?? '-'} bpm"),
          CardRowData(label: 'Status', nilai: (data['statusSaturasi'] ?? '-').toString()),
          CardRowData(label: 'Waktu', nilai: formatWaktu),
        ];
      case 'Termometer':
        return [
          CardRowData(label: 'Suhu Tubuh', nilai: "${data['suhu'] ?? '-'}°C"),
          CardRowData(label: 'Status', nilai: (data['statusSuhu'] ?? '-').toString()),
          CardRowData(label: 'Waktu', nilai: formatWaktu),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Riwayat ${widget.namaAlat} Anda',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF111111)),
            ),
          ),
          Expanded(
            child: _stream == null
                ? const Center(child: Text('Silakan login kembali', style: TextStyle(color: Color(0xFF888888))))
                : StreamBuilder<QuerySnapshot>(
                    stream: _stream,
                    builder: (context, snapshot) {
                      // 1. Loading State
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Color(0xFFE91E8C)),
                        );
                      }

                      // 2. Error State
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                          ),
                        );
                      }

                      // 3. Empty State
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('Data riwayat tidak tersedia', style: TextStyle(color: Color(0xFF888888))),
                        );
                      }

                      // 4. Sort Client-Side (Mengurutkan berdasarkan timestamp 'waktu' terbaru)
                      final docs = snapshot.data!.docs.toList()
                        ..sort((a, b) {
                          final aData = a.data() as Map<String, dynamic>;
                          final bData = b.data() as Map<String, dynamic>;
                          final aWaktu = aData['waktu'];
                          final bWaktu = bData['waktu'];
                          if (aWaktu is Timestamp && bWaktu is Timestamp) {
                            return bWaktu.compareTo(aWaktu); // Descending (terbaru di atas)
                          }
                          return 0;
                        });

                      // 5. Main List Builder
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final firestoreData = docs[index].data() as Map<String, dynamic>;
                          final List<CardRowData> rows = _mapFirestoreToRows(widget.namaAlat, firestoreData);

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: rows.asMap().entries.map((entry) {
                                final isLast = entry.key == rows.length - 1;
                                return _buildDataRow(entry.value.label, entry.value.nilai, isLast: isLast);
                              }).toList(),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 12,
        left: 16,
        right: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Color(0xFF222222), size: 24),
          ),
          const Text(
            'HaloHealth',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFFE91E8C)),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String nilai, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Color(0xFF888888)),
              ),
              Text(
                nilai,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF222222),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 0, thickness: 0.5, color: Color(0xFFF0F0F0)),
      ],
    );
  }
}