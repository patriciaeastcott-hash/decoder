/// Conversation provider for managing conversations and analyses
library;

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class ConversationProvider extends ChangeNotifier {
  final StorageService _storageService;
  final ApiService _apiService = ApiService();

  ConversationProvider({required StorageService storageService})
      : _storageService = storageService;

  // ============================================
  // STATE
  // ============================================

  List<Conversation> _conversations = [];
  List<Conversation> get conversations => _conversations;

  Conversation? _currentConversation;
  Conversation? get currentConversation => _currentConversation;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Processing state
  bool _isIdentifyingSpeakers = false;
  bool get isIdentifyingSpeakers => _isIdentifyingSpeakers;

  bool _isAnalyzing = false;
  bool get isAnalyzing => _isAnalyzing;

  // ============================================
  // INITIALIZATION
  // ============================================

  Future<void> loadConversations() async {
    _setLoading(true);

    try {
      _conversations = await _storageService.getAllConversations();
      _clearError();
    } catch (e) {
      _setError('Failed to load conversations: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ============================================
  // CONVERSATION CRUD
  // ============================================

  /// Create a new conversation from raw text
  Future<Conversation?> createConversation({
    required String rawText,
    String? title,
    String? sourceType,
  }) async {
    _setLoading(true);

    try {
      final conversation = Conversation.fromRawText(
        rawText,
        title: title,
      ).copyWith(sourceType: sourceType);

      await _storageService.saveConversation(conversation);
      _conversations.insert(0, conversation);
      _currentConversation = conversation;
      _clearError();
      notifyListeners();
      return conversation;
    } catch (e) {
      _setError('Failed to create conversation: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get a specific conversation
  Future<Conversation?> getConversation(String id) async {
    // Check local list first
    final local = _conversations.where((c) => c.id == id).firstOrNull;
    if (local != null) {
      _currentConversation = local;
      notifyListeners();
      return local;
    }

    // Load from storage
    final conversation = await _storageService.getConversation(id);
    if (conversation != null) {
      _currentConversation = conversation;
      notifyListeners();
    }
    return conversation;
  }

  /// Update a conversation
  Future<bool> updateConversation(Conversation conversation) async {
    try {
      final updated = conversation.copyWith(updatedAt: DateTime.now());
      await _storageService.saveConversation(updated);

      // Update local list
      final index = _conversations.indexWhere((c) => c.id == conversation.id);
      if (index >= 0) {
        _conversations[index] = updated;
      }

      if (_currentConversation?.id == conversation.id) {
        _currentConversation = updated;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update conversation: $e');
      return false;
    }
  }

  /// Delete a conversation
  Future<bool> deleteConversation(String id) async {
    try {
      await _storageService.deleteConversation(id);
      _conversations.removeWhere((c) => c.id == id);

      if (_currentConversation?.id == id) {
        _currentConversation = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete conversation: $e');
      return false;
    }
  }

  /// Delete all conversations
  Future<bool> deleteAllConversations() async {
    try {
      await _storageService.deleteAllConversations();
      _conversations.clear();
      _currentConversation = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete conversations: $e');
      return false;
    }
  }

  // ============================================
  // SPEAKER IDENTIFICATION
  // ============================================

  /// Identify speakers in a conversation using AI
  Future<bool> identifySpeakers(Conversation conversation) async {
    _isIdentifyingSpeakers = true;
    notifyListeners();

    try {
      final result = await _apiService.identifySpeakers(conversation.rawText);

      if (!result.isSuccess) {
        _setError(result.error ?? 'Failed to identify speakers');
        return false;
      }

      final data = result.data!;

      // Convert identified messages to our format
      final messages = <Message>[];
      final speakerMap = <String, Speaker>{};

      for (var i = 0; i < data.messages.length; i++) {
        final msg = data.messages[i];

        // Create speaker if not exists
        if (!speakerMap.containsKey(msg.speaker)) {
          speakerMap[msg.speaker] = Speaker.fromAIIdentification(msg.speaker);
        }

        messages.add(Message(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}_$i',
          text: msg.text,
          speakerId: speakerMap[msg.speaker]!.id,
          speakerName: msg.speaker,
          confidenceScore: msg.confidence,
          reasoning: msg.reasoning,
          isVerified: false,
          orderIndex: i,
        ));
      }

      // Update conversation
      final updated = conversation.copyWith(
        messages: messages,
        speakers: speakerMap.values.toList(),
        status: ConversationStatus.speakersIdentified,
        updatedAt: DateTime.now(),
      );

      await updateConversation(updated);
      _clearError();
      return true;
    } catch (e) {
      _setError('Speaker identification failed: $e');
      return false;
    } finally {
      _isIdentifyingSpeakers = false;
      notifyListeners();
    }
  }

  /// Update speaker assignment for a message
  Future<bool> updateMessageSpeaker({
    required String conversationId,
    required String messageId,
    required String newSpeakerId,
    required String newSpeakerName,
  }) async {
    final conversation = await getConversation(conversationId);
    if (conversation == null) return false;

    final updatedMessages = conversation.messages.map((m) {
      if (m.id == messageId) {
        return m.copyWith(
          speakerId: newSpeakerId,
          speakerName: newSpeakerName,
          isVerified: true,
        );
      }
      return m;
    }).toList();

    return updateConversation(conversation.copyWith(messages: updatedMessages));
  }

  /// Mark all speakers as verified
  Future<bool> verifySpeakers(String conversationId) async {
    final conversation = await getConversation(conversationId);
    if (conversation == null) return false;

    final updatedMessages = conversation.messages
        .map((m) => m.copyWith(isVerified: true))
        .toList();

    return updateConversation(conversation.copyWith(
      messages: updatedMessages,
      speakersVerified: true,
      status: ConversationStatus.speakersVerified,
    ));
  }

  /// Add a new speaker to a conversation
  Future<Speaker?> addSpeaker({
    required String conversationId,
    required String name,
    bool isUser = false,
  }) async {
    final conversation = await getConversation(conversationId);
    if (conversation == null) return null;

    final speaker = Speaker.fromAIIdentification(name, isUser: isUser);
    final updatedSpeakers = [...conversation.speakers, speaker];

    final success = await updateConversation(
      conversation.copyWith(speakers: updatedSpeakers),
    );

    return success ? speaker : null;
  }

  /// Update speaker details
  Future<bool> updateSpeaker({
    required String conversationId,
    required Speaker speaker,
  }) async {
    final conversation = await getConversation(conversationId);
    if (conversation == null) return false;

    final updatedSpeakers = conversation.speakers.map((s) {
      if (s.id == speaker.id) return speaker;
      return s;
    }).toList();

    // Also update messages with this speaker
    final updatedMessages = conversation.messages.map((m) {
      if (m.speakerId == speaker.id) {
        return m.copyWith(speakerName: speaker.effectiveName);
      }
      return m;
    }).toList();

    return updateConversation(conversation.copyWith(
      speakers: updatedSpeakers,
      messages: updatedMessages,
    ));
  }

  // ============================================
  // CONVERSATION ANALYSIS
  // ============================================

  /// Analyze a conversation for psychological insights
  Future<bool> analyzeConversation(Conversation conversation) async {
    if (!conversation.speakersVerified) {
      _setError('Please verify speakers before analyzing');
      return false;
    }

    _isAnalyzing = true;
    notifyListeners();

    // Update status to analyzing
    await updateConversation(
      conversation.copyWith(status: ConversationStatus.analyzing),
    );

    try {
      final result = await _apiService.analyzeConversation(
        messages: conversation.messages,
        speakers: conversation.speakers,
      );

      if (!result.isSuccess) {
        await updateConversation(
          conversation.copyWith(status: ConversationStatus.error),
        );
        _setError(result.error ?? 'Analysis failed');
        return false;
      }

      final analysis = result.data!.copyWith(
        conversationId: conversation.id,
      );

      final updated = conversation.copyWith(
        analysis: analysis,
        status: ConversationStatus.analyzed,
        updatedAt: DateTime.now(),
      );

      await updateConversation(updated);
      _clearError();
      return true;
    } catch (e) {
      await updateConversation(
        conversation.copyWith(status: ConversationStatus.error),
      );
      _setError('Analysis failed: $e');
      return false;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  // ============================================
  // RESPONSE TESTING
  // ============================================

  ResponseImpactResult? _lastResponseImpact;
  ResponseImpactResult? get lastResponseImpact => _lastResponseImpact;

  bool _isTestingResponse = false;
  bool get isTestingResponse => _isTestingResponse;

  /// Test how a response might impact the conversation
  Future<ResponseImpactResult?> testResponse({
    required Conversation conversation,
    required String userSpeaker,
    required String draftResponse,
  }) async {
    _isTestingResponse = true;
    notifyListeners();

    try {
      final result = await _apiService.analyzeResponseImpact(
        conversation: conversation.messages,
        userSpeaker: userSpeaker,
        draftResponse: draftResponse,
      );

      if (!result.isSuccess) {
        _setError(result.error ?? 'Response analysis failed');
        return null;
      }

      _lastResponseImpact = result.data;
      _clearError();
      return result.data;
    } catch (e) {
      _setError('Response analysis failed: $e');
      return null;
    } finally {
      _isTestingResponse = false;
      notifyListeners();
    }
  }

  void clearResponseImpact() {
    _lastResponseImpact = null;
    notifyListeners();
  }

  // ============================================
  // HELPERS
  // ============================================

  void setCurrentConversation(Conversation? conversation) {
    _currentConversation = conversation;
    notifyListeners();
  }

  void clearCurrentConversation() {
    _currentConversation = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ============================================
  // ACCESSIBILITY
  // ============================================

  String get accessibilityStateLabel {
    if (_isLoading) return 'Loading conversations';
    if (_isIdentifyingSpeakers) return 'Identifying speakers in conversation';
    if (_isAnalyzing) return 'Analyzing conversation';
    if (_isTestingResponse) return 'Testing response impact';
    if (error != null) return 'Error: $error';
    return '${_conversations.length} conversations available';
  }
}
