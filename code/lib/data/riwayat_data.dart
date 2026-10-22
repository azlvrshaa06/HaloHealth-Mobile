import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/device_model.dart';

// Struktur Firestore:
// users/{uid}/alat/{namaAlat}/riwayat/  ← hasil scan
// users/{uid}/alat/{namaAlat}/          ← field 'baterai'

class HealthService {
  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get currentUid => _auth.currentUser?.uid ?? '';

  // Helper: sub-collection riwayat per alat
  CollectionReference _riwayatRef(String namaAlat) =>
      _db.collection('users').doc(currentUid).collection('alat').doc(namaAlat).collection('riwayat');

  // Helper: dokumen alat (untuk field baterai dll)
  DocumentReference _alatRef(String namaAlat) =>
      _db.collection('users').doc(currentUid).collection('alat').doc(namaAlat);

  // Simpan riwayat Tensimeter
  Future<void> simpanRiwayatTensimeter(RiwayatModel d) async {
    if (currentUid.isEmpty) return;
    await _riwayatRef(d.namaAlat).add({
      'sistol': d.sistol, 'diastol': d.diastol,
      'denyutJantung': d.denyutJantung, 'waktu': FieldValue.serverTimestamp(),
    });
  }

  // Simpan riwayat Heart Rate Monitor
  Future<void> simpanRiwayatHeartRate(HeartRateModel d) async {
    if (currentUid.isEmpty) return;
    await _riwayatRef(d.namaAlat).add({
      'bpm': d.bpm, 'status': d.status, 'waktu': FieldValue.serverTimestamp(),
    });
  }

  // Simpan riwayat Oximeter
  Future<void> simpanRiwayatOximeter(OximeterModel d) async {
    if (currentUid.isEmpty) return;
    await _riwayatRef(d.namaAlat).add({
      'saturasi': d.saturasi, 'bpm': d.bpm,
      'statusSaturasi': d.statusSaturasi, 'waktu': FieldValue.serverTimestamp(),
    });
  }

  // Simpan riwayat Termometer
  Future<void> simpanRiwayatTermometer(ThermometerModel d) async {
    if (currentUid.isEmpty) return;
    await _riwayatRef(d.namaAlat).add({
      'suhu': d.suhu, 'statusSuhu': d.statusSuhu, 'waktu': FieldValue.serverTimestamp(),
    });
  }

  // Update level baterai alat (merge agar field lain tidak tertimpa)
  Future<void> updateBaterai(String namaAlat, int persen) async {
    if (currentUid.isEmpty) return;
    await _alatRef(namaAlat).set({'baterai': persen.clamp(0, 100)}, SetOptions(merge: true));
  }

  // Upload semua dummy data sekaligus (untuk testing)
  Future<void> uploadSemuaDummyData() => Future.wait([
    for (var i in daftarRiwayatTensimeter)  simpanRiwayatTensimeter(i),
    for (var i in daftarRiwayatHeartRate)   simpanRiwayatHeartRate(i),
    for (var i in daftarRiwayatOximeter)    simpanRiwayatOximeter(i),
    for (var i in daftarRiwayatTermometer)  simpanRiwayatTermometer(i),
  ]);

  // Upload dummy baterai semua alat (untuk testing)
  Future<void> uploadDummyBaterai() => Future.wait([
    updateBaterai('Tensimeter', 85),
    updateBaterai('Heart Rate Monitor', 60),
    updateBaterai('Oximeter', 45),
    updateBaterai('Termometer', 15),
  ]);
}

// ── DATA DUMMY ──

List<RiwayatModel> daftarRiwayatTensimeter = [
  RiwayatModel(namaAlat: 'Tensimeter', sistol: '120', diastol: '80', denyutJantung: '72', waktu: '22 Mei 2026, 14:30'),
  RiwayatModel(namaAlat: 'Tensimeter', sistol: '118', diastol: '78', denyutJantung: '68', waktu: '22 Mei 2026, 07:33'),
];

List<HeartRateModel> daftarRiwayatHeartRate = [
  HeartRateModel(namaAlat: 'Heart Rate Monitor', bpm: '88', status: 'Normal', waktu: '22 Mei 2026, 14:45'),
];

List<OximeterModel> daftarRiwayatOximeter = [
  OximeterModel(namaAlat: 'Oximeter', saturasi: '98', bpm: '80', statusSaturasi: 'Normal', waktu: '22 Mei 2026, 15:00'),
];

List<ThermometerModel> daftarRiwayatTermometer = [
  ThermometerModel(namaAlat: 'Termometer', suhu: '36.8', statusSuhu: 'Normal', waktu: '22 Mei 2026, 15:10'),
];