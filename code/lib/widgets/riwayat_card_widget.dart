import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CardRowData {
  final String label;
  final String nilai;

  CardRowData({required this.label, required this.nilai});
}

// Widget card riwayat reusable yang otomatis sync ke Firestore berdasarkan nama alat.
// Menggunakan StatefulWidget agar stream Firestore hanya dibuat SEKALI di initState,
// so no terjadi re-subscribe (dan loading spinner ) setiap kali parent rebuild.
class RiwayatCardWidget extends StatefulWidget {
  final String namaAlat;
  final VoidCallback? onTap;

  const RiwayatCardWidget({
    super.key,
    required this.namaAlat, this.onTap
  });

  @override
  State<RiwayatCardWidget> createState() => _RiwayatCardWidgetState();
}

class _RiwayatCardWidgetState extends State<RiwayatCardWidget> {
  Stream<QuerySnapshot>? _stream;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isNotEmpty) {
      // Path baru: users/{uid}/alat/{namaAlat}/riwayat
      // Tidak pakai .orderBy() agar tidak butuh Composite Index — sort di client-side.
      _stream = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('alat')
          .doc(widget.namaAlat)
          .collection('riwayat')
          .snapshots();
    }
  }

  // Memetakan dokumen Firestore ke List<CardRowData> secara dinamis.
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
    // Guard: uid kosong berarti belum login
    if (_stream == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Silakan login kembali'),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(child: CircularProgressIndicator(color: Color(0xFFE91E8C))),
          );
        }

        // Error state — tampilkan pesan error agar tidak silent
        if (snapshot.hasError) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          );
        }

        // Empty state
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(16),
            child: Text(
              'Belum ada riwayat pemeriksaan untuk ${widget.namaAlat}.',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          );
        }

        // Sort client-side by waktu descending, ambil yang paling baru
        final docs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aWaktu = aData['waktu'];
            final bWaktu = bData['waktu'];
            if (aWaktu is Timestamp && bWaktu is Timestamp) {
              return bWaktu.compareTo(aWaktu); // descending
            }
            return 0;
          });

        final Map<String, dynamic> firestoreData =
            docs.first.data() as Map<String, dynamic>;
        final List<CardRowData> rows = _mapFirestoreToRows(widget.namaAlat, firestoreData);

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
             decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header: icon + nama alat
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
                  const SizedBox(width: 12),
                  Text(
                    widget.namaAlat,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Baris-baris data dari Firestore
              ...rows.asMap().entries.map((entry) {
                final isLast = entry.key == rows.length - 1;
                return _buildDataRow(entry.value.label, entry.value.nilai, isLast: isLast);
              }),
            ],
          ),
          )
        );
      },
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