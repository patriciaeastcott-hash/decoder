/// API service for communicating with the backend
/// Handles all Gemini API proxy calls

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

import '../models/models.dart';

class ApiService {
  // Configure your Cloud Run URL here
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://text-decoder-api-xxxxx.run.app', // Replace with actual URL
  );

  static const Duration _timeout = Duration(seconds: 60);

  final Logger _logger = Logger();
  String? _authToken;

  /// Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  /// Check if device is online
  Future<bool> isOnline() async {
    final connectivity = await Connectivity().checkConnectivity();
    return connectivity != ConnectivityResult.none;
  }

  /// Build headers with auth token
  Map<String, String> _buildHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  /// Handle API response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = body['data'] as Map<String, dynamic>?;
        if (data != null) {
          return ApiResponse.success(fromJson(data));
        }
        return ApiResponse.error('No data in response');
      }

      final error = body['error'] as String? ?? 'Unknown error';
      final details = body['details'] as String? ?? '';
      return ApiResponse.error('$error: $details');
    } catch (e) {
      _logger.e('Error parsing response: $e');
      return ApiResponse.error('Failed to parse response: $e');
    }
  }

  // ============================================
  // SPEAKER IDENTIFICATION
  // ============================================

  /// Identify speakers in conversation text
  Future<ApiResponse<SpeakerIdentificationResult>> identifySpeakers(
      String text) async {
    if (!await isOnline()) {
      return ApiResponse.error(
          'No internet connection. Speaker identification requires online access.');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/analyze/identify-speakers'),
            headers: _buildHeaders(),
            body: jsonEncode({'text': text}),
          )
          .timeout(_timeout);

      return _handleResponse(
          response, (data) => SpeakerIdentificationResult.fromJson(data));
    } on SocketException {
      return ApiResponse.error('Network error. Please check your connection.');
    } on http.ClientException catch (e) {
      return ApiResponse.error('Connection failed: $e');
    } catch (e) {
      _logger.e('Speaker identification error: $e');
      return ApiResponse.error('Failed to identify speakers: $e');
    }
  }

  // ============================================
  // CONVERSATION ANALYSIS
  // ============================================

  /// Analyze a conversation for psychological insights
  Future<ApiResponse<AnalysisResult>> analyzeConversation({
    required List<Message> messages,
    required List<Speaker> speakers,
  }) async {
    if (!await isOnline()) {
      return ApiResponse.error(
          'No internet connection. Conversation analysis requires online access.');
    }

    try {
      final conversationData = messages.map((m) => {
            'speaker': m.speakerName,
            'text': m.text,
          }).toList();

      final speakerNames = speakers.map((s) => s.effectiveName).toList();

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/analyze/conversation'),
            headers: _buildHeaders(),
            body: jsonEncode({
              'conversation': conversationData,
              'speakers': speakerNames,
            }),
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) {
        final result = AnalysisResult.fromJson(data);
        return result;
      });
    } on SocketException {
      return ApiResponse.error('Network error. Please check your connection.');
    } on http.ClientException catch (e) {
      return ApiResponse.error('Connection failed: $e');
    } catch (e) {
      _logger.e('Conversation analysis error: $e');
      return ApiResponse.error('Failed to analyze conversation: $e');
    }
  }

  // ============================================
  // RESPONSE IMPACT ANALYSIS
  // ============================================

  /// Analyze how a potential response might impact the conversation
  Future<ApiResponse<ResponseImpactResult>> analyzeResponseImpact({
    required List<Message> conversation,
    required String userSpeaker,
    required String draftResponse,
  }) async {
    if (!await isOnline()) {
      return ApiResponse.error(
          'No internet connection. Response analysis requires online access.');
    }

    try {
      final conversationData = conversation.map((m) => {
            'speaker': m.speakerName,
            'text': m.text,
          }).toList();

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/analyze/response-impact'),
            headers: _buildHeaders(),
            body: jsonEncode({
              'conversation': conversationData,
              'user_speaker': userSpeaker,
              'draft_response': draftResponse,
            }),
          )
          .timeout(_timeout);

      return _handleResponse(
          response, (data) => ResponseImpactResult.fromJson(data));
    } on SocketException {
      return ApiResponse.error('Network error. Please check your connection.');
    } on http.ClientException catch (e) {
      return ApiResponse.error('Connection failed: $e');
    } catch (e) {
      _logger.e('Response impact analysis error: $e');
      return ApiResponse.error('Failed to analyze response impact: $e');
    }
  }

  // ============================================
  // PROFILE ANALYSIS
  // ============================================

  /// Generate comprehensive profile analysis
  Future<ApiResponse<ProfileAnalysis>> analyzeProfile({
    required Profile profile,
    required List<Conversation> conversations,
  }) async {
    if (!await isOnline()) {
      return ApiResponse.error(
          'No internet connection. Profile analysis requires online access.');
    }

    try {
      // Compile profile data from all conversations
      final profileData = {
        'profile_name': profile.name,
        'conversation_count': conversations.length,
        'conversations': conversations.map((c) => {
              'messages': c.messages.map((m) => m.toJson()).toList(),
              'analysis': c.analysis?.toJson(),
            }).toList(),
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/analyze/profile'),
            headers: _buildHeaders(),
            body: jsonEncode({'profile_data': profileData}),
          )
          .timeout(const Duration(seconds: 120)); // Longer timeout for profile analysis

      return _handleResponse(
          response, (data) => ProfileAnalysis.fromJson(data));
    } on SocketException {
      return ApiResponse.error('Network error. Please check your connection.');
    } on http.ClientException catch (e) {
      return ApiResponse.error('Connection failed: $e');
    } catch (e) {
      _logger.e('Profile analysis error: $e');
      return ApiResponse.error('Failed to analyze profile: $e');
    }
  }

  /// Generate self-profile analysis (unbiased)
  Future<ApiResponse<SelfProfileAnalysis>> analyzeSelfProfile({
    required List<Conversation> conversations,
    required String userName,
  }) async {
    if (!await isOnline()) {
      return ApiResponse.error(
          'No internet connection. Self-profile analysis requires online access.');
    }

    try {
      // Compile user's data from all conversations
      final userData = {
        'user_name': userName,
        'conversation_count': conversations.length,
        'conversations': conversations.map((c) => {
              'messages': c.messages
                  .where((m) => m.speakerName == userName)
                  .map((m) => m.toJson())
                  .toList(),
              'analysis': c.analysis?.toJson(),
            }).toList(),
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/analyze/self-profile'),
            headers: _buildHeaders(),
            body: jsonEncode({'user_data': userData}),
          )
          .timeout(const Duration(seconds: 120));

      return _handleResponse(
          response, (data) => SelfProfileAnalysis.fromJson(data));
    } on SocketException {
      return ApiResponse.error('Network error. Please check your connection.');
    } on http.ClientException catch (e) {
      return ApiResponse.error('Connection failed: $e');
    } catch (e) {
      _logger.e('Self-profile analysis error: $e');
      return ApiResponse.error('Failed to analyze self-profile: $e');
    }
  }

  // ============================================
  // BEHAVIOR LIBRARY
  // ============================================

  /// Fetch the behavior library from server
  Future<ApiResponse<BehaviorLibrary>> fetchBehaviorLibrary() async {
    if (!await isOnline()) {
      return ApiResponse.error(
          'No internet connection. Using cached behavior library.');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/v1/behaviors'),
            headers: _buildHeaders(),
          )
          .timeout(_timeout);

      return _handleResponse(
          response, (data) => BehaviorLibrary.fromJson(data));
    } on SocketException {
      return ApiResponse.error('Network error. Using cached behavior library.');
    } on http.ClientException catch (e) {
      return ApiResponse.error('Connection failed: $e');
    } catch (e) {
      _logger.e('Fetch behavior library error: $e');
      return ApiResponse.error('Failed to fetch behavior library: $e');
    }
  }

  // ============================================
  // SYNC
  // ============================================

  /// Upload encrypted data for sync
  Future<ApiResponse<SyncResult>> uploadSyncData({
    required String encryptedData,
    required String userHash,
  }) async {
    if (!await isOnline()) {
      return ApiResponse.error('No internet connection. Sync requires online access.');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/sync/upload'),
            headers: _buildHeaders(),
            body: jsonEncode({
              'encrypted_data': encryptedData,
              'user_hash': userHash,
            }),
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) => SyncResult.fromJson(data));
    } on SocketException {
      return ApiResponse.error('Network error. Please check your connection.');
    } catch (e) {
      _logger.e('Sync upload error: $e');
      return ApiResponse.error('Failed to sync data: $e');
    }
  }

  /// Download encrypted data from sync
  Future<ApiResponse<SyncDownloadResult>> downloadSyncData({
    required String userHash,
  }) async {
    if (!await isOnline()) {
      return ApiResponse.error('No internet connection. Sync requires online access.');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/sync/download'),
            headers: _buildHeaders(),
            body: jsonEncode({'user_hash': userHash}),
          )
          .timeout(_timeout);

      return _handleResponse(
          response, (data) => SyncDownloadResult.fromJson(data));
    } on SocketException {
      return ApiResponse.error('Network error. Please check your connection.');
    } catch (e) {
      _logger.e('Sync download error: $e');
      return ApiResponse.error('Failed to download sync data: $e');
    }
  }

  // ============================================
  // USER DATA DELETION
  // ============================================

  /// Request deletion of all server-side user data
  Future<ApiResponse<DeleteResult>> deleteUserData({
    required String userHash,
  }) async {
    if (!await isOnline()) {
      return ApiResponse.error(
          'No internet connection. Data deletion requires online access.');
    }

    try {
      final response = await http
          .delete(
            Uri.parse('$_baseUrl/api/v1/user/delete'),
            headers: _buildHeaders(),
            body: jsonEncode({'user_hash': userHash}),
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) => DeleteResult.fromJson(data));
    } on SocketException {
      return ApiResponse.error('Network error. Please check your connection.');
    } catch (e) {
      _logger.e('Delete user data error: $e');
      return ApiResponse.error('Failed to delete user data: $e');
    }
  }

  // ============================================
  // HEALTH CHECK
  // ============================================

  /// Check if API is available
  Future<bool> healthCheck() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

