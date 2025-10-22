import 'package:shared_preferences/shared_preferences.dart';
import 'auth_roles.dart';

class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  /// Limpa todos os caches do aplicativo
  static Future<void> clearAllCaches() async {
    try {
      // 1. Limpar cache de roles
      RoleService.clearAllCaches();

      // 2. Limpar SharedPreferences (exceto configurações importantes)
      final prefs = await SharedPreferences.getInstance();

      // Lista de chaves que devem ser mantidas
      const keysToKeep = [
        'notifications_enabled', // Configuração de notificações
        'themeModeKey', // Tema do app
      ];

      // Obter todas as chaves
      final keys = prefs.getKeys();

      // Remover apenas as chaves que não estão na lista de manter
      for (String key in keys) {
        if (!keysToKeep.contains(key)) {
          await prefs.remove(key);
        }
      }

      print('✅ Cache limpo com sucesso');
    } catch (e) {
      print('❌ Erro ao limpar cache: $e');
    }
  }

  /// Limpa apenas o cache de roles
  static void clearRoleCache() {
    RoleService.clearAllCaches();
    print('✅ Cache de roles limpo');
  }

  /// Limpa apenas o SharedPreferences (exceto configurações importantes)
  static Future<void> clearSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      const keysToKeep = ['notifications_enabled', 'themeModeKey'];

      final keys = prefs.getKeys();

      for (String key in keys) {
        if (!keysToKeep.contains(key)) {
          await prefs.remove(key);
        }
      }

      print('✅ SharedPreferences limpo');
    } catch (e) {
      print('❌ Erro ao limpar SharedPreferences: $e');
    }
  }

  /// Força refresh de todos os dados
  static Future<void> forceRefresh() async {
    await clearAllCaches();
    print('🔄 Dados atualizados - cache limpo');
  }
}
