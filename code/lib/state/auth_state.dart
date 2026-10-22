class AuthState {
  static final AuthState _instance = AuthState._internal();
  factory AuthState() => _instance;
  AuthState._internal();

  final List<Map<String, String>> _daftarAkun = [];
  Map<String, String>? akunAktif;

  void daftarAkun(Map<String, String> dataAkun) {
    _daftarAkun.add(dataAkun);
  }

  Map<String, String>? cekLogin(String email, String password) {
    for (final akun in _daftarAkun) {
      if (akun['email'] == email && akun['password'] == password) {
        return akun;
      }
    }
    return null;
  }

  bool emailSudahTerdaftar(String email) {
    return _daftarAkun.any((akun) => akun['email'] == email);
  }

  // Logout → hapus akun aktif
  void logout() {
    akunAktif = null;
  }

  // Getter data profil dari akun aktif
  String get nama => akunAktif?['nama'] ?? '-';
  String get email => akunAktif?['email'] ?? '-';
  String get usia => akunAktif?['usia'] ?? '-';
  String get jenisKelamin => akunAktif?['jenisKelamin'] ?? '-';
  String get telepon => akunAktif?['telepon'] ?? '-';

  // Format jenis kelamin untuk ditampilkan
  String get jenisKelaminLabel {
    if (jenisKelamin == 'laki') return 'Laki-laki';
    if (jenisKelamin == 'perempuan') return 'Perempuan';
    return '-';
  }
}