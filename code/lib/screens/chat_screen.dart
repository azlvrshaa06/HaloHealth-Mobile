

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/colors.dart';
import '../state/chat_state.dart';

class ChatMessage {
  final String? text;
  final bool isRiwayat;
  final String? namaAlatRiwayat;
  final DateTime waktu;
  // snapshotData sudah di-fetch saat kirim — bubble tidak perlu query ulang
  final Map<String, dynamic>? snapshotData;

  ChatMessage({
    this.text,
    this.isRiwayat = false,
    this.namaAlatRiwayat,
    required this.waktu,
    this.snapshotData,
  });
}

class ChatScreen extends StatefulWidget {
  final String doctorName;
  final IconData doctorIcon;

  const ChatScreen({super.key, required this.doctorName, required this.doctorIcon});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _showPilihRiwayat = false;
  bool _isSendingRiwayat = false; // loading state saat fetch Firestore

  bool _tensimeterDipilih = false;
  bool _heartRateDipilih = false;
  bool _oximeterDipilih = false;
  bool _termometerDipilih = false;

  bool get _adaYangDipilih =>
      _tensimeterDipilih || _heartRateDipilih || _oximeterDipilih || _termometerDipilih;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollKeBottom());
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollKeBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _kirimPesan() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    Provider.of<ChatState>(context, listen: false).tambahPesan(
      widget.doctorName,
      ChatMessage(text: text, waktu: DateTime.now()),
    );
    _textController.clear();
    _scrollKeBottom();
  }

  void _pilihDevice(String device) {
    setState(() {
      _tensimeterDipilih = device == 'Tensimeter' ? !_tensimeterDipilih : false;
      _heartRateDipilih = device == 'Heart Rate Monitor' ? !_heartRateDipilih : false;
      _oximeterDipilih = device == 'Oximeter' ? !_oximeterDipilih : false;
      _termometerDipilih = device == 'Termometer' ? !_termometerDipilih : false;
    });
  }

  // Async — fetch data dari Firestore dulu, baru tambah ke chat
  Future<void> _kirimRiwayat() async {
    if (!_adaYangDipilih || _isSendingRiwayat) return;

    setState(() => _isSendingRiwayat = true);

    await Provider.of<ChatState>(context, listen: false).kirimRiwayatAlat(
      doctorName: widget.doctorName,
      tensimeter: _tensimeterDipilih,
      heartRate: _heartRateDipilih,
      oximeter: _oximeterDipilih,
      termometer: _termometerDipilih,
    );

    if (mounted) {
      setState(() {
        _isSendingRiwayat = false;
        _showPilihRiwayat = false;
        _tensimeterDipilih = _heartRateDipilih = _oximeterDipilih = _termometerDipilih = false;
      });
      _scrollKeBottom();
    }
  }

  String _formatJam(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final messages = context.watch<ChatState>().messagesFor(widget.doctorName);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return msg.isRiwayat
                      ? _buildBubbleRiwayat(msg)
                      : _buildBubbleTeks(msg);
                },
              ),
            ),
            _buildPanelBawah(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Color(0xFF222222), size: 24),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: Color(0xFFE8EBFD), shape: BoxShape.circle),
            child: Icon(widget.doctorIcon, color: AppColors.primaryPink, size: 22),
          ),
          const SizedBox(width: 10),
          Text(widget.doctorName,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111111))),
        ],
      ),
    );
  }

  Widget _buildBubbleTeks(ChatMessage msg) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, left: 60),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          color: AppColors.primaryPink,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(msg.text ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_formatJam(msg.waktu),
                    style: const TextStyle(color: Colors.white70, fontSize: 10)),
                const SizedBox(width: 4),
                const Icon(Icons.done_all, color: Colors.white70, size: 13),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Bubble riwayat — render langsung dari snapshotData, tidak ada StreamBuilder
  Widget _buildBubbleRiwayat(ChatMessage msg) {
    final namaAlat = msg.namaAlatRiwayat ?? '';
    final data = msg.snapshotData;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, left: 40),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
          border: Border.all(color: const Color(0xFFF48FB1), width: 1.5),
        ),
        child: data == null
            // Tidak ada data di Firestore untuk alat ini
            ? _buildBubbleKosong(namaAlat)
            : _buildBubbleIsi(namaAlat, data, msg.waktu),
      ),
    );
  }

  Widget _buildBubbleKosong(String namaAlat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBubbleHeader(namaAlat),
        const SizedBox(height: 10),
        Text(
          'Belum ada data $namaAlat yang tersimpan.',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildBubbleIsi(String namaAlat, Map<String, dynamic> data, DateTime waktu) {
    final baris = _getBarisDariDevice(namaAlat, data);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBubbleHeader(namaAlat),
        const SizedBox(height: 10),
        const Divider(height: 0, thickness: 0.5, color: Color(0xFFF0F0F0)),
        ...baris.asMap().entries.map((entry) => _buildRiwayatRow(
              entry.value['label']!,
              entry.value['nilai']!,
              isLast: entry.key == baris.length - 1,
            )),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(_formatJam(waktu),
                style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 10)),
            const SizedBox(width: 4),
            const Icon(Icons.done_all, color: Color(0xFF90CAF9), size: 13),
          ],
        ),
      ],
    );
  }

  Widget _buildBubbleHeader(String namaAlat) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(color: Color(0xFFDBEAFE), shape: BoxShape.circle),
          child: const Icon(Icons.monitor_heart_outlined, color: Color(0xFF2563EB), size: 18),
        ),
        const SizedBox(width: 10),
        Text(namaAlat,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111111))),
      ],
    );
  }

  // Mapping data Firestore → baris label-nilai untuk ditampilkan di bubble
  List<Map<String, String>> _getBarisDariDevice(
      String namaAlat, Map<String, dynamic> data) {
    String formatWaktu = '-';
    if (data['waktu'] is Timestamp) {
      final date = (data['waktu'] as Timestamp).toDate();
      formatWaktu =
          "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year} "
          "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } else if (data['waktu'] is String) {
      formatWaktu = data['waktu'];
    }

    switch (namaAlat) {
      case 'Tensimeter':
        return [
          {'label': 'Sistol', 'nilai': '${data['sistol'] ?? '-'} mmHg'},
          {'label': 'Diastol', 'nilai': '${data['diastol'] ?? '-'} mmHg'},
          {'label': 'Denyut Jantung', 'nilai': '${data['denyutJantung'] ?? '-'} bpm'},
          {'label': 'Waktu', 'nilai': formatWaktu},
        ];
      case 'Heart Rate Monitor':
        return [
          {'label': 'Detak Jantung', 'nilai': '${data['bpm'] ?? '-'} bpm'},
          {'label': 'Status', 'nilai': (data['status'] ?? '-').toString()},
          {'label': 'Waktu', 'nilai': formatWaktu},
        ];
      case 'Oximeter':
        return [
          {'label': 'Saturasi Oksigen (SpO₂)', 'nilai': '${data['saturasi'] ?? '-'}%'},
          {'label': 'Detak Jantung', 'nilai': '${data['bpm'] ?? '-'} bpm'},
          {'label': 'Status', 'nilai': (data['statusSaturasi'] ?? '-').toString()},
          {'label': 'Waktu', 'nilai': formatWaktu},
        ];
      case 'Termometer':
        return [
          {'label': 'Suhu Tubuh', 'nilai': '${data['suhu'] ?? '-'}°C'},
          {'label': 'Status', 'nilai': (data['statusSuhu'] ?? '-').toString()},
          {'label': 'Waktu', 'nilai': formatWaktu},
        ];
      default:
        return [];
    }
  }

  Widget _buildRiwayatRow(String label, String nilai, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
              Text(nilai,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF222222))),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 0, thickness: 0.5, color: Color(0xFFF0F0F0)),
      ],
    );
  }

  Widget _buildPanelBawah() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 0, thickness: 0.5, color: Color(0xFFEEEEEE)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPink.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.primaryPink.withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'Halo, selamat datang di ruang konsultasi.\nMari mulai konsultasi Anda',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF333333), height: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Kirim riwayat Anda',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF333333))),
                          GestureDetector(
                            onTap: () {
                              if (_showPilihRiwayat) {
                                _kirimRiwayat();
                              } else {
                                setState(() => _showPilihRiwayat = true);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: (_showPilihRiwayat && !_adaYangDipilih)
                                    ? const Color(0xFFDDDDDD)
                                    : AppColors.primaryPink,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              // Tampilkan loading spinner kecil saat sedang fetch Firestore
                              child: _isSendingRiwayat
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _showPilihRiwayat
                                          ? 'Kirim Sekarang'
                                          : 'Kirim',
                                      style: TextStyle(
                                        color: (_showPilihRiwayat &&
                                                !_adaYangDipilih)
                                            ? const Color(0xFF888888)
                                            : Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      if (_showPilihRiwayat) ...[
                        const SizedBox(height: 10),
                        const Divider(height: 0, thickness: 0.5),
                        const SizedBox(height: 10),
                        _buildPilihanDevice('Tensimeter', _tensimeterDipilih),
                        const SizedBox(height: 8),
                        _buildPilihanDevice('Heart Rate Monitor', _heartRateDipilih),
                        const SizedBox(height: 8),
                        _buildPilihanDevice('Oximeter', _oximeterDipilih),
                        const SizedBox(height: 8),
                        _buildPilihanDevice('Termometer', _termometerDipilih),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _kirimPesan(),
                        decoration: InputDecoration(
                          hintText: 'Ketik pesan...',
                          hintStyle: const TextStyle(
                              color: Color(0xFFAAAAAA), fontSize: 14),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _kirimPesan,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                            color: AppColors.primaryPink, shape: BoxShape.circle),
                        child: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPilihanDevice(String namaDevice, bool dipilih) {
    return GestureDetector(
      onTap: _isSendingRiwayat ? null : () => _pilihDevice(namaDevice),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: dipilih
                      ? AppColors.primaryPink
                      : const Color(0xFFAAAAAA),
                  width: 2),
              color: dipilih ? AppColors.primaryPink : Colors.transparent,
            ),
            child: dipilih
                ? const Icon(Icons.check, color: Colors.white, size: 12)
                : null,
          ),
          const SizedBox(width: 10),
          Text(namaDevice,
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}