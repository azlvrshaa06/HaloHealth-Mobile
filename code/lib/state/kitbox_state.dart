import 'package:flutter/material.dart';

// State sederhana untuk menyimpan status kit box (aktif/tidak)
class KitBoxState extends ChangeNotifier {
  bool _isActive = false;

  bool get isActive => _isActive;

  void aktivasiKitBox() {
    _isActive = true;
    notifyListeners();
  }

  void kunciKitBox() {
    _isActive = false;
    notifyListeners();
  }
}