// ============================================
// RESPONSE MODELS
// ============================================

/// Generic API response wrapper
class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const ApiResponse._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse._(data: data, isSuccess: true);
  }

  factory ApiResponse.error(String message) {
    return ApiResponse._(error: message, isSuccess: false);
  }
}

/// Speaker identification result
class SpeakerIdentificationResult {
  final List<String> speakersIdentified;
  final List<IdentifiedMessage> messages;
  final String analysisNotes;
  final double confidenceOverall;

  const SpeakerIdentificationResult({
    required this.speakersIdentified,
    required this.messages,
    this.analysisNotes = '',
    this.confidenceOverall = 0.0,
  });

  factory SpeakerIdentificationResult.fromJson(Map<String, dynamic> json) {
    return SpeakerIdentificationResult(
      speakersIdentified: (json['speakers_identified'] as List<dynamic>?)
              ?.map((s) => s as String)
              .toList() ??
          [],
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => IdentifiedMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      analysisNotes: json['analysis_notes'] as String? ?? '',
      confidenceOverall: (json['confidence_overall'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class IdentifiedMessage {
  final String speaker;
  final String text;
  final double confidence;
  final String reasoning;

  const IdentifiedMessage({
    required this.speaker,
    required this.text,
    this.confidence = 0.0,
    this.reasoning = '',
  });

  factory IdentifiedMessage.fromJson(Map<String, dynamic> json) {
    return IdentifiedMessage(
      speaker: json['speaker'] as String? ?? 'Unknown',
      text: json['text'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      reasoning: json['reasoning'] as String? ?? '',
    );
  }
}

/// Response impact analysis result
class ResponseImpactResult {
  final ImpactAnalysis impactAnalysis;
  final ToneAnalysis toneAnalysis;
  final List<AlternativeResponse> alternativeResponses;
  final RecommendedResponse? recommendedResponse;
  final List<String> communicationTips;

  const ResponseImpactResult({
    required this.impactAnalysis,
    required this.toneAnalysis,
    this.alternativeResponses = const [],
    this.recommendedResponse,
    this.communicationTips = const [],
  });

  factory ResponseImpactResult.fromJson(Map<String, dynamic> json) {
    return ResponseImpactResult(
      impactAnalysis: ImpactAnalysis.fromJson(
          json['impact_analysis'] as Map<String, dynamic>? ?? {}),
      toneAnalysis: ToneAnalysis.fromJson(
          json['tone_analysis'] as Map<String, dynamic>? ?? {}),
      alternativeResponses: (json['alternative_responses'] as List<dynamic>?)
              ?.map((a) => AlternativeResponse.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      recommendedResponse: json['recommended_response'] != null
          ? RecommendedResponse.fromJson(
              json['recommended_response'] as Map<String, dynamic>)
          : null,
      communicationTips: (json['communication_tips'] as List<dynamic>?)
              ?.map((t) => t as String)
              .toList() ??
          [],
    );
  }
}

class ImpactAnalysis {
  final String likelyReception;
  final String emotionalImpact;
  final String powerDynamicShift;
  final String escalationRisk;
  final String deEscalationPotential;
  final List<String> predictedOutcomes;

  const ImpactAnalysis({
    this.likelyReception = '',
    this.emotionalImpact = '',
    this.powerDynamicShift = '',
    this.escalationRisk = 'medium',
    this.deEscalationPotential = 'medium',
    this.predictedOutcomes = const [],
  });

  factory ImpactAnalysis.fromJson(Map<String, dynamic> json) {
    return ImpactAnalysis(
      likelyReception: json['likely_reception'] as String? ?? '',
      emotionalImpact: json['emotional_impact'] as String? ?? '',
      powerDynamicShift: json['power_dynamic_shift'] as String? ?? '',
      escalationRisk: json['escalation_risk'] as String? ?? 'medium',
      deEscalationPotential: json['de_escalation_potential'] as String? ?? 'medium',
      predictedOutcomes: (json['predicted_outcomes'] as List<dynamic>?)
              ?.map((o) => o as String)
              .toList() ??
          [],
    );
  }
}

class ToneAnalysis {
  final String detectedTone;
  final String alignmentWithGoals;
  final List<String> potentialMisinterpretations;

  const ToneAnalysis({
    this.detectedTone = '',
    this.alignmentWithGoals = '',
    this.potentialMisinterpretations = const [],
  });

  factory ToneAnalysis.fromJson(Map<String, dynamic> json) {
    return ToneAnalysis(
      detectedTone: json['detected_tone'] as String? ?? '',
      alignmentWithGoals: json['alignment_with_goals'] as String? ?? '',
      potentialMisinterpretations:
          (json['potential_misinterpretations'] as List<dynamic>?)
                  ?.map((m) => m as String)
                  .toList() ??
              [],
    );
  }
}

class AlternativeResponse {
  final String response;
  final String approach;
  final String likelyImpact;
  final String bestFor;

  const AlternativeResponse({
    required this.response,
    this.approach = '',
    this.likelyImpact = '',
    this.bestFor = '',
  });

  factory AlternativeResponse.fromJson(Map<String, dynamic> json) {
    return AlternativeResponse(
      response: json['response'] as String? ?? '',
      approach: json['approach'] as String? ?? '',
      likelyImpact: json['likely_impact'] as String? ?? '',
      bestFor: json['best_for'] as String? ?? '',
    );
  }
}

class RecommendedResponse {
  final String text;
  final String reasoning;
  final String expectedOutcome;

  const RecommendedResponse({
    required this.text,
    this.reasoning = '',
    this.expectedOutcome = '',
  });

  factory RecommendedResponse.fromJson(Map<String, dynamic> json) {
    return RecommendedResponse(
      text: json['text'] as String? ?? '',
      reasoning: json['reasoning'] as String? ?? '',
      expectedOutcome: json['expected_outcome'] as String? ?? '',
    );
  }
}

/// Self-profile analysis result
class SelfProfileAnalysis {
  final String honestSummary;
  final SelfAwarenessIndicators? selfAwarenessIndicators;
  final Map<String, dynamic> communicationSelfProfile;
  final Map<String, dynamic> emotionalPatterns;
  final Map<String, dynamic> behavioralTendencies;
  final Map<String, dynamic> relationshipPatterns;
  final List<Map<String, String>> honestStrengths;
  final List<Map<String, String>> honestGrowthAreas;
  final Map<String, dynamic> actionPlan;
  final String encouragement;

  const SelfProfileAnalysis({
    required this.honestSummary,
    this.selfAwarenessIndicators,
    this.communicationSelfProfile = const {},
    this.emotionalPatterns = const {},
    this.behavioralTendencies = const {},
    this.relationshipPatterns = const {},
    this.honestStrengths = const [],
    this.honestGrowthAreas = const [],
    this.actionPlan = const {},
    this.encouragement = '',
  });

  factory SelfProfileAnalysis.fromJson(Map<String, dynamic> json) {
    return SelfProfileAnalysis(
      honestSummary: json['honest_summary'] as String? ?? '',
      selfAwarenessIndicators: json['self_awareness_indicators'] != null
          ? SelfAwarenessIndicators.fromJson(
              json['self_awareness_indicators'] as Map<String, dynamic>)
          : null,
      communicationSelfProfile:
          json['communication_self_profile'] as Map<String, dynamic>? ?? {},
      emotionalPatterns:
          json['emotional_patterns'] as Map<String, dynamic>? ?? {},
      behavioralTendencies:
          json['behavioral_tendencies'] as Map<String, dynamic>? ?? {},
      relationshipPatterns:
          json['relationship_patterns'] as Map<String, dynamic>? ?? {},
      honestStrengths: (json['honest_strengths'] as List<dynamic>?)
              ?.map((s) => Map<String, String>.from(s as Map))
              .toList() ??
          [],
      honestGrowthAreas: (json['honest_growth_areas'] as List<dynamic>?)
              ?.map((g) => Map<String, String>.from(g as Map))
              .toList() ??
          [],
      actionPlan: json['action_plan'] as Map<String, dynamic>? ?? {},
      encouragement: json['encouragement'] as String? ?? '',
    );
  }
}

class SelfAwarenessIndicators {
  final String level;
  final String evidence;
  final List<String> blindSpots;

  const SelfAwarenessIndicators({
    this.level = '',
    this.evidence = '',
    this.blindSpots = const [],
  });

  factory SelfAwarenessIndicators.fromJson(Map<String, dynamic> json) {
    return SelfAwarenessIndicators(
      level: json['level'] as String? ?? '',
      evidence: json['evidence'] as String? ?? '',
      blindSpots: (json['blind_spots'] as List<dynamic>?)
              ?.map((b) => b as String)
              .toList() ??
          [],
    );
  }
}

/// Sync result
class SyncResult {
  final String syncId;
  final String timestamp;
  final String status;

  const SyncResult({
    required this.syncId,
    required this.timestamp,
    required this.status,
  });

  factory SyncResult.fromJson(Map<String, dynamic> json) {
    return SyncResult(
      syncId: json['sync_id'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

class SyncDownloadResult {
  final String? encryptedData;
  final String? lastSync;
  final String status;

  const SyncDownloadResult({
    this.encryptedData,
    this.lastSync,
    required this.status,
  });

  factory SyncDownloadResult.fromJson(Map<String, dynamic> json) {
    return SyncDownloadResult(
      encryptedData: json['encrypted_data'] as String?,
      lastSync: json['last_sync'] as String?,
      status: json['status'] as String? ?? '',
    );
  }
}

/// Delete result
class DeleteResult {
  final bool deleted;
  final String timestamp;
  final String confirmationCode;

  const DeleteResult({
    required this.deleted,
    required this.timestamp,
    required this.confirmationCode,
  });

  factory DeleteResult.fromJson(Map<String, dynamic> json) {
    return DeleteResult(
      deleted: json['deleted'] as bool? ?? false,
      timestamp: json['timestamp'] as String? ?? '',
      confirmationCode: json['confirmation_code'] as String? ?? '',
    );
  }
}
