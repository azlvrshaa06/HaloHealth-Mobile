// =============================================================
// FITUR: Screen daftar dokter untuk konsultasi
// Fitur: search by nama / spesialisasi, tap Konsultasi → ChatScreen
// Navigasi dari: HomeScreen (tombol "Chat dengan Dokter")
// =============================================================

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../data/dummy_doctors.dart';
import '../widgets/doctor_card_widget.dart';
import 'chat_screen.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    _filteredDoctors = List<Map<String, dynamic>>.from(dummyDoctors);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter list dokter berdasarkan nama atau spesialisasi 
  void _filterDoctors(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDoctors = List<Map<String, dynamic>>.from(dummyDoctors);
      } else {
        final q = query.toLowerCase();
        _filteredDoctors = dummyDoctors.where((doctor) {
          final name = (doctor['name'] ?? '').toString().toLowerCase();
          final speciality = (doctor['speciality'] ?? '').toString().toLowerCase();
          return name.contains(q) || speciality.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('Chat dengan Dokter', style: TextStyle(fontSize: 18, color: AppColors.textDark, fontWeight: FontWeight.bold)),
                  const Text('HaloHealth', style: TextStyle(fontSize: 18, color: AppColors.primaryPink, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: _filterDoctors,
                style: const TextStyle(color: AppColors.textDark, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search doctors, specialties...',
                  hintStyle: const TextStyle(color: Color(0xFF7B8794)),
                  prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF7B8794)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.accentBlue),
                          onPressed: () {
                            _searchController.clear();
                            _filterDoctors('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // List dokter
            Expanded(
              child: _filteredDoctors.isEmpty
                  ? const Center(child: Text('No doctors found', style: TextStyle(color: AppColors.textDark)))
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: _filteredDoctors.length,
                      itemBuilder: (context, index) {
                        final doctor = _filteredDoctors[index];
                        return DoctorCardWidget(
                          name: doctor['name'] ?? 'Unknown Doctor',
                          speciality: doctor['speciality'] ?? 'General',
                          icon: doctor['icon'] ?? Icons.person_rounded,
                          // Hanya dokter pertama yang bisa dikonsultasi
                            onKonsultasi: doctor['name'] == dummyDoctors.first['name']
                              ? () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        doctorName: doctor['name'],
                                        doctorIcon: doctor['icon'],
                                      ),
                                    ),
                                  )
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}