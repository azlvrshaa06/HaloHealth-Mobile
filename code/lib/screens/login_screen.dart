
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _tabIndex = 0;

  // ── Controller Login ──────────────────────────────────────
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  bool _loginPasswordVisible = false;
  String? _errorLoginEmail;
  String? _errorLoginPassword;
  String? _errorLoginUmum;

  // ── Controller Register ───────────────────────────────────
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usiaController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _kodeKitController = TextEditingController();
  bool _registerPasswordVisible = false;
  String _jenisKelamin = '';
  String? _errorNama, _errorEmail, _errorUsia, _errorJenisKelamin, _errorTelepon, _errorPassword, _errorKodeKit;


  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _namaController.dispose();
    _emailController.dispose();
    _usiaController.dispose();
    _teleponController.dispose();
    _passwordController.dispose();
    _kodeKitController.dispose();
    super.dispose();
  }

  // Reset semua field & error form register
  void _resetRegister() {
    _namaController.clear();
    _emailController.clear();
    _usiaController.clear();
    _teleponController.clear();
    _passwordController.clear();
    _kodeKitController.clear();
    _jenisKelamin = '';
    _errorNama = _errorEmail = _errorUsia = _errorJenisKelamin =
        _errorTelepon = _errorPassword = _errorKodeKit = null;
    _registerPasswordVisible = false;
  }

  // Reset semua field & error form login
  void _resetLogin() {
    _loginEmailController.clear();
    _loginPasswordController.clear();
    _loginPasswordVisible = false;
    _errorLoginEmail = _errorLoginPassword = _errorLoginUmum = null;
  }

  // Ganti tab dan reset form tab yang ditinggalkan
  void _gantiTab(int index) {
    setState(() {
      index == 1 ? _resetLogin() : _resetRegister();
      _tabIndex = index;
    });
  }

  
  // ── PROSES REGISTER FIREBASE ───────────────────────────────────
Future<void> _prosesRegister() async {
  // Reset semua error dulu
  setState(() {
    _errorNama = _errorEmail = _errorUsia = _errorJenisKelamin =
        _errorTelepon = _errorPassword = _errorKodeKit = null;
  });

  final email = _emailController.text.trim();
  final password = _passwordController.text;

  // Kumpulkan semua error dulu, baru setState sekali
  String? errNama, errEmail, errUsia, errJK, errTelepon, errPass, errKit;
  bool valid = true;

  if (_namaController.text.trim().isEmpty) {
    errNama = 'Nama lengkap wajib diisi'; valid = false;
  }
  if (email.isEmpty) {
    errEmail = 'Email wajib diisi'; valid = false;
  } else if (!email.contains('@') || !email.contains('.')) {
    errEmail = 'Format email tidak valid'; valid = false;
  }
  if (_usiaController.text.trim().isEmpty) {
    errUsia = 'Usia wajib diisi'; valid = false;
  } else if (int.tryParse(_usiaController.text.trim()) == null) {
    errUsia = 'Usia harus berupa angka'; valid = false;
  }
  if (_jenisKelamin.isEmpty) {
    errJK = 'Pilih jenis kelamin'; valid = false;
  }
  if (_teleponController.text.trim().isEmpty) {
    errTelepon = 'Nomor telepon wajib diisi'; valid = false;
  }
  if (password.isEmpty || password.length < 6) {
    errPass = 'Kata sandi minimal 6 karakter'; valid = false;
  }
  if (_kodeKitController.text.trim().isEmpty) {
    errKit = 'Kode kit wajib diisi'; valid = false;
  }

  // Tampilkan semua error sekaligus
  if (!valid) {
    setState(() {
      _errorNama = errNama;
      _errorEmail = errEmail;
      _errorUsia = errUsia;
      _errorJenisKelamin = errJK;
      _errorTelepon = errTelepon;
      _errorPassword = errPass;
      _errorKodeKit = errKit;
    });
    return; 
  }

  // Lanjut ke Firebase IF ONLY  semua valid
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    final String uid = userCredential.user!.uid;
    FirebaseFirestore ff = FirebaseFirestore.instance;

    UserModel newUser = UserModel(
      uid: uid,
      nama: _namaController.text.trim(),
      email: email,
      usia: int.tryParse(_usiaController.text.trim()) ?? 0,
      jenisKelamin: _jenisKelamin,
      telepon: _teleponController.text.trim(),
      kodeKit: _kodeKitController.text.trim(),
      createdAt: null,
    );

    await ff.collection('users').doc(uid).set(UserModel.toMap(newUser));

    //updates the name on display for home screen and profile display
    await userCredential.user!.updateDisplayName(_namaController.text.trim());

    if (mounted) {
      _resetRegister();
      setState(() => _tabIndex = 0); // Pindah ke tab Masuk
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun berhasil dibuat! Silakan masuk 🎉'),
          backgroundColor: Color(0xFFE91E8C),
        ),
      );
    }
  } on FirebaseAuthException catch (e) {
    setState(() {
      if (e.code == 'email-already-in-use') {
        _errorEmail = 'Email ini sudah terdaftar';
      } else if (e.code == 'weak-password') {
        _errorPassword = 'Kata sandi terlalu lemah';
      } else {
        _errorNama = 'Gagal mendaftar: ${e.message}';
      }
    });
  } catch (e) {
    setState(() {
      _errorNama = 'Terjadi kesalahan: $e';
    });
  }
}

