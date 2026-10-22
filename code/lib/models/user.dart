import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String nama;
  String email;
  int usia;
  String jenisKelamin;
  String telepon;
  String kodeKit;
  Timestamp? createdAt; // Gunakan Timestamp dari package Firestore

 
  UserModel({
    required this.uid,
    required this.nama,
    required this.email,
    required this.usia,
    required this.jenisKelamin,
    required this.telepon,
    required this.kodeKit,
    this.createdAt,
  });

  // 2. toMap (Mengubah objek User menjadi Map sebelum dikirim ke Firestore)
  static Map<String, dynamic> toMap(UserModel user) {
    return {
      'uid': user.uid,
      'nama': user.nama,
      'email': user.email,
      'usia': user.usia,
      'jenisKelamin': user.jenisKelamin,
      'telepon': user.telepon,
      'kodeKit': user.kodeKit,
      'createdAt': user.createdAt ?? FieldValue.serverTimestamp(), 
    };
  }

  // 3. fromMap / Factory (Mengubah Map dari Firestore menjadi objek User di Flutter)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      nama: map['nama'] ?? '',
      email: map['email'] ?? '',
      usia: map['usia'] ?? 0,
      jenisKelamin: map['jenisKelamin'] ?? '',
      telepon: map['telepon'] ?? '',
      kodeKit: map['kodeKit'] ?? '',
      createdAt: map['createdAt'] as Timestamp?,
    );
  }
}