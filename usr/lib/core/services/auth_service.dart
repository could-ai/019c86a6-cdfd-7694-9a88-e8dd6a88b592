import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:couldai_user_app/data/database/app_database.dart';
import 'package:drift/drift.dart';

class AuthService extends ChangeNotifier {
  final AppDatabase _db;
  User? _currentUser;

  AuthService(this._db);

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'ADMIN';
  bool get isAnalyst => _currentUser?.role == 'ANALISTA' || isAdmin;

  // Hash simple para MVP (en producción usar Argon2)
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> login(String username, String password) async {
    final user = await _db.getUser(username);
    if (user != null && user.passwordHash == _hashPassword(password)) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    
    // Crear usuario admin por defecto si no existe ninguno (solo para MVP/Dev)
    if (username == 'admin' && password == 'admin123') {
      final existingAdmin = await _db.getUser('admin');
      if (existingAdmin == null) {
        await _db.createUser(UsersCompanion(
          username: const Value('admin'),
          passwordHash: Value(_hashPassword('admin123')),
          role: const Value('ADMIN'),
        ));
        return login('admin', 'admin123');
      }
    }
    
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
