import '../models/device_model.dart';

// ── DATA STATUS BATERAI ALAT (Untuk Dokumen Induk Alat) ──
//Map<String, int> bateraiAlatDummy = {
//  'Tensimeter': 85,
//  'Heart Rate Monitor': 92,
//  'Oximeter': 74,
//  'Termometer': 60,
//};

// ── Tensimeter ──
List<RiwayatModel> daftarRiwayatTensimeter = [
  RiwayatModel(
    namaAlat: 'Tensimeter',
    sistol: '120 mmHg',
    diastol: '80 mmHg',
    denyutJantung: '72 bpm',
    waktu: '22 Mei 2026, 14:30',
  ),
  RiwayatModel(
    namaAlat: 'Tensimeter',
    sistol: '118 mmHg',
    diastol: '78 mmHg',
    denyutJantung: '68 bpm',
    waktu: '22 Mei 2026, 07:33',
  ),
  RiwayatModel(
    namaAlat: 'Tensimeter',
    sistol: '122 mmHg',
    diastol: '82 mmHg',
    denyutJantung: '75 bpm',
    waktu: '05 Mei 2026, 23:00',
  ),
  RiwayatModel(
    namaAlat: 'Tensimeter',
    sistol: '115 mmHg',
    diastol: '76 mmHg',
    denyutJantung: '70 bpm',
    waktu: '05 Mei 2026, 09:20',
  ),
];

RiwayatModel riwayatTerbaruTensimeter = daftarRiwayatTensimeter.first;

// ── Heart Rate Monitor ──
List<HeartRateModel> daftarRiwayatHeartRate = [
  HeartRateModel(
    namaAlat: 'Heart Rate Monitor',
    bpm: '88 bpm',
    status: 'Normal',
    waktu: '22 Mei 2026, 14:45',
  ),
  HeartRateModel(
    namaAlat: 'Heart Rate Monitor',
    bpm: '102 bpm',
    status: 'Tinggi',
    waktu: '22 Mei 2026, 08:10',
  ),
  HeartRateModel(
    namaAlat: 'Heart Rate Monitor',
    bpm: '76 bpm',
    status: 'Normal',
    waktu: '05 Mei 2026, 20:00',
  ),
  HeartRateModel(
    namaAlat: 'Heart Rate Monitor',
    bpm: '91 bpm',
    status: 'Normal',
    waktu: '05 Mei 2026, 09:30',
  ),
];

HeartRateModel riwayatTerbaruHeartRate = daftarRiwayatHeartRate.first;

// ── Oximeter ──
List<OximeterModel> daftarRiwayatOximeter = [
  OximeterModel(
    namaAlat: 'Oximeter',
    saturasi: '98%',
    bpm: '80 bpm',
    statusSaturasi: 'Normal',
    waktu: '22 Mei 2026, 15:00',
  ),
  OximeterModel(
    namaAlat: 'Oximeter',
    saturasi: '96%',
    bpm: '85 bpm',
    statusSaturasi: 'Normal',
    waktu: '22 Mei 2026, 07:45',
  ),
  OximeterModel(
    namaAlat: 'Oximeter',
    saturasi: '94%',
    bpm: '92 bpm',
    statusSaturasi: 'Perhatikan',
    waktu: '05 Mei 2026, 22:15',
  ),
  OximeterModel(
    namaAlat: 'Oximeter',
    saturasi: '97%',
    bpm: '78 bpm',
    statusSaturasi: 'Normal',
    waktu: '05 Mei 2026, 10:00',
  )
];

OximeterModel riwayatTerbaruOximeter = daftarRiwayatOximeter.first;

// ── Termometer ──
List<ThermometerModel> daftarRiwayatTermometer = [
  ThermometerModel(
    namaAlat: 'Termometer',
    suhu: '36.8°C',
    statusSuhu: 'Normal',
    waktu: '22 Mei 2026, 15:10',
  ),
  ThermometerModel(
    namaAlat: 'Termometer',
    suhu: '38.2°C',
    statusSuhu: 'Demam',
    waktu: '22 Mei 2026, 06:50',
  ),
  ThermometerModel(
    namaAlat: 'Termometer',
    suhu: '37.1°C',
    statusSuhu: 'Normal',
    waktu: '05 Mei 2026, 21:30',
  ),
  ThermometerModel(
    namaAlat: 'Termometer',
    suhu: '36.5°C',
    statusSuhu: 'Normal',
    waktu: '05 Mei 2026, 08:00',
  ),
];

ThermometerModel riwayatTerbaruTermometer = daftarRiwayatTermometer.first;