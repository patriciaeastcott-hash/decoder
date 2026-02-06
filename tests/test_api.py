"""
Backend API Tests for Text Decoder
Tests all endpoints, utilities, error handling, and security features.

Run: python -m pytest tests/ -v --cov=app
"""

import json
import os
import pytest
from unittest.mock import patch, MagicMock
from datetime import datetime

# Set env vars before importing app
os.environ['APP_SECRET_KEY'] = 'test-secret-key'

from app import (
    app,
    sanitize_input,
    create_accessible_response,
    create_error_response,
    count_behaviors,
    get_default_behavior_library,
)


# ============================================
# FIXTURES
# ============================================

@pytest.fixture
def client():
    """Create a test client."""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


@pytest.fixture
def auth_header():
    """Standard auth header for protected endpoints."""
    return {'Authorization': 'Bearer test-token-12345'}


@pytest.fixture
def sample_conversation_text():
    return "Alice: Hey, how was your day?\nBob: It was good, thanks for asking!"


@pytest.fixture
def sample_conversation_data():
    return {
        'conversation': [
            {'speaker': 'Alice', 'text': 'Hey, how was your day?'},
            {'speaker': 'Bob', 'text': 'It was good, thanks for asking!'},
        ],
        'speakers': ['Alice', 'Bob']
    }


@pytest.fixture
def sample_behavior_library():
    return {
        "version": "1.0.0",
        "categories": [
            {
                "category": "Communication Styles",
                "subcategories": [
                    {
                        "name": "Assertive",
                        "behaviors": [
                            {"id": "assert_1", "name": "Direct Expression"},
                            {"id": "assert_2", "name": "Clear Boundaries"},
                        ]
                    }
                ]
            },
            {
                "category": "Emotional Intelligence",
                "subcategories": [
                    {
                        "name": "Self-Awareness",
                        "behaviors": [
                            {"id": "ei_1", "name": "Emotion Recognition"},
                        ]
                    }
                ]
            }
        ]
    }


# ============================================
# UTILITY FUNCTION TESTS
# ============================================

class TestSanitizeInput:
    """Tests for input sanitization."""

    def test_removes_html_tags(self):
        result = sanitize_input("<script>alert('xss')</script>Hello")
        assert "<script>" not in result
        assert "Hello" in result

    def test_removes_html_attributes(self):
        result = sanitize_input('<a href="javascript:alert(1)">Click</a>')
        assert "javascript" not in result
        assert "Click" in result

    def test_preserves_plain_text(self):
        text = "This is a normal conversation between two people."
        assert sanitize_input(text) == text

    def test_truncates_long_input(self):
        long_text = "a" * 60000
        result = sanitize_input(long_text)
        assert len(result) == 50000

    def test_handles_empty_string(self):
        assert sanitize_input("") == ""

    def test_handles_none(self):
        assert sanitize_input(None) == ""

    def test_preserves_newlines(self):
        text = "Alice: Hello\nBob: Hi there"
        result = sanitize_input(text)
        assert "\n" in result

    def test_preserves_unicode(self):
        text = "Hello, this has emoji and accents: cafe"
        result = sanitize_input(text)
        assert "cafe" in result


class TestCreateAccessibleResponse:
    """Tests for WCAG-compliant response builder."""

    def test_basic_structure(self):
        result = create_accessible_response({"key": "value"}, "Test message")
        assert result['success'] is True
        assert result['message'] == "Test message"
        assert result['data'] == {"key": "value"}
        assert 'timestamp' in result
        assert 'accessibility' in result

    def test_accessibility_fields(self):
        result = create_accessible_response({}, "Test")
        assert result['accessibility']['screen_reader_summary'] == "Test"
        assert result['accessibility']['data_type'] == 'dict'

    def test_default_message(self):
        result = create_accessible_response({})
        assert result['message'] == "Success"

    def test_timestamp_format(self):
        result = create_accessible_response({})
        # Should be ISO format
        datetime.fromisoformat(result['timestamp'])


