/// Local storage service using Hive
/// All user data is stored locally on device
library;

import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';

import '../models/models.dart';

class StorageService {
  static const String _conversationsBoxName = 'conversations';
  static const String _profilesBoxName = 'profiles';
  static const String _settingsBoxName = 'settings';
  static const String _behaviorLibraryBoxName = 'behavior_library';
  static const String _syncMetadataBoxName = 'sync_metadata';

  late Box<String> _conversationsBox;
  late Box<String> _profilesBox;
  late Box<dynamic> _settingsBox;
  late Box<String> _behaviorLibraryBox;
  late Box<String> _syncMetadataBox;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _initialized = false;

  /// Initialize storage service
  Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // Open boxes
    _conversationsBox = await Hive.openBox<String>(_conversationsBoxName);
    _profilesBox = await Hive.openBox<String>(_profilesBoxName);
    _settingsBox = await Hive.openBox<dynamic>(_settingsBoxName);
    _behaviorLibraryBox = await Hive.openBox<String>(_behaviorLibraryBoxName);
    _syncMetadataBox = await Hive.openBox<String>(_syncMetadataBoxName);

    _initialized = true;
  }

  /// Ensure service is initialized
  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('StorageService not initialized. Call initialize() first.');
    }
  }

  // ============================================
  // CONVERSATIONS
  // ============================================

  /// Save a conversation
  Future<void> saveConversation(Conversation conversation) async {
    _ensureInitialized();
    final json = jsonEncode(conversation.toJson());
    await _conversationsBox.put(conversation.id, json);
  }

  /// Get a conversation by ID
  Future<Conversation?> getConversation(String id) async {
    _ensureInitialized();
    final json = _conversationsBox.get(id);
    if (json == null) return null;
    return Conversation.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Get all conversations
  Future<List<Conversation>> getAllConversations() async {
    _ensureInitialized();
    final conversations = <Conversation>[];
    for (final key in _conversationsBox.keys) {
      final json = _conversationsBox.get(key);
      if (json != null) {
        conversations.add(
          Conversation.fromJson(jsonDecode(json) as Map<String, dynamic>),
        );
      }
    }
    // Sort by updated date, newest first
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return conversations;
  }

  /// Delete a conversation
  Future<void> deleteConversation(String id) async {
    _ensureInitialized();
    await _conversationsBox.delete(id);
  }

  /// Delete all conversations
  Future<void> deleteAllConversations() async {
    _ensureInitialized();
    await _conversationsBox.clear();
  }

  // ============================================
  // PROFILES
  // ============================================

  /// Save a profile
  Future<void> saveProfile(Profile profile) async {
    _ensureInitialized();
    final json = jsonEncode(profile.toJson());
    await _profilesBox.put(profile.id, json);
  }

  /// Get a profile by ID
  Future<Profile?> getProfile(String id) async {
    _ensureInitialized();
    final json = _profilesBox.get(id);
    if (json == null) return null;
    return Profile.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Get all profiles
  Future<List<Profile>> getAllProfiles() async {
    _ensureInitialized();
    final profiles = <Profile>[];
    for (final key in _profilesBox.keys) {
      final json = _profilesBox.get(key);
      if (json != null) {
        profiles.add(
          Profile.fromJson(jsonDecode(json) as Map<String, dynamic>),
        );
      }
    }
    // Sort by name
    profiles.sort((a, b) => a.name.compareTo(b.name));
    return profiles;
  }

  /// Get user's self profile
  Future<Profile?> getUserProfile() async {
    _ensureInitialized();
    final profiles = await getAllProfiles();
    return profiles.where((p) => p.isUserProfile).firstOrNull;
  }

  /// Delete a profile
  Future<void> deleteProfile(String id) async {
    _ensureInitialized();
    await _profilesBox.delete(id);
  }

  /// Delete all profiles
  Future<void> deleteAllProfiles() async {
    _ensureInitialized();
    await _profilesBox.clear();
  }

  /// Clean up expired profiles
  Future<int> cleanupExpiredProfiles() async {
    _ensureInitialized();
    final profiles = await getAllProfiles();
    final now = DateTime.now();
    int deleted = 0;

    for (final profile in profiles) {
      if (profile.expiresAt != null && profile.expiresAt!.isBefore(now)) {
        await deleteProfile(profile.id);
        deleted++;
      }
    }

    return deleted;
  }

  // ============================================
  // SETTINGS
  // ============================================

  /// Save a setting
  Future<void> saveSetting(String key, dynamic value) async {
    _ensureInitialized();
    await _settingsBox.put(key, value);
  }

  /// Get a setting
  T? getSetting<T>(String key, {T? defaultValue}) {
    _ensureInitialized();
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  /// Get all settings
  Map<String, dynamic> getAllSettings() {
    _ensureInitialized();
    final settings = <String, dynamic>{};
    for (final key in _settingsBox.keys) {
      settings[key as String] = _settingsBox.get(key);
    }
    return settings;
  }

  /// Delete a setting
  Future<void> deleteSetting(String key) async {
    _ensureInitialized();
    await _settingsBox.delete(key);
  }

  /// Reset all settings to defaults
  Future<void> resetSettings() async {
    _ensureInitialized();
    await _settingsBox.clear();
  }

  // ============================================
  // BEHAVIOR LIBRARY
  // ============================================

  /// Save behavior library
  Future<void> saveBehaviorLibrary(BehaviorLibrary library) async {
    _ensureInitialized();
    final json = jsonEncode(library.toJson());
    await _behaviorLibraryBox.put('library', json);
    await _behaviorLibraryBox.put('version', library.version);
    await _behaviorLibraryBox.put('last_updated', library.lastUpdated);
  }

  /// Get behavior library
  Future<BehaviorLibrary?> getBehaviorLibrary() async {
    _ensureInitialized();
    final json = _behaviorLibraryBox.get('library');
    if (json == null) return null;
    return BehaviorLibrary.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Get library version
  String? getBehaviorLibraryVersion() {
    _ensureInitialized();
    return _behaviorLibraryBox.get('version');
  }

  // ============================================
  // SECURE STORAGE (for sensitive data)
  // ============================================

  /// Save encrypted data
  Future<void> saveSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// Get encrypted data
  Future<String?> getSecure(String key) async {
    return await _secureStorage.read(key: key);
  }

  /// Delete encrypted data
  Future<void> deleteSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// Delete all encrypted data
  Future<void> deleteAllSecure() async {
    await _secureStorage.deleteAll();
  }

  // ============================================
  // SYNC METADATA
  // ============================================

  /// Save sync metadata
  Future<void> saveSyncMetadata(String key, String value) async {
    _ensureInitialized();
    await _syncMetadataBox.put(key, value);
  }

  /// Get sync metadata
  String? getSyncMetadata(String key) {
    _ensureInitialized();
    return _syncMetadataBox.get(key);
  }

  /// Get last sync time
  DateTime? getLastSyncTime() {
    final timestamp = getSyncMetadata('last_sync');
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp);
  }

  /// Set last sync time
  Future<void> setLastSyncTime(DateTime time) async {
    await saveSyncMetadata('last_sync', time.toIso8601String());
  }

  // ============================================
  // DATA EXPORT/IMPORT FOR SYNC
  // ============================================

  /// Export all data for sync (encrypted)
  Future<String> exportDataForSync(String encryptionKey) async {
    _ensureInitialized();

    final data = {
      'conversations': _conversationsBox.toMap(),
      'profiles': _profilesBox.toMap(),
      'settings': getAllSettings(),
      'exported_at': DateTime.now().toIso8601String(),
    };

    final jsonString = jsonEncode(data);

    // Encrypt
    final key = encrypt.Key.fromUtf8(_padKey(encryptionKey));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(jsonString, iv: iv);

    return '${iv.base64}:${encrypted.base64}';
  }

  /// Import data from sync (decrypted)
  Future<void> importDataFromSync(
      String encryptedData, String encryptionKey) async {
    _ensureInitialized();

    // Decrypt
    final parts = encryptedData.split(':');
    if (parts.length != 2) throw const FormatException('Invalid encrypted data format');

    final iv = encrypt.IV.fromBase64(parts[0]);
    final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
    final key = encrypt.Key.fromUtf8(_padKey(encryptionKey));
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decrypted = encrypter.decrypt(encrypted, iv: iv);

    final data = jsonDecode(decrypted) as Map<String, dynamic>;

    // Import conversations
    final conversations = data['conversations'] as Map<String, dynamic>?;
    if (conversations != null) {
      for (final entry in conversations.entries) {
        await _conversationsBox.put(entry.key, entry.value as String);
      }
    }

    // Import profiles
    final profiles = data['profiles'] as Map<String, dynamic>?;
    if (profiles != null) {
      for (final entry in profiles.entries) {
        await _profilesBox.put(entry.key, entry.value as String);
      }
    }

    // Import settings
    final settings = data['settings'] as Map<String, dynamic>?;
    if (settings != null) {
      for (final entry in settings.entries) {
        await _settingsBox.put(entry.key, entry.value);
      }
    }
  }

  /// Pad encryption key to 32 characters
  String _padKey(String key) {
    if (key.length >= 32) return key.substring(0, 32);
    return key.padRight(32, '0');
  }

  // ============================================
  // DATA DELETION (Privacy Compliance)
  // ============================================

  /// Delete all user data (full reset)
  Future<void> deleteAllData() async {
    _ensureInitialized();

    await _conversationsBox.clear();
    await _profilesBox.clear();
    await _settingsBox.clear();
    await _syncMetadataBox.clear();
    await _secureStorage.deleteAll();
  }

  /// Delete data for a specific person (profile and associated conversations)
  Future<void> deletePersonData(String profileId) async {
    _ensureInitialized();

    // Get the profile
    final profile = await getProfile(profileId);
    if (profile == null) return;

    // Delete associated conversations
    for (final convId in profile.conversationIds) {
      await deleteConversation(convId);
    }

    // Delete the profile
    await deleteProfile(profileId);
  }

  /// Generate anonymous hash for user identification (for sync)
  String generateUserHash(String userId) {
    final bytes = utf8.encode(userId);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ============================================
  // STORAGE STATISTICS
  // ============================================

  /// Get storage statistics
  Future<StorageStats> getStorageStats() async {
    _ensureInitialized();

    return StorageStats(
      conversationCount: _conversationsBox.length,
      profileCount: _profilesBox.length,
      behaviorLibraryLoaded: _behaviorLibraryBox.get('library') != null,
      lastSyncTime: getLastSyncTime(),
    );
  }
}

/// Storage statistics
class StorageStats {
  final int conversationCount;
  final int profileCount;
  final bool behaviorLibraryLoaded;
  final DateTime? lastSyncTime;

  const StorageStats({
    required this.conversationCount,
    required this.profileCount,
    required this.behaviorLibraryLoaded,
    this.lastSyncTime,
  });

  String get accessibilityLabel {
    return '$conversationCount conversations, $profileCount profiles stored locally';
  }
}
