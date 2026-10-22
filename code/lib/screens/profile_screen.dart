import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  
  // State manajemen mode edit
  bool _isEditing = false;
  bool _isLoading = false;
  bool _hasInitializedControllers = false;

  // Controller untuk form edit data
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _usiaController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _usiaController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

  // Fungsi untuk menyimpan perubahan ke Cloud Firestore
  Future<void> _simpanPerubahan() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Update data tambahan di dokumen Firestore 'users' berdasarkan UID
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .update({
        'nama': _namaController.text.trim(),
        'usia': int.tryParse(_usiaController.text.trim()) ?? 0,
        'telepon': _teleponController.text.trim(),
      });

      // 2. Sinkronisasikan nama ke properti bawaan Firebase Auth Display Name
      await _currentUser.updateDisplayName(_namaController.text.trim());

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil kamu berhasil diperbarui! ✨'),
            backgroundColor: Color(0xFFE91E8C),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Pengguna tidak ditemukan. Silakan login kembali.')),
      );
    }

    // Menggunakan StreamBuilder di tingkat paling atas agar data memantau Firestore secara real-time
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(_currentUser.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFFE91E8C))),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Gagal memuat data profil atau dokumen tidak ditemukan.')),
          );
        }

        // Memetakan data dari dokumen Firestore
        UserModel userProfil = UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

        // Inisialisasi teks awal pada controller saat pertama kali masuk ke mode edit
        if (!_hasInitializedControllers) {
          _namaController.text = userProfil.nama;
          _usiaController.text = userProfil.usia.toString();
          _teleponController.text = userProfil.telepon;
          _hasInitializedControllers = true;
}

        String labelGender = (userProfil.jenisKelamin == 'laki') ? 'Laki-laki' : 'Perempuan';

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Avatar + Nama Utama + Email Bawaan Auth
                      Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFCE4EC)),
                              child: const Icon(Icons.person, color: Color(0xFFE91E8C), size: 44),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              userProfil.nama.isEmpty ? 'Tanpa Nama' : userProfil.nama,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF111111)),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userProfil.email,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF888888)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Card Data Profil & Form Input Mode
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Informasi Pribadi',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF888888), letterSpacing: 0.5),
                                  ),
                                  if (!_isEditing)
                                    GestureDetector(
                                      onTap: () => setState(() => _isEditing = true),
                                      child: const Text(
                                        'Ubah Profil',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFE91E8C)),
                                      ),
                                    )
                                ],
                              ),
                            ),
                            _buildKomponenBaris(
                              icon: Icons.person_outline,
                              label: 'Nama Lengkap',
                              nilai: userProfil.nama,
                              isEditable: _isEditing,
                              controller: _namaController,
                            ),
                            _buildDivider(),
                            _buildKomponenBaris(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              nilai: userProfil.email,
                              isEditable: false,
                            ),
                            _buildDivider(),
                            _buildKomponenBaris(
                              icon: Icons.cake_outlined,
                              label: 'Usia',
                              nilai: '${userProfil.usia} tahun',
                              isEditable: _isEditing,
                              controller: _usiaController,
                              keyboardType: TextInputType.number,
                            ),
                            _buildDivider(),
                            _buildKomponenBaris(
                              icon: Icons.wc_outlined,
                              label: 'Jenis Kelamin',
                              nilai: labelGender,
                              isEditable: false,
                            ),
                            _buildDivider(),
                            _buildKomponenBaris(
                              icon: Icons.phone_outlined,
                              label: 'Nomor Telepon',
                              nilai: userProfil.telepon,
                              isEditable: _isEditing,
                              controller: _teleponController,
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tombol Simpan / Batal (Hanya muncul jika dalam mode edit)
                      if (_isEditing)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isLoading ? null : () => setState(() => _isEditing = false),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFE91E8C)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                                  ),
                                  child: const Text('Batal', style: TextStyle(color: Color(0xFFE91E8C), fontWeight: FontWeight.w700)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _simpanPerubahan,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE91E8C),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
          const Text('HaloHealth', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFFE91E8C))),
        ],
      ),
    );
  }

  Widget _buildKomponenBaris({
    required IconData icon,
    required String label,
    required String nilai,
    required bool isEditable,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(color: Color(0xFFFCE4EC), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFFE91E8C), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: isEditable && controller != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: 36,
                        child: TextField(
                          controller: controller,
                          keyboardType: keyboardType,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF111111), fontWeight: FontWeight.w500),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                            isDense: true,
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE91E8C))),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFDDDDDD))),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                      const SizedBox(height: 3),
                      Text(nilai, style: const TextStyle(fontSize: 15, color: Color(0xFF111111), fontWeight: FontWeight.w500)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 68),
      child: Divider(height: 0, thickness: 0.5, color: Color(0xFFF0F0F0)),
    );
  }
}