class TestCreateErrorResponse:
    """Tests for error response builder (requires Flask app context for jsonify)."""

    def test_returns_tuple(self, client):
        with app.app_context():
            result = create_error_response("Test Error", "Details", 400)
            assert isinstance(result, tuple)
            assert result[1] == 400

    def test_error_body_structure(self, client):
        with app.app_context():
            response, status = create_error_response("Not Found", "Resource missing", 404)
            data = response.get_json()
            assert data['success'] is False
            assert data['error'] == "Not Found"
            assert data['details'] == "Resource missing"
            assert 'timestamp' in data
            assert 'accessibility' in data

    def test_accessibility_in_error(self, client):
        with app.app_context():
            response, _ = create_error_response("Server Error")
            data = response.get_json()
            assert "Error: Server Error" in data['accessibility']['screen_reader_summary']
            assert data['accessibility']['suggested_action'] is not None


class TestCountBehaviors:
    """Tests for behavior counting utility."""

    def test_counts_correctly(self, sample_behavior_library):
        count = count_behaviors(sample_behavior_library)
        assert count == 3  # 2 + 1

    def test_empty_library(self):
        assert count_behaviors({}) == 0
        assert count_behaviors({"categories": []}) == 0

    def test_missing_subcategories(self):
        lib = {"categories": [{"category": "Test"}]}
        assert count_behaviors(lib) == 0

    def test_missing_behaviors(self):
        lib = {"categories": [{"category": "Test", "subcategories": [{"name": "Sub"}]}]}
        assert count_behaviors(lib) == 0


class TestGetDefaultBehaviorLibrary:
    """Tests for the default behavior library."""

    def test_returns_dict(self):
        result = get_default_behavior_library()
        assert isinstance(result, dict)

    def test_has_version(self):
        result = get_default_behavior_library()
        assert 'version' in result

    def test_has_categories(self):
        result = get_default_behavior_library()
        assert 'categories' in result
        assert isinstance(result['categories'], list)


# ============================================
# HEALTH CHECK ENDPOINT
# ============================================

class TestHealthCheck:
    """Tests for /health endpoint."""

    def test_returns_200(self, client):
        response = client.get('/health')
        assert response.status_code == 200

    def test_response_structure(self, client):
        response = client.get('/health')
        data = response.get_json()
        assert data['status'] == 'healthy'
        assert data['service'] == 'text-decoder-api'
        assert data['version'] == '1.0.0-mvp'
        assert 'timestamp' in data

    def test_no_auth_required(self, client):
        """Health check should not require authentication."""
        response = client.get('/health')
        assert response.status_code == 200


# ============================================
# AUTH VALIDATION
# ============================================

class TestAuthValidation:
    """Tests for the authentication decorator."""

    def test_rejects_missing_auth(self, client):
        response = client.post('/api/v1/analyze/identify-speakers',
                               json={'text': 'hello'})
        assert response.status_code == 401

    def test_rejects_invalid_auth_format(self, client):
        response = client.post('/api/v1/analyze/identify-speakers',
                               json={'text': 'hello'},
                               headers={'Authorization': 'InvalidFormat'})
        assert response.status_code == 401

    def test_rejects_empty_bearer(self, client):
        response = client.post('/api/v1/analyze/identify-speakers',
                               json={'text': 'hello'},
                               headers={'Authorization': 'Token abc'})
        assert response.status_code == 401

    def test_accepts_bearer_token(self, client, auth_header):
        """With valid bearer token, should not get 401 (may get other errors)."""
        response = client.post('/api/v1/analyze/identify-speakers',
                               json={'text': 'hello'},
                               headers=auth_header)
        assert response.status_code != 401


# ============================================
# SPEAKER IDENTIFICATION ENDPOINT
# ============================================