// ── PROSES LOGIN FIREBASE AUTHENTICATION ────────────────────
  Future<void> _prosesLogin() async {
    setState(() {
      _errorLoginEmail = _errorLoginPassword = _errorLoginUmum = null;
    });

    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;
    bool valid = true;

    // 1. Validasi Input Lokal
    if (email.isEmpty) {
      setState(() => _errorLoginEmail = 'Email wajib diisi');
      valid = false;
    } else if (!email.contains('@') || !email.contains('.')) {
      setState(() => _errorLoginEmail = 'Format email tidak valid');
      valid = false;
    }
    
    if (password.isEmpty) {
      setState(() => _errorLoginPassword = 'Kata sandi wajib diisi');
      valid = false;
    }
    
    if (!valid) return;

    try {
      // 2. Kirim kredensial ke Firebase Authentication
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 3. Jika berhasil, pindah ke HomeScreen dan hapus tumpukan halaman lama
      if (mounted) {
        _resetLogin();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // 4. Tangani error spesifik dari Firebase Auth
      setState(() {
        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          _errorLoginUmum = 'Email belum terdaftar atau kata sandi salah.';
        } else if (e.code == 'too-many-requests') {
          _errorLoginUmum = 'Terlalu banyak percobaan login yang gagal. Silakan coba lagi nanti.';
        } else {
          _errorLoginUmum = 'Gagal masuk: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _errorLoginUmum = 'Terjadi kesalahan sistem saat mencoba login.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Text('HaloHealth', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Color(0xFFE91E8C), letterSpacing: 0.5)),
              const SizedBox(height: 8),
              const Text('Kesehatan kamu, prioritas kami', style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
              const SizedBox(height: 40),
              // Tab Masuk / Daftar
              Row(children: [_buildTab('Masuk', 0), _buildTab('Daftar', 1)]),
              const SizedBox(height: 32),
              _tabIndex == 0 ? _buildLogin() : _buildRegister(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

//*----WIDGETS -------------------------------------------------

  Widget _buildTab(String label, int index) {
    final aktif = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _gantiTab(index),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: aktif ? FontWeight.w700 : FontWeight.w400, color: aktif ? const Color(0xFFE91E8C) : const Color(0xFFAAAAAA)),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 3,
              decoration: BoxDecoration(
                color: aktif ? const Color(0xFFE91E8C) : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Form Login ─────────────────────────────────────────────
  Widget _buildLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputKotak(controller: _loginEmailController, label: 'Email', icon: Icons.email_outlined, tipeKeyboard: TextInputType.emailAddress, errorText: _errorLoginEmail, onChanged: (_) => setState(() => _errorLoginEmail = null)),
        const SizedBox(height: 14),
        _buildInputKotak(controller: _loginPasswordController, label: 'Kata Sandi', icon: Icons.lock_outline, isPassword: true, passwordVisible: _loginPasswordVisible, onTogglePassword: () => setState(() => _loginPasswordVisible = !_loginPasswordVisible), errorText: _errorLoginPassword, onChanged: (_) => setState(() => _errorLoginPassword = null)),
        const SizedBox(height: 10),
        if (_errorLoginUmum != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(_errorLoginUmum!, style: const TextStyle(color: Color(0xFFE53935), fontSize: 12), textAlign: TextAlign.center),
          ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _prosesLogin,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(color: const Color(0xFFE91E8C), borderRadius: BorderRadius.circular(50)),
            child: const Center(child: Text('Masuk', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))),
          ),
        ),
      ],
    );
  }

  // ── Form Register ──────────────────────────────────────────
  Widget _buildRegister() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputGaris(controller: _namaController, label: 'Nama Lengkap', icon: Icons.person_outline, errorText: _errorNama, onChanged: (_) => setState(() => _errorNama = null)),
        const SizedBox(height: 16),
        _buildInputGaris(controller: _emailController, label: 'Email', icon: Icons.email_outlined, tipeKeyboard: TextInputType.emailAddress, errorText: _errorEmail, onChanged: (_) => setState(() => _errorEmail = null)),
        const SizedBox(height: 16),
        _buildInputGaris(controller: _usiaController, label: 'Usia', icon: Icons.cake_outlined, tipeKeyboard: TextInputType.number, errorText: _errorUsia, onChanged: (_) => setState(() => _errorUsia = null)),
        const SizedBox(height: 20),
        const Text('Jenis Kelamin', style: TextStyle(fontSize: 13, color: Color(0xFF888888), fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        _buildRadioOption('Laki-laki', 'laki'),
        const SizedBox(height: 10),
        _buildRadioOption('Perempuan', 'perempuan'),
        if (_errorJenisKelamin != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_errorJenisKelamin!, style: const TextStyle(color: Color(0xFFE53935), fontSize: 12)),
          ),
        const SizedBox(height: 16),
        _buildInputGaris(controller: _teleponController, label: 'Nomor Telepon', icon: Icons.phone_outlined, tipeKeyboard: TextInputType.phone, errorText: _errorTelepon, onChanged: (_) => setState(() => _errorTelepon = null)),
        const SizedBox(height: 16),
        _buildInputGaris(controller: _passwordController, label: 'Kata Sandi', icon: Icons.lock_outline, isPassword: true, passwordVisible: _registerPasswordVisible, onTogglePassword: () => setState(() => _registerPasswordVisible = !_registerPasswordVisible), errorText: _errorPassword, onChanged: (_) => setState(() => _errorPassword = null)),
        const SizedBox(height: 16),
        _buildInputGaris(controller: _kodeKitController, label: 'Kode Kit', icon: Icons.qr_code_outlined, errorText: _errorKodeKit, onChanged: (_) => setState(() => _errorKodeKit = null)),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: _prosesRegister,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(color: const Color(0xFFE91E8C), borderRadius: BorderRadius.circular(50)),
            child: const Center(child: Text('Buat Akun', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))),
          ),
        ),
      ],
    );
  }

  // Radio button jenis kelamin
  Widget _buildRadioOption(String label, String nilai) {
    final dipilih = _jenisKelamin == nilai;
    return GestureDetector(
      onTap: () => setState(() { _jenisKelamin = nilai; _errorJenisKelamin = null; }),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: dipilih ? const Color(0xFFE91E8C) : const Color(0xFFAAAAAA), width: 2),
              color: dipilih ? const Color(0xFFE91E8C) : Colors.transparent,
            ),
            child: dipilih ? const Icon(Icons.check, color: Colors.white, size: 12) : null,
          ),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF333333))),
        ],
      ),
    );
  }

  // Input field kotak (digunakan di form Login)
  Widget _buildInputKotak({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool passwordVisible = false,
    VoidCallback? onTogglePassword,
    TextInputType tipeKeyboard = TextInputType.text,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: errorText != null ? Border.all(color: const Color(0xFFE53935), width: 1.5) : null,
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !passwordVisible,
            keyboardType: tipeKeyboard,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFFAAAAAA), size: 20),
              labelText: label,
              labelStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: isPassword
                  ? GestureDetector(
                      onTap: onTogglePassword,
                      child: Icon(passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFFAAAAAA), size: 20),
                    )
                  : null,
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(errorText, style: const TextStyle(color: Color(0xFFE53935), fontSize: 12)),
          ),
      ],
    );
  }

  // Input field bergaris bawah (digunakan di form Register)
  Widget _buildInputGaris({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool passwordVisible = false,
    VoidCallback? onTogglePassword,
    TextInputType tipeKeyboard = TextInputType.text,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    final errorColor = errorText != null ? const Color(0xFFE53935) : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: isPassword && !passwordVisible,
          keyboardType: tipeKeyboard,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: errorColor ?? const Color(0xFFAAAAAA), size: 20),
            labelText: label,
            labelStyle: TextStyle(color: errorColor ?? const Color(0xFFAAAAAA), fontSize: 14),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: errorColor ?? const Color(0xFFDDDDDD), width: 1.5)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: errorColor ?? const Color(0xFFE91E8C), width: 2)),
            suffixIcon: isPassword
                ? GestureDetector(
                    onTap: onTogglePassword,
                    child: Icon(passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFFAAAAAA), size: 20),
                  )
                : null,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(errorText, style: const TextStyle(color: Color(0xFFE53935), fontSize: 12)),
          ),
      ],
    );
  }
}