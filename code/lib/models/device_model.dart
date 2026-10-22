// Model untuk menyimpan data riwayat alat kesehatan
class RiwayatModel {
  final String namaAlat;
  final String sistol;       // khusus tensimeter
  final String diastol;      // khusus tensimeter
  final String denyutJantung;
  final String waktu;

  RiwayatModel({
    required this.namaAlat,
    required this.sistol,
    required this.diastol,
    required this.denyutJantung,
    required this.waktu,
  });
}

// Model untuk menyimpan data Termometer
class ThermometerModel {
  final String namaAlat;
  final String suhu;
  final String statusSuhu;   // Normal / Demam Ringan / Demam
  final String waktu;

  ThermometerModel({
    required this.namaAlat,
    required this.suhu,
    required this.statusSuhu,
    required this.waktu,
  });
}

class HeartRateModel {
  final String namaAlat;
  final String bpm;
  final String status;
  final String waktu;

  HeartRateModel({
    required this.namaAlat,
    required this.bpm,
    required this.status,
    required this.waktu,
  });
}

class OximeterModel {
  final String namaAlat;
  final String saturasi;     // saturasi oksigen SpO2
  final String bpm;          // detak jantung
  final String statusSaturasi;
  final String waktu;

  OximeterModel({
    required this.namaAlat,
    required this.saturasi,
    required this.bpm,
    required this.statusSaturasi,
    required this.waktu,
  });
}