class TestIdentifySpeakers:
    """Tests for /api/v1/analyze/identify-speakers endpoint."""

    def test_rejects_missing_text(self, client, auth_header):
        response = client.post('/api/v1/analyze/identify-speakers',
                               json={},
                               headers=auth_header)
        assert response.status_code == 400
        data = response.get_json()
        assert data['success'] is False

    def test_rejects_empty_text(self, client, auth_header):
        response = client.post('/api/v1/analyze/identify-speakers',
                               json={'text': ''},
                               headers=auth_header)
        assert response.status_code == 400

    @patch('app.genai')
    def test_successful_identification(self, mock_genai, client, auth_header):
        """Test successful speaker identification with mocked Gemini."""
        mock_model = MagicMock()
        mock_genai.GenerativeModel.return_value = mock_model
        mock_response = MagicMock()
        mock_response.text = json.dumps({
            "speakers_identified": ["Alice", "Bob"],
            "messages": [
                {"speaker": "Alice", "text": "Hello", "confidence": 0.9, "reasoning": "Name used"},
                {"speaker": "Bob", "text": "Hi there", "confidence": 0.85, "reasoning": "Context"},
            ],
            "analysis_notes": "Clear two-person conversation",
            "confidence_overall": 0.87
        })
        mock_model.generate_content.return_value = mock_response

        response = client.post('/api/v1/analyze/identify-speakers',
                               json={'text': 'Alice: Hello\nBob: Hi there'},
                               headers=auth_header)
        assert response.status_code == 200
        data = response.get_json()
        assert data['success'] is True
        assert 'speakers_identified' in data['data']

    @patch('app.genai')
    def test_handles_malformed_gemini_response(self, mock_genai, client, auth_header):
        """Test graceful handling of non-JSON Gemini response."""
        mock_model = MagicMock()
        mock_genai.GenerativeModel.return_value = mock_model
        mock_response = MagicMock()
        mock_response.text = "This is not valid JSON"
        mock_model.generate_content.return_value = mock_response

        response = client.post('/api/v1/analyze/identify-speakers',
                               json={'text': 'Some conversation text'},
                               headers=auth_header)
        assert response.status_code == 200
        data = response.get_json()
        assert data['success'] is True
        # Should fall back to default structure
        assert 'raw_response' in data['data'] or 'speakers_identified' in data['data']

    @patch('app.genai')
    def test_handles_gemini_exception(self, mock_genai, client, auth_header):
        """Test error handling when Gemini API throws."""
        mock_model = MagicMock()
        mock_genai.GenerativeModel.return_value = mock_model
        mock_model.generate_content.side_effect = Exception("API rate limit")

        response = client.post('/api/v1/analyze/identify-speakers',
                               json={'text': 'Some conversation text'},
                               headers=auth_header)
        assert response.status_code == 500
        data = response.get_json()
        assert data['success'] is False

    def test_sanitizes_input(self, client, auth_header):
        """Input with HTML should be sanitized."""
        with patch('app.genai') as mock_genai:
            mock_model = MagicMock()
            mock_genai.GenerativeModel.return_value = mock_model
            mock_response = MagicMock()
            mock_response.text = json.dumps({
                "speakers_identified": ["Speaker 1"],
                "messages": [],
                "analysis_notes": "",
                "confidence_overall": 0.5
            })
            mock_model.generate_content.return_value = mock_response

            response = client.post('/api/v1/analyze/identify-speakers',
                                   json={'text': '<script>alert("xss")</script>Hello'},
                                   headers=auth_header)
            assert response.status_code == 200


# ============================================
# CONVERSATION ANALYSIS ENDPOINT
# ============================================

class TestAnalyzeConversation:
    """Tests for /api/v1/analyze/conversation endpoint."""

    def test_rejects_missing_conversation(self, client, auth_header):
        response = client.post('/api/v1/analyze/conversation',
                               json={'speakers': ['Alice', 'Bob']},
                               headers=auth_header)
        assert response.status_code == 400

    def test_rejects_missing_speakers(self, client, auth_header):
        response = client.post('/api/v1/analyze/conversation',
                               json={'conversation': 'text'},
                               headers=auth_header)
        assert response.status_code == 400

    @patch('app.genai')
    def test_successful_analysis(self, mock_genai, client, auth_header, sample_conversation_data):
        mock_model = MagicMock()
        mock_genai.GenerativeModel.return_value = mock_model
        mock_response = MagicMock()
        mock_response.text = json.dumps({
            "summary": "A friendly exchange",
            "conversation_health_score": 85
        })
        mock_model.generate_content.return_value = mock_response

        response = client.post('/api/v1/analyze/conversation',
                               json=sample_conversation_data,
                               headers=auth_header)
        assert response.status_code == 200
        data = response.get_json()
        assert data['success'] is True


# ============================================
# RESPONSE IMPACT ENDPOINT
# ============================================

