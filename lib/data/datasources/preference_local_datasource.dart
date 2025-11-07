import 'package:hive/hive.dart';
import 'package:kl_teams/core/errors/exceptions.dart';
import 'package:kl_teams/data/models/preference_model.dart';
import 'package:uuid/uuid.dart';

abstract class PreferenceLocalDataSource {
  Future<List<PreferenceModel>> getAllPreferences();
  Future<PreferenceModel> getPreferenceById(String id);
  Future<PreferenceModel> savePreference(PreferenceModel preference);
  Future<PreferenceModel> updatePreference(PreferenceModel preference);
  Future<void> deletePreference(String id);
  Future<bool> preferenceExistsForTeam(int teamId);
}

class PreferenceLocalDataSourceImpl implements PreferenceLocalDataSource {
  static const String _boxName = 'preferences';
  final Uuid _uuid = const Uuid();

  Future<Box<PreferenceModel>> _openBox() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        return await Hive.openBox<PreferenceModel>(_boxName);
      }
      return Hive.box<PreferenceModel>(_boxName);
    } catch (e) {
      throw CacheException('Error al abrir la base de datos: ${e.toString()}');
    }
  }

  @override
  Future<List<PreferenceModel>> getAllPreferences() async {
    try {
      final box = await _openBox();
      return box.values.toList();
    } catch (e) {
      throw CacheException('Error al obtener preferencias: ${e.toString()}');
    }
  }

  @override
  Future<PreferenceModel> getPreferenceById(String id) async {
    try {
      final box = await _openBox();
      final preference = box.get(id);

      if (preference == null) {
        throw CacheException('Preferencia no encontrada');
      }

      return preference;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Error al obtener preferencia: ${e.toString()}');
    }
  }

  @override
  Future<PreferenceModel> savePreference(PreferenceModel preference) async {
    try {
      final box = await _openBox();

      final exists = await preferenceExistsForTeam(preference.teamId);
      if (exists) {
        throw CacheException('Ya existe una preferencia para este equipo');
      }

      final id = preference.id.isEmpty ? _uuid.v4() : preference.id;

      final newPreference = PreferenceModel(
        id: id,
        teamId: preference.teamId,
        teamName: preference.teamName,
        customName: preference.customName,
        logoUrl: preference.logoUrl,
        city: preference.city,
        country: preference.country,
        createdAt: preference.createdAt,
        updatedAt: preference.updatedAt,
      );

      await box.put(id, newPreference);
      return newPreference;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Error al guardar preferencia: ${e.toString()}');
    }
  }

  @override
  Future<PreferenceModel> updatePreference(PreferenceModel preference) async {
    try {
      final box = await _openBox();

      if (!box.containsKey(preference.id)) {
        throw CacheException('Preferencia no encontrada para actualizar');
      }

      final updatedPreference = preference.copyWith(
        updatedAt: DateTime.now(),
      );

      await box.put(preference.id, updatedPreference);
      return updatedPreference;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Error al actualizar preferencia: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePreference(String id) async {
    try {
      final box = await _openBox();

      if (!box.containsKey(id)) {
        throw CacheException('Preferencia no encontrada para eliminar');
      }

      await box.delete(id);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Error al eliminar preferencia: ${e.toString()}');
    }
  }

  @override
  Future<bool> preferenceExistsForTeam(int teamId) async {
    try {
      final box = await _openBox();
      return box.values.any((pref) => pref.teamId == teamId);
    } catch (e) {
      throw CacheException('Error al verificar preferencia: ${e.toString()}');
    }
  }
}