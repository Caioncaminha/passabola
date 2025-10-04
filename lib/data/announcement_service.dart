import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnnouncementService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _announcementsCollection = _firestore
      .collection('avisos');

  /// Cria um novo aviso
  static Future<String> createAnnouncement({
    required String title,
    required String message,
    bool isActive = true,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final docRef = await _announcementsCollection.add({
        'title': title.trim(),
        'message': message.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': isActive,
        'createdBy': user.uid,
        'createdByName': user.displayName ?? 'Admin',
      });

      print('DEBUG: Aviso criado com ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('DEBUG: Erro ao criar aviso: $e');
      throw Exception('Erro ao criar aviso: $e');
    }
  }

  /// Busca todos os avisos ativos
  static Future<List<Map<String, dynamic>>> getActiveAnnouncements() async {
    try {
      final querySnapshot = await _announcementsCollection
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final announcements = <Map<String, dynamic>>[];
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        announcements.add({
          'id': doc.id,
          'title': data['title'] ?? 'Sem título',
          'message': data['message'] ?? 'Sem mensagem',
          'createdAt': data['createdAt']?.toDate(),
          'updatedAt': data['updatedAt']?.toDate(),
          'isActive': data['isActive'] ?? true,
          'createdBy': data['createdBy'] ?? 'Desconhecido',
          'createdByName': data['createdByName'] ?? 'Admin',
        });
      }

      print('DEBUG: Avisos ativos encontrados: ${announcements.length}');
      return announcements;
    } catch (e) {
      print('DEBUG: Erro ao buscar avisos: $e');
      throw Exception('Erro ao buscar avisos: $e');
    }
  }

  /// Busca todos os avisos (para administração)
  static Future<List<Map<String, dynamic>>> getAllAnnouncements() async {
    try {
      final querySnapshot = await _announcementsCollection
          .orderBy('createdAt', descending: true)
          .get();

      final announcements = <Map<String, dynamic>>[];
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        announcements.add({
          'id': doc.id,
          'title': data['title'] ?? 'Sem título',
          'message': data['message'] ?? 'Sem mensagem',
          'createdAt': data['createdAt']?.toDate(),
          'updatedAt': data['updatedAt']?.toDate(),
          'isActive': data['isActive'] ?? true,
          'createdBy': data['createdBy'] ?? 'Desconhecido',
          'createdByName': data['createdByName'] ?? 'Admin',
        });
      }

      print('DEBUG: Total de avisos encontrados: ${announcements.length}');
      return announcements;
    } catch (e) {
      print('DEBUG: Erro ao buscar todos os avisos: $e');
      throw Exception('Erro ao buscar avisos: $e');
    }
  }

  /// Atualiza um aviso
  static Future<void> updateAnnouncement({
    required String announcementId,
    String? title,
    String? message,
    bool? isActive,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (title != null) updateData['title'] = title.trim();
      if (message != null) updateData['message'] = message.trim();
      if (isActive != null) updateData['isActive'] = isActive;

      await _announcementsCollection.doc(announcementId).update(updateData);
      print('DEBUG: Aviso $announcementId atualizado com sucesso');
    } catch (e) {
      print('DEBUG: Erro ao atualizar aviso: $e');
      throw Exception('Erro ao atualizar aviso: $e');
    }
  }

  /// Deleta um aviso
  static Future<void> deleteAnnouncement(String announcementId) async {
    try {
      await _announcementsCollection.doc(announcementId).delete();
      print('DEBUG: Aviso $announcementId deletado com sucesso');
    } catch (e) {
      print('DEBUG: Erro ao deletar aviso: $e');
      throw Exception('Erro ao deletar aviso: $e');
    }
  }

  /// Ativa/desativa um aviso
  static Future<void> toggleAnnouncementStatus(
    String announcementId,
    bool isActive,
  ) async {
    try {
      await _announcementsCollection.doc(announcementId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print(
        'DEBUG: Status do aviso $announcementId alterado para ${isActive ? 'ativo' : 'inativo'}',
      );
    } catch (e) {
      print('DEBUG: Erro ao alterar status do aviso: $e');
      throw Exception('Erro ao alterar status do aviso: $e');
    }
  }
}