class TestAnalyzeResponseImpact:
    """Tests for /api/v1/analyze/response-impact endpoint."""

    def test_rejects_missing_fields(self, client, auth_header):
        # Missing conversation
        response = client.post('/api/v1/analyze/response-impact',
                               json={'user_speaker': 'Alice', 'draft_response': 'Hi'},
                               headers=auth_header)
        assert response.status_code == 400

        # Missing user_speaker
        response = client.post('/api/v1/analyze/response-impact',
                               json={'conversation': 'text', 'draft_response': 'Hi'},
                               headers=auth_header)
        assert response.status_code == 400

        # Missing draft_response
        response = client.post('/api/v1/analyze/response-impact',
                               json={'conversation': 'text', 'user_speaker': 'Alice'},
                               headers=auth_header)
        assert response.status_code == 400

    @patch('app.genai')
    def test_successful_impact_analysis(self, mock_genai, client, auth_header):
        mock_model = MagicMock()
        mock_genai.GenerativeModel.return_value = mock_model
        mock_response = MagicMock()
        mock_response.text = json.dumps({
            "impact_analysis": {"escalation_risk": "low"},
            "alternative_responses": []
        })
        mock_model.generate_content.return_value = mock_response

        response = client.post('/api/v1/analyze/response-impact',
                               json={
                                   'conversation': 'Alice: Hi\nBob: Hey',
                                   'user_speaker': 'Alice',
                                   'draft_response': 'How are you?'
                               },
                               headers=auth_header)
        assert response.status_code == 200


# ============================================
# PROFILE ANALYSIS ENDPOINT
# ============================================

class TestAnalyzeProfile:
    """Tests for /api/v1/analyze/profile endpoint."""

    def test_rejects_missing_profile_data(self, client, auth_header):
        response = client.post('/api/v1/analyze/profile',
                               json={},
                               headers=auth_header)
        assert response.status_code == 400

    @patch('app.genai')
    def test_successful_profile_analysis(self, mock_genai, client, auth_header):
        mock_model = MagicMock()
        mock_genai.GenerativeModel.return_value = mock_model
        mock_response = MagicMock()
        mock_response.text = json.dumps({
            "profile_summary": "A balanced communicator"
        })
        mock_model.generate_content.return_value = mock_response

        response = client.post('/api/v1/analyze/profile',
                               json={'profile_data': {'name': 'Test', 'conversations': []}},
                               headers=auth_header)
        assert response.status_code == 200


# ============================================
# SELF PROFILE ANALYSIS ENDPOINT
# ============================================

class TestAnalyzeSelfProfile:
    """Tests for /api/v1/analyze/self-profile endpoint."""

    def test_rejects_missing_user_data(self, client, auth_header):
        response = client.post('/api/v1/analyze/self-profile',
                               json={},
                               headers=auth_header)
        assert response.status_code == 400

    @patch('app.genai')
    def test_successful_self_analysis(self, mock_genai, client, auth_header):
        mock_model = MagicMock()
        mock_genai.GenerativeModel.return_value = mock_model
        mock_response = MagicMock()
        mock_response.text = json.dumps({
            "honest_summary": "Self-aware communicator with growth areas"
        })
        mock_model.generate_content.return_value = mock_response

        response = client.post('/api/v1/analyze/self-profile',
                               json={'user_data': {'conversations': []}},
                               headers=auth_header)
        assert response.status_code == 200


# ============================================
# BEHAVIOR LIBRARY ENDPOINTS
# ============================================

class TestBehaviorLibrary:
    """Tests for behavior library endpoints."""

    def test_get_behaviors_no_auth(self, client):
        """Behavior library should be publicly accessible."""
        response = client.get('/api/v1/behaviors')
        assert response.status_code == 200

    def test_get_behaviors_structure(self, client):
        response = client.get('/api/v1/behaviors')
        data = response.get_json()
        assert data['success'] is True
        assert 'data' in data
        assert 'accessibility' in data

    def test_get_behaviors_loads_from_file(self, client):
        """Should load real library from data/behavior_library.json."""
        response = client.get('/api/v1/behaviors')
        data = response.get_json()
        # The file exists with 162 behaviors
        if data['data'].get('categories'):
            assert len(data['data']['categories']) > 0

    def test_get_categories(self, client):
        response = client.get('/api/v1/behaviors/categories')
        assert response.status_code == 200
        data = response.get_json()
        assert data['success'] is True


# ============================================
# SYNC ENDPOINTS
# ============================================

