import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserRole { admin, usuario, olheiro }

class RoleService {
  static final RoleService _instance = RoleService._internal();
  factory RoleService() => _instance;
  RoleService._internal();

  UserRole? _cachedRole;

  Future<UserRole> getCurrentUserRole() async {
    if (_cachedRole != null) return _cachedRole!;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _cachedRole = UserRole.usuario;
      return _cachedRole!;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      final data = doc.data() ?? {};
      final String roleStr =
          (data['role'] as String?)?.toLowerCase() ?? 'usuario';
      _cachedRole = _fromString(roleStr);
      return _cachedRole!;
    } catch (_) {
      _cachedRole = UserRole.usuario;
      return _cachedRole!;
    }
  }

  void clearCache() {
    _cachedRole = null;
  }

  // Método estático para limpar cache globalmente
  static void clearAllCaches() {
    _instance.clearCache();
  }

  UserRole _fromString(String value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'olheiro':
        return UserRole.olheiro;
      case 'usuario':
      default:
        return UserRole.usuario;
    }
  }
}
