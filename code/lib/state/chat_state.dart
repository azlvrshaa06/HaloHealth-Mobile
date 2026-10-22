import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/chat_screen.dart';

class ChatState extends ChangeNotifier {
  final Map<String, List<ChatMessage>> _chatMap = {};

  List<ChatMessage> messagesFor(String doctorName) {
    return _chatMap[doctorName] ?? [];
  }

  void tambahPesan(String doctorName, ChatMessage message) {
    _chatMap.putIfAbsent(doctorName, () => []);
    _chatMap[doctorName]!.add(message);
    notifyListeners();
  }

  // Fetch data terbaru dari Firestore path baru: users/{uid}/alat/{namaAlat}/riwayat
  // lalu simpan snapshotData-nya ke dalam ChatMessage agar bubble tidak perlu re-fetch
  Future<void> kirimRiwayatAlat({
    required String doctorName,
    required bool tensimeter,
    required bool heartRate,
    required bool oximeter,
    required bool termometer,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    final sekarang = DateTime.now();
    _chatMap.putIfAbsent(doctorName, () => []);

    // Kumpulkan semua alat yang dipilih
    final Map<String, bool> pilihanAlat = {
      'Tensimeter': tensimeter,
      'Heart Rate Monitor': heartRate,
      'Oximeter': oximeter,
      'Termometer': termometer,
    };

    // Fetch semua alat yang dipilih secara paralel
    final futures = pilihanAlat.entries
        .where((e) => e.value)
        .map((e) => _fetchRiwayatTerbaru(uid, e.key));

    final results = await Future.wait(futures);

    // Tambahkan pesan untuk setiap alat yang berhasil di-fetch
    final alatDipilih = pilihanAlat.entries.where((e) => e.value).toList();
    for (int i = 0; i < alatDipilih.length; i++) {
      _chatMap[doctorName]!.add(ChatMessage(
        isRiwayat: true,
        namaAlatRiwayat: alatDipilih[i].key,
        waktu: sekarang,
        snapshotData: results[i], // bisa null kalau belum ada data
      ));
    }

    notifyListeners();
  }

  // Ambil 1 dokumen terbaru dari sub-collection riwayat, sort client-side
  // agar tidak butuh Composite Index di Firestore
  Future<Map<String, dynamic>?> _fetchRiwayatTerbaru(String uid, String namaAlat) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('alat')
          .doc(namaAlat)
          .collection('riwayat')
          .get();

      if (snapshot.docs.isEmpty) return null;

      // Sort client-side by waktu descending, ambil yang paling baru
      final docs = snapshot.docs.toList()
        ..sort((a, b) {
          final aWaktu = (a.data())['waktu'];
          final bWaktu = (b.data())['waktu'];
          if (aWaktu is Timestamp && bWaktu is Timestamp) {
            return bWaktu.compareTo(aWaktu);
          }
          return 0;
        });

      return docs.first.data();
    } catch (e) {
      debugPrint('Error fetch riwayat $namaAlat: $e');
      return null;
    }
  }
}