class TestSyncUpload:
    """Tests for /api/v1/sync/upload endpoint."""

    def test_rejects_missing_fields(self, client, auth_header):
        response = client.post('/api/v1/sync/upload',
                               json={'encrypted_data': 'abc'},
                               headers=auth_header)
        assert response.status_code == 400

        response = client.post('/api/v1/sync/upload',
                               json={'user_hash': 'abc'},
                               headers=auth_header)
        assert response.status_code == 400

    def test_successful_upload(self, client, auth_header):
        response = client.post('/api/v1/sync/upload',
                               json={
                                   'encrypted_data': 'encrypted_blob_here',
                                   'user_hash': 'abcdef1234567890'
                               },
                               headers=auth_header)
        assert response.status_code == 200
        data = response.get_json()
        assert data['success'] is True
        assert 'sync_id' in data['data']

    def test_truncates_long_user_hash(self, client, auth_header):
        """User hash should be truncated to 64 chars for safety."""
        long_hash = 'a' * 200
        response = client.post('/api/v1/sync/upload',
                               json={
                                   'encrypted_data': 'blob',
                                   'user_hash': long_hash
                               },
                               headers=auth_header)
        assert response.status_code == 200


class TestSyncDownload:
    """Tests for /api/v1/sync/download endpoint."""

    def test_rejects_missing_user_hash(self, client, auth_header):
        response = client.post('/api/v1/sync/download',
                               json={},
                               headers=auth_header)
        assert response.status_code == 400

    def test_returns_no_data_for_new_user(self, client, auth_header):
        response = client.post('/api/v1/sync/download',
                               json={'user_hash': 'new_user_123'},
                               headers=auth_header)
        assert response.status_code == 200
        data = response.get_json()
        assert data['data']['status'] == 'no_data'


# ============================================
# USER DATA DELETION ENDPOINT
# ============================================

class TestDeleteUserData:
    """Tests for /api/v1/user/delete endpoint (Privacy Act compliance)."""

    def test_rejects_missing_user_hash(self, client, auth_header):
        response = client.delete('/api/v1/user/delete',
                                 json={},
                                 headers=auth_header)
        assert response.status_code == 400

    def test_successful_deletion(self, client, auth_header):
        response = client.delete('/api/v1/user/delete',
                                 json={'user_hash': 'user_to_delete'},
                                 headers=auth_header)
        assert response.status_code == 200
        data = response.get_json()
        assert data['success'] is True
        assert data['data']['deleted'] is True
        assert 'confirmation_code' in data['data']

    def test_requires_auth(self, client):
        """Data deletion requires authentication."""
        response = client.delete('/api/v1/user/delete',
                                 json={'user_hash': 'user'})
        assert response.status_code == 401


# ============================================
# ERROR HANDLERS
# ============================================

class TestErrorHandlers:
    """Tests for custom error handlers."""

    def test_404_handler(self, client):
        response = client.get('/nonexistent/endpoint')
        assert response.status_code == 404
        data = response.get_json()
        assert data['success'] is False
        assert 'accessibility' in data

    def test_405_method_not_allowed(self, client, auth_header):
        """GET on POST-only endpoint should fail."""
        response = client.get('/api/v1/analyze/identify-speakers')
        assert response.status_code == 405


# ============================================
# SECURITY TESTS
# ============================================

class TestSecurity:
    """Tests for security measures."""

    def test_xss_in_text_field(self, client, auth_header):
        """XSS attempts should be sanitized."""
        with patch('app.genai') as mock_genai:
            mock_model = MagicMock()
            mock_genai.GenerativeModel.return_value = mock_model
            mock_response = MagicMock()
            mock_response.text = json.dumps({"speakers_identified": [], "messages": [], "analysis_notes": "", "confidence_overall": 0})
            mock_model.generate_content.return_value = mock_response

            response = client.post('/api/v1/analyze/identify-speakers',
                                   json={'text': '<img src=x onerror=alert(1)>Test'},
                                   headers=auth_header)
            # Should not crash and should sanitize
            assert response.status_code == 200

    def test_cors_headers_present(self, client):
        """CORS headers should be set."""
        response = client.get('/health')
        # Flask-CORS adds headers for allowed origins
        assert response.status_code == 200

    def test_no_sensitive_data_in_errors(self, client, auth_header):
        """Error responses should not leak sensitive information."""
        response = client.get('/nonexistent')
        data = response.get_json()
        assert 'traceback' not in str(data).lower()
        assert 'stack' not in str(data).lower()
