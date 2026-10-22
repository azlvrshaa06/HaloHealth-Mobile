import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../services/dialog_service.dart';
import '../widgets/kitbox_button_widget.dart';
import '../widgets/riwayat_card_widget.dart';
import '../widgets/device_card_widget.dart';
import '../screens/device_desc.dart';
import 'riwayat_screen.dart';
import 'doctor_list_screen.dart';
import '../state/auth_state.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _ctrlRiwayat;
  late final PageController _ctrlAlat;

  bool _kitBoxAktif      = false;
  int  _idxRiwayat       = 0;
  int  _idxAlat          = 0;
  final _scaffoldKey     = GlobalKey<ScaffoldState>();

  static const _listAlat = ['Tensimeter', 'Heart Rate Monitor', 'Oximeter', 'Termometer'];

  @override
  void initState() {
    super.initState();
    _ctrlRiwayat = PageController();
    _ctrlAlat    = PageController();
  }

  @override
  void dispose() {
    _ctrlRiwayat.dispose(); _ctrlAlat.dispose();
    super.dispose();
  }

  // Toggle kit box dengan dialog konfirmasi
  void _handleKitBox() async {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) Navigator.pop(context);
    if (!_kitBoxAktif) {
      final ok = await DialogService.tampilkanDialogBuka(context);
      if (ok == true) setState(() => _kitBoxAktif = true);
    } else {
      final ok = await DialogService.tampilkanDialogKunci(context);
      if (ok == true) setState(() => _kitBoxAktif = false);
    }
  }

  // Navigasi ke carousel berikutnya (wrap ke 0)
  void _navigasiCarousel(PageController ctrl, int idx) {
    ctrl.animateToPage(
      idx < 3 ? idx + 1 : 0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  // Upload dummy data ke Firestore (untuk testing)
  Future<void> _kirimDataDummyLangsung() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal: Kamu belum login / UID tidak ditemukan!')));
      return;
    }

    // Helper shortcut
    CollectionReference riwayatRef(String nama) => FirebaseFirestore.instance
        .collection('users').doc(uid).collection('alat').doc(nama).collection('riwayat');
    DocumentReference alatRef(String nama) => FirebaseFirestore.instance
        .collection('users').doc(uid).collection('alat').doc(nama);

    try {
      await Future.wait([
        riwayatRef('Tensimeter').add({'sistol': 118, 'diastol': 79, 'denyutJantung': 72, 'waktu': FieldValue.serverTimestamp()}),
        riwayatRef('Oximeter').add({'saturasi': 99, 'bpm': 74, 'statusSaturasi': 'Normal', 'waktu': FieldValue.serverTimestamp()}),
        riwayatRef('Termometer').add({'suhu': 36.6, 'statusSuhu': 'Normal', 'waktu': FieldValue.serverTimestamp()}),
        riwayatRef('Heart Rate Monitor').add({'bpm': 80, 'status': 'Normal', 'waktu': FieldValue.serverTimestamp()}),
        //alatRef('Tensimeter').set({'baterai': 85}, SetOptions(merge: true)),
        //alatRef('Oximeter').set({'baterai': 45}, SetOptions(merge: true)),
        //alatRef('Termometer').set({'baterai': 15}, SetOptions(merge: true)),
        //alatRef('Heart Rate Monitor').set({'baterai': 60}, SetOptions(merge: true)),
      ]);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Berhasil menulis dummy data!'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: _buildDrawer(),
      body: Column(children: [
        _buildHeader(),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Tombol Chat dengan Dokter
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorListScreen())),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E8C), borderRadius: BorderRadius.circular(18)),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.chat_bubble_outline, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text('Chat dengan Dokter',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
            const SizedBox(height: 20),

            // Section Riwayat
            const Text('Riwayat',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF111111))),
            const SizedBox(height: 12),
            _buildSectionRiwayat(),
            const SizedBox(height: 20),

            // Section Alat Kesehatan
            const Text('Alat Kesehatan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF111111))),
            const SizedBox(height: 12),
            _buildSectionAlat(),
            const SizedBox(height: 16),
          ]),
        )),
      ]),
    );
  }

  // Drawer navigasi: profil, kit box, dummy data, logout
  Widget _buildDrawer() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user     = FirebaseAuth.instance.currentUser?..reload();
        final nama     = (user?.displayName?.isNotEmpty == true) ? user!.displayName! : 'Pengguna Baru';
        final email    = user?.email ?? 'Tidak ada email';

        return Drawer(
          backgroundColor: const Color(0xFFF5F5F5),
          child: Column(children: [

            // Header profil (tap → ProfileScreen)
            GestureDetector(
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())); },
              child: Container(
                width: double.infinity,
                color: const Color(0xFFE91E8C),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 24,
                  bottom: 28, left: 24, right: 24,
                ),
                child: Row(children: [
                  Container(
                    width: 56, height: 56,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    child: const Icon(Icons.person, color: Color(0xFFE91E8C), size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Profil Saya', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(nama, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(email, style: const TextStyle(color: Colors.white60, fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                  ])),
                  const Icon(Icons.chevron_right, color: Colors.white60, size: 22),
                ]),
              ),
            ),

            // Tombol Kit Box
            Expanded(child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Perangkat',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: Color(0xFF888888), letterSpacing: 0.5)),
                const SizedBox(height: 12),
                KitBoxButtonWidget(isActive: _kitBoxAktif, onTap: _handleKitBox),
              ]),
            )),

            // Tombol Dummy Data (sementara/testing)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: GestureDetector(
                onTap: _kirimDataDummyLangsung,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE7F3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFBCFE8)),
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.playlist_add, color: Color(0xFFDB2777), size: 18),
                    SizedBox(width: 8),
                    Text('Buat Sub-Koleksi Dummy',
                      style: TextStyle(color: Color(0xFFDB2777), fontSize: 14, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ),

            // Tombol Logout
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: GestureDetector(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  AuthState().logout();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
                  },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 18),
                    SizedBox(width: 8),
                    Text('Keluar', style: TextStyle(
                      color: Color(0xFFDC2626), fontSize: 14, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  // Header atas: hamburger menu + logo
  Widget _buildHeader() => Container(
    color: Colors.white,
    padding: EdgeInsets.only(
      top: MediaQuery.of(context).padding.top + 12,
      bottom: 12, left: 20, right: 20,
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      GestureDetector(
        onTap: () => _scaffoldKey.currentState?.openDrawer(),
        child: const Icon(Icons.menu, color: Color(0xFF333333), size: 26)),
      const Text('HaloHealth',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFFE91E8C))),
    ]),
  );

  // Carousel riwayat pengukuran (per alat)
  Widget _buildSectionRiwayat() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return const Center(child: Text('Silakan login kembali'));
    return _buildCarousel(
      height: 260, controller: _ctrlRiwayat,
      currentIndex: _idxRiwayat,
      onPageChanged: (i) => setState(() => _idxRiwayat = i),
      onPanah: () => _navigasiCarousel(_ctrlRiwayat, _idxRiwayat),
      children: _listAlat.map((nama) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: RiwayatCardWidget(
          namaAlat: nama,
          onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => RiwayatScreen(namaAlat: nama))),
        ),
      )).toList(),
    );
  }

  // Carousel alat kesehatan (baterai realtime dari Firestore)
  Widget _buildSectionAlat() => _buildCarousel(
    height: 210, controller: _ctrlAlat,
    currentIndex: _idxAlat,
    onPageChanged: (i) => setState(() => _idxAlat = i),
    onPanah: () => _navigasiCarousel(_ctrlAlat, _idxAlat),
    children: _listAlat.asMap().entries.map((e) => Padding(
      padding: EdgeInsets.only(
        left: e.key > 0 ? 4 : 0,
        right: e.key < _listAlat.length - 1 ? 4 : 0,
      ),
      child: DeviceCardWidget(
        nama: e.value,
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => DeviceDesc(deviceName: e.value))),
      ),
    )).toList(),
  );

  // Carousel generik: PageView + indikator dot + tombol panah
  Widget _buildCarousel({
    required double height,
    required PageController controller,
    required int currentIndex,
    required ValueChanged<int> onPageChanged,
    required VoidCallback onPanah,
    required List<Widget> children,
  }) {
    return RawGestureDetector(
      // Prioritaskan swipe horizontal ke PageView, bukan ke parent ScrollView
      gestures: {
        HorizontalDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
          () => HorizontalDragGestureRecognizer(), (i) {}),
      },
      behavior: HitTestBehavior.opaque,
      child: Stack(children: [
        SizedBox(
          height: height,
          // Absorb scroll notification agar tidak bubble ke parent ScrollView
          child: NotificationListener<ScrollNotification>(
            onNotification: (_) => true,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
              child: PageView(
                controller: controller,
                onPageChanged: onPageChanged,
                physics: const ClampingScrollPhysics(),
                children: children,
              ),
            ),
          ),
        ),

        // Tombol panah next/prev
        Positioned(
          top: 16, right: 16,
          child: GestureDetector(
            onTap: onPanah,
            child: Container(
              width: 38, height: 38,
              decoration: const BoxDecoration(color: Color(0xFFFCE4EC), shape: BoxShape.circle),
              child: Icon(
                currentIndex < children.length - 1 ? Icons.chevron_right : Icons.chevron_left,
                color: const Color(0xFFE91E8C), size: 22),
            ),
          ),
        ),

        // Dot indikator
        Positioned(
          bottom: 12, left: 0, right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(children.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: currentIndex == i ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: currentIndex == i ? const Color(0xFFE91E8C) : const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(3)),
            )),
          ),
        ),
      ]),
    );
  }
}