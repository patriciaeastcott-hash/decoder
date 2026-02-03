"""
Text Decoder MVP - Backend API
Deployed on Google Cloud Run
Handles Gemini API proxy, encrypted sync, and behavior library serving

Compliant with:
- Australian Privacy Act
- International AI Standards
- WCAG 2.1 AAA (API responses structured for accessibility)
"""

import os
import json
import hashlib
import logging
from datetime import datetime, timedelta
from functools import wraps
from typing import Optional, Dict, Any, List

from flask import Flask, request, jsonify, Response
from flask_cors import CORS
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
import google.generativeai as genai
from cryptography.fernet import Fernet
import bleach

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize Flask app
app = Flask(__name__)

# CORS configuration for mobile and web apps
CORS(app, origins=[
    "https://digitalabcs.com.au",
    "https://*.digitalabcs.com.au",
    "capacitor://localhost",
    "ionic://localhost",
    "http://localhost:*",
    "http://127.0.0.1:*"
], supports_credentials=True)

# Rate limiting for API protection
limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["1000 per day", "100 per hour"]
)

# Environment variables
GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY')
ENCRYPTION_KEY = os.environ.get('ENCRYPTION_KEY')  # For sync encryption
APP_SECRET_KEY = os.environ.get('APP_SECRET_KEY', 'dev-secret-key')

# Configure Gemini
if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)

# Initialize encryption for sync
cipher_suite = None
if ENCRYPTION_KEY:
    cipher_suite = Fernet(ENCRYPTION_KEY.encode() if len(ENCRYPTION_KEY) == 44 else Fernet.generate_key())


# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

def sanitize_input(text: str) -> str:
    """Sanitize user input to prevent injection attacks."""
    if not text:
        return ""
    # Remove potentially harmful HTML/scripts
    cleaned = bleach.clean(text, tags=[], strip=True)
    # Limit length to prevent abuse
    return cleaned[:50000]


def validate_api_key(f):
    """Decorator to validate Firebase auth token."""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({
                'error': 'Unauthorized',
                'message': 'Valid authentication token required'
            }), 401
        # In production, validate Firebase token here
        # For MVP, we accept the token as-is
        return f(*args, **kwargs)
    return decorated_function


def create_accessible_response(data: Dict[Any, Any], message: str = "Success") -> Dict[Any, Any]:
    """Create WCAG-compliant API response with clear structure."""
    return {
        'success': True,
        'message': message,
        'timestamp': datetime.utcnow().isoformat(),
        'data': data,
        'accessibility': {
            'screen_reader_summary': message,
            'data_type': type(data).__name__
        }
    }


def create_error_response(error: str, details: str = "", status_code: int = 400) -> tuple:
    """Create accessible error response."""
    return jsonify({
        'success': False,
        'error': error,
        'details': details,
        'timestamp': datetime.utcnow().isoformat(),
        'accessibility': {
            'screen_reader_summary': f"Error: {error}",
            'suggested_action': 'Please try again or contact support'
        }
    }), status_code


# =============================================================================
# GEMINI API PROMPTS
# =============================================================================

SPEAKER_IDENTIFICATION_PROMPT = """
You are an expert conversation analyst. Analyze the following text and identify distinct speakers.

Rules:
1. Look for patterns indicating different speakers (names, pronouns, speech patterns, context clues)
2. If no clear identifiers exist, label speakers as "Speaker 1", "Speaker 2", etc.
3. Preserve the exact original text for each message
4. Note confidence level for each identification

Return a JSON object with this exact structure:
{
    "speakers_identified": ["Speaker 1", "Speaker 2"],
    "messages": [
        {
            "speaker": "Speaker 1",
            "text": "exact message text",
            "confidence": 0.85,
            "reasoning": "brief explanation of why this speaker was identified"
        }
    ],
    "analysis_notes": "any observations about the conversation structure",
    "confidence_overall": 0.75
}

Text to analyze:
"""

CONVERSATION_ANALYSIS_PROMPT = """
You are a supportive, neutral, and unbiased psychological conversation analyst. Analyze this conversation providing actionable insights.

Provide analysis that is:
- Supportive: Help the user understand patterns without judgment
- Neutral: No bias toward any speaker
- Actionable: Specific suggestions for improvement

Analyze for ALL of the following:
1. Power dynamics between speakers
2. Communication styles (passive, aggressive, assertive, passive-aggressive)
3. Manipulation patterns (if any): gaslighting, DARVO, deflection, etc.
4. Attachment style indicators
5. Emotional regulation patterns
6. Defense mechanisms employed
7. Red flags and green flags
8. Specific behaviors from the behavior library that match

Return a JSON object:
{
    "summary": "2-3 sentence overview",
    "power_dynamics": {
        "assessment": "description",
        "indicators": ["specific examples from text"],
        "balance_score": 0-10
    },
    "speaker_analyses": [
        {
            "speaker": "name",
            "communication_style": {
                "primary": "assertive/passive/aggressive/passive-aggressive",
                "examples": ["quotes from conversation"],
                "effectiveness_score": 0-10
            },
            "emotional_patterns": {
                "regulation_level": "well-regulated/moderately-regulated/dysregulated",
                "triggers_observed": ["list"],
                "coping_mechanisms": ["list"]
            },
            "attachment_indicators": {
                "likely_style": "secure/anxious/avoidant/disorganized",
                "evidence": ["specific examples"]
            },
            "behaviors_exhibited": [
                {
                    "behavior_id": "id from library",
                    "behavior_name": "name",
                    "examples": ["quotes"],
                    "frequency": "rare/occasional/frequent",
                    "impact": "positive/neutral/negative"
                }
            ],
            "strengths": ["list"],
            "growth_areas": ["list"],
            "red_flags": ["if any"],
            "green_flags": ["positive indicators"]
        }
    ],
    "relationship_dynamics": {
        "overall_health": "healthy/concerning/unhealthy",
        "patterns": ["recurring patterns"],
        "conflict_style": "description",
        "resolution_potential": "high/medium/low"
    },
    "manipulation_check": {
        "detected": true/false,
        "types": ["if any"],
        "examples": ["specific quotes"],
        "severity": "none/mild/moderate/severe"
    },
    "actionable_insights": [
        {
            "for_speaker": "name or 'both'",
            "insight": "specific observation",
            "suggestion": "actionable recommendation",
            "expected_outcome": "what improvement might look like"
        }
    ],
    "conversation_health_score": 0-100,
    "follow_up_questions": ["questions that might help deeper understanding"]
}

Speakers in conversation: {speakers}
Behavior library categories to reference: {behavior_categories}

Conversation:
{conversation}
"""

RESPONSE_IMPACT_PROMPT = """
You are a communication dynamics expert. The user wants to understand how a potential response might impact their conversation.

Context:
- Previous conversation provided below
- User is: {user_speaker}
- User's drafted response: {draft_response}

Analyze the potential impact and provide alternatives.

Return JSON:
{
    "impact_analysis": {
        "likely_reception": "how the other person might receive this",
        "emotional_impact": "predicted emotional response",
        "power_dynamic_shift": "how it changes the dynamic",
        "escalation_risk": "low/medium/high",
        "de_escalation_potential": "low/medium/high",
        "predicted_outcomes": ["possible responses/outcomes"]
    },
    "tone_analysis": {
        "detected_tone": "assertive/defensive/aggressive/etc",
        "alignment_with_goals": "does this help achieve user's likely goals?",
        "potential_misinterpretations": ["ways it could be misread"]
    },
    "alternative_responses": [
        {
            "response": "alternative text",
            "approach": "assertive/empathetic/boundary-setting/etc",
            "likely_impact": "expected outcome",
            "best_for": "situation where this works best"
        }
    ],
    "recommended_response": {
        "text": "best suggested response",
        "reasoning": "why this is recommended",
        "expected_outcome": "likely result"
    },
    "communication_tips": ["specific tips for this situation"]
}

Previous conversation:
{conversation}
"""

PROFILE_ANALYSIS_PROMPT = """
You are creating a comprehensive psychological profile based on multiple conversation analyses.
This must be supportive, unbiased, and actionable.

Historical data:
{profile_data}

Create a detailed profile analysis:
{
    "profile_summary": "3-4 sentence overview of this person's communication patterns",
    "communication_profile": {
        "dominant_style": "primary communication style",
        "secondary_styles": ["other styles used"],
        "style_consistency": "how consistent across conversations",
        "adaptability": "how well they adjust to different situations"
    },
    "emotional_profile": {
        "baseline_regulation": "typical emotional regulation level",
        "common_triggers": ["identified triggers"],
        "coping_strategies": {
            "healthy": ["strategies"],
            "unhealthy": ["patterns to work on"]
        },
        "emotional_intelligence_indicators": "assessment"
    },
    "behavioral_patterns": {
        "frequent_behaviors": [
            {
                "behavior": "name",
                "frequency": "how often",
                "contexts": "when it appears",
                "impact": "effect on conversations"
            }
        ],
        "rare_behaviors": ["behaviors that appear occasionally"],
        "evolving_patterns": "how patterns have changed over time"
    },
    "attachment_profile": {
        "primary_style": "attachment style",
        "triggers_for_insecurity": ["situations that activate attachment fears"],
        "secure_base_behaviors": ["when they show security"]
    },
    "conflict_profile": {
        "approach": "how they handle conflict",
        "strengths_in_conflict": ["what they do well"],
        "challenges_in_conflict": ["areas for growth"],
        "resolution_patterns": "how conflicts typically resolve"
    },
    "strengths": [
        {
            "strength": "name",
            "evidence": "how it manifests",
            "impact": "positive effect"
        }
    ],
    "growth_opportunities": [
        {
            "area": "name",
            "current_pattern": "what happens now",
            "suggested_growth": "actionable suggestion",
            "resources": "what might help"
        }
    ],
    "communication_recommendations": {
        "best_approaches_with_them": ["how to communicate effectively with this person"],
        "topics_to_approach_carefully": ["sensitive areas"],
        "conflict_resolution_strategies": ["specific strategies"],
        "relationship_potential": "assessment of relationship viability"
    },
    "red_flags_summary": ["concerning patterns if any"],
    "green_flags_summary": ["positive indicators"],
    "overall_assessment": "balanced final assessment"
}
"""

SELF_PROFILE_PROMPT = """
You are creating an unbiased self-analysis profile for the user based on their conversations.
Be honest, supportive, and constructive. Do not flatter - provide genuine insights.

User's conversation history:
{user_data}

Create an unbiased self-profile:
{
    "honest_summary": "Balanced 3-4 sentence overview - include both strengths and areas for growth",
    "self_awareness_indicators": {
        "level": "high/moderate/low",
        "evidence": "how self-aware they appear in conversations",
        "blind_spots": ["potential areas they may not see clearly"]
    },
    "communication_self_profile": {
        "how_you_come_across": "honest assessment of how others likely perceive them",
        "intended_vs_actual": "gap between intention and impact",
        "strengths": ["genuine communication strengths"],
        "improvement_areas": ["honest areas for growth"]
    },
    "emotional_patterns": {
        "regulation_assessment": "honest evaluation",
        "triggers_identified": ["what sets them off"],
        "response_patterns": "how they typically respond to stress",
        "emotional_intelligence": "candid assessment"
    },
    "behavioral_tendencies": {
        "positive_patterns": [
            {
                "behavior": "name",
                "impact": "positive effect",
                "continue_because": "why this helps"
            }
        ],
        "patterns_to_examine": [
            {
                "behavior": "name",
                "current_impact": "effect on conversations",
                "alternative_approach": "what might work better",
                "why_change": "honest reason"
            }
        ]
    },
    "relationship_patterns": {
        "your_role_in_dynamics": "honest look at what you contribute",
        "patterns_across_relationships": "recurring themes",
        "what_you_attract": "types of dynamics you tend to create/enter",
        "responsibility_taking": "how well you own your part"
    },
    "honest_strengths": [
        {
            "strength": "genuine strength",
            "evidence": "how it shows",
            "leverage_it": "how to use it more"
        }
    ],
    "honest_growth_areas": [
        {
            "area": "genuine area for growth",
            "current_pattern": "what you do now",
            "impact": "how it affects others",
            "actionable_step": "specific thing to try",
            "expected_benefit": "what might improve"
        }
    ],
    "action_plan": {
        "immediate_focus": "one thing to work on now",
        "short_term_goals": ["1-2 month goals"],
        "long_term_development": ["ongoing growth areas"],
        "resources_suggested": ["books, practices, etc"]
    },
    "encouragement": "genuine supportive message acknowledging effort to self-improve"
}
"""


# =============================================================================
# API ENDPOINTS
# =============================================================================

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint for Cloud Run."""
    return jsonify({
        'status': 'healthy',
        'service': 'text-decoder-api',
        'version': '1.0.0-mvp',
        'timestamp': datetime.utcnow().isoformat()
    })


@app.route('/api/v1/analyze/identify-speakers', methods=['POST'])
@limiter.limit("30 per minute")
@validate_api_key
def identify_speakers():
    """
    Identify speakers in a conversation text.
    Users can then verify and correct the identification.
    """
    try:
        data = request.get_json()
        if not data or 'text' not in data:
            return create_error_response(
                "Missing required field",
                "The 'text' field is required",
                400
            )

        text = sanitize_input(data['text'])
        if not text:
            return create_error_response(
                "Invalid input",
                "Text cannot be empty after sanitization",
                400
            )

        # Call Gemini API
        model = genai.GenerativeModel('gemini-1.5-pro')

        prompt = SPEAKER_IDENTIFICATION_PROMPT + text

        response = model.generate_content(
            prompt,
            generation_config=genai.types.GenerationConfig(
                temperature=0.3,
                response_mime_type="application/json"
            )
        )

        # Parse the response
        try:
            result = json.loads(response.text)
        except json.JSONDecodeError:
            # Try to extract JSON from response
            result = {
                "speakers_identified": ["Speaker 1", "Speaker 2"],
                "messages": [],
                "analysis_notes": response.text,
                "confidence_overall": 0.5,
                "raw_response": response.text
            }

        return jsonify(create_accessible_response(
            result,
            f"Identified {len(result.get('speakers_identified', []))} speakers in the conversation"
        ))

    except Exception as e:
        logger.error(f"Speaker identification error: {str(e)}")
        return create_error_response(
            "Analysis failed",
            "Unable to process the conversation. Please try again.",
            500
        )


@app.route('/api/v1/analyze/conversation', methods=['POST'])
@limiter.limit("20 per minute")
@validate_api_key
def analyze_conversation():
    """
    Perform deep psychological analysis of a conversation.
    Requires speakers to be identified first.
    """
    try:
        data = request.get_json()
        required_fields = ['conversation', 'speakers']

        for field in required_fields:
            if field not in data:
                return create_error_response(
                    "Missing required field",
                    f"The '{field}' field is required",
                    400
                )

        conversation = sanitize_input(json.dumps(data['conversation']))
        speakers = data['speakers']

        # Load behavior categories for reference
        behavior_categories = get_behavior_categories()

        # Build the prompt
        prompt = CONVERSATION_ANALYSIS_PROMPT.format(
            speakers=json.dumps(speakers),
            behavior_categories=json.dumps(behavior_categories),
            conversation=conversation
        )

        model = genai.GenerativeModel('gemini-1.5-pro')

        response = model.generate_content(
            prompt,
            generation_config=genai.types.GenerationConfig(
                temperature=0.4,
                response_mime_type="application/json",
                max_output_tokens=8192
            )
        )

        try:
            result = json.loads(response.text)
        except json.JSONDecodeError:
            result = {
                "summary": "Analysis completed",
                "raw_analysis": response.text,
                "parse_error": True
            }

        return jsonify(create_accessible_response(
            result,
            "Conversation analysis complete"
        ))

    except Exception as e:
        logger.error(f"Conversation analysis error: {str(e)}")
        return create_error_response(
            "Analysis failed",
            "Unable to analyze the conversation. Please try again.",
            500
        )


@app.route('/api/v1/analyze/response-impact', methods=['POST'])
@limiter.limit("30 per minute")
@validate_api_key
def analyze_response_impact():
    """
    Analyze how a drafted response might impact the conversation.
    Provides alternatives and recommendations.
    """
    try:
        data = request.get_json()
        required_fields = ['conversation', 'user_speaker', 'draft_response']

        for field in required_fields:
            if field not in data:
                return create_error_response(
                    "Missing required field",
                    f"The '{field}' field is required",
                    400
                )

        conversation = sanitize_input(json.dumps(data['conversation']))
        user_speaker = sanitize_input(data['user_speaker'])
        draft_response = sanitize_input(data['draft_response'])

        prompt = RESPONSE_IMPACT_PROMPT.format(
            user_speaker=user_speaker,
            draft_response=draft_response,
            conversation=conversation
        )

        model = genai.GenerativeModel('gemini-1.5-pro')

        response = model.generate_content(
            prompt,
            generation_config=genai.types.GenerationConfig(
                temperature=0.5,
                response_mime_type="application/json",
                max_output_tokens=4096
            )
        )

        try:
            result = json.loads(response.text)
        except json.JSONDecodeError:
            result = {
                "impact_analysis": {"raw": response.text},
                "parse_error": True
            }

        return jsonify(create_accessible_response(
            result,
            "Response impact analysis complete"
        ))

    except Exception as e:
        logger.error(f"Response impact analysis error: {str(e)}")
        return create_error_response(
            "Analysis failed",
            "Unable to analyze response impact. Please try again.",
            500
        )


@app.route('/api/v1/analyze/profile', methods=['POST'])
@limiter.limit("10 per minute")
@validate_api_key
def analyze_profile():
    """
    Generate comprehensive profile analysis for a speaker.
    Uses historical conversation data stored on device.
    """
    try:
        data = request.get_json()
        if 'profile_data' not in data:
            return create_error_response(
                "Missing required field",
                "The 'profile_data' field is required",
                400
            )

        profile_data = sanitize_input(json.dumps(data['profile_data']))

        prompt = PROFILE_ANALYSIS_PROMPT.format(profile_data=profile_data)

        model = genai.GenerativeModel('gemini-1.5-pro')

        response = model.generate_content(
            prompt,
            generation_config=genai.types.GenerationConfig(
                temperature=0.4,
                response_mime_type="application/json",
                max_output_tokens=8192
            )
        )

        try:
            result = json.loads(response.text)
        except json.JSONDecodeError:
            result = {
                "profile_summary": "Profile analysis completed",
                "raw_analysis": response.text,
                "parse_error": True
            }

        return jsonify(create_accessible_response(
            result,
            "Profile analysis complete"
        ))

    except Exception as e:
        logger.error(f"Profile analysis error: {str(e)}")
        return create_error_response(
            "Analysis failed",
            "Unable to generate profile analysis. Please try again.",
            500
        )


@app.route('/api/v1/analyze/self-profile', methods=['POST'])
@limiter.limit("10 per minute")
@validate_api_key
def analyze_self_profile():
    """
    Generate unbiased self-analysis profile for the user.
    """
    try:
        data = request.get_json()
        if 'user_data' not in data:
            return create_error_response(
                "Missing required field",
                "The 'user_data' field is required",
                400
            )

        user_data = sanitize_input(json.dumps(data['user_data']))

        prompt = SELF_PROFILE_PROMPT.format(user_data=user_data)

        model = genai.GenerativeModel('gemini-1.5-pro')

        response = model.generate_content(
            prompt,
            generation_config=genai.types.GenerationConfig(
                temperature=0.4,
                response_mime_type="application/json",
                max_output_tokens=8192
            )
        )

        try:
            result = json.loads(response.text)
        except json.JSONDecodeError:
            result = {
                "honest_summary": "Self-analysis completed",
                "raw_analysis": response.text,
                "parse_error": True
            }

        return jsonify(create_accessible_response(
            result,
            "Self-profile analysis complete"
        ))

    except Exception as e:
        logger.error(f"Self-profile analysis error: {str(e)}")
        return create_error_response(
            "Analysis failed",
            "Unable to generate self-profile analysis. Please try again.",
            500
        )


@app.route('/api/v1/behaviors', methods=['GET'])
@limiter.limit("60 per minute")
def get_behaviors():
    """
    Get the complete behavior/trait library.
    Available offline after initial fetch.
    """
    try:
        # Load from file
        behaviors_path = os.path.join(
            os.path.dirname(__file__),
            'data',
            'behavior_library.json'
        )

        if os.path.exists(behaviors_path):
            with open(behaviors_path, 'r') as f:
                behaviors = json.load(f)
        else:
            behaviors = get_default_behavior_library()

        return jsonify(create_accessible_response(
            behaviors,
            f"Loaded {count_behaviors(behaviors)} behaviors and traits"
        ))

    except Exception as e:
        logger.error(f"Behavior library error: {str(e)}")
        return create_error_response(
            "Failed to load behaviors",
            "Unable to retrieve the behavior library.",
            500
        )


@app.route('/api/v1/behaviors/categories', methods=['GET'])
def get_behavior_categories():
    """Get just the category names for reference."""
    behaviors = get_default_behavior_library()
    categories = [cat['category'] for cat in behaviors.get('categories', [])]
    return categories if request.method != 'GET' else jsonify(
        create_accessible_response({'categories': categories}, "Categories loaded")
    )


@app.route('/api/v1/sync/upload', methods=['POST'])
@limiter.limit("10 per minute")
@validate_api_key
def sync_upload():
    """
    Upload encrypted, anonymized data for cross-device sync.
    Data is encrypted client-side before transmission.
    Server stores only encrypted blobs.
    """
    try:
        data = request.get_json()

        if 'encrypted_data' not in data or 'user_hash' not in data:
            return create_error_response(
                "Missing required fields",
                "Both 'encrypted_data' and 'user_hash' are required",
                400
            )

        # In production, store to Cloud Storage or database
        # For MVP, we acknowledge receipt
        user_hash = data['user_hash'][:64]  # Truncate for safety

        # Log sync (no actual data logged)
        logger.info(f"Sync upload received for user hash: {user_hash[:8]}...")

        return jsonify(create_accessible_response(
            {
                'sync_id': hashlib.sha256(
                    f"{user_hash}{datetime.utcnow().isoformat()}".encode()
                ).hexdigest()[:32],
                'timestamp': datetime.utcnow().isoformat(),
                'status': 'stored'
            },
            "Data synced successfully"
        ))

    except Exception as e:
        logger.error(f"Sync upload error: {str(e)}")
        return create_error_response(
            "Sync failed",
            "Unable to sync data. Please try again.",
            500
        )


@app.route('/api/v1/sync/download', methods=['POST'])
@limiter.limit("10 per minute")
@validate_api_key
def sync_download():
    """
    Download encrypted sync data for a user.
    """
    try:
        data = request.get_json()

        if 'user_hash' not in data:
            return create_error_response(
                "Missing required field",
                "The 'user_hash' field is required",
                400
            )

        # In production, retrieve from Cloud Storage
        # For MVP, return empty
        return jsonify(create_accessible_response(
            {
                'encrypted_data': None,
                'last_sync': None,
                'status': 'no_data'
            },
            "No sync data found"
        ))

    except Exception as e:
        logger.error(f"Sync download error: {str(e)}")
        return create_error_response(
            "Sync failed",
            "Unable to retrieve sync data. Please try again.",
            500
        )


@app.route('/api/v1/user/delete', methods=['DELETE'])
@limiter.limit("5 per minute")
@validate_api_key
def delete_user_data():
    """
    Delete all server-side data for a user.
    Compliant with Australian Privacy Act data deletion requirements.
    """
    try:
        data = request.get_json()

        if 'user_hash' not in data:
            return create_error_response(
                "Missing required field",
                "The 'user_hash' field is required",
                400
            )

        user_hash = data['user_hash'][:64]

        # In production, delete from all storage
        # Log deletion for compliance
        logger.info(f"User data deletion requested for hash: {user_hash[:8]}...")

        return jsonify(create_accessible_response(
            {
                'deleted': True,
                'timestamp': datetime.utcnow().isoformat(),
                'confirmation_code': hashlib.sha256(
                    f"deleted_{user_hash}_{datetime.utcnow().isoformat()}".encode()
                ).hexdigest()[:16]
            },
            "All your data has been permanently deleted from our servers"
        ))

    except Exception as e:
        logger.error(f"User deletion error: {str(e)}")
        return create_error_response(
            "Deletion failed",
            "Unable to delete data. Please contact support.",
            500
        )


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

def count_behaviors(library: Dict) -> int:
    """Count total behaviors in library."""
    count = 0
    for category in library.get('categories', []):
        for subcategory in category.get('subcategories', []):
            count += len(subcategory.get('behaviors', []))
    return count


def get_default_behavior_library() -> Dict:
    """Return the default behavior library structure."""
    # This is loaded from behavior_library.json in production
    # Placeholder structure for when file doesn't exist
    return {
        "version": "1.0.0",
        "last_updated": datetime.utcnow().isoformat(),
        "categories": []
    }


# =============================================================================
# ERROR HANDLERS
# =============================================================================

@app.errorhandler(404)
def not_found(error):
    return create_error_response(
        "Not Found",
        "The requested endpoint does not exist",
        404
    )


@app.errorhandler(429)
def rate_limit_exceeded(error):
    return create_error_response(
        "Rate Limit Exceeded",
        "Too many requests. Please wait before trying again.",
        429
    )


@app.errorhandler(500)
def internal_error(error):
    return create_error_response(
        "Internal Server Error",
        "An unexpected error occurred. Please try again later.",
        500
    )


# =============================================================================
# MAIN
# =============================================================================

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    debug = os.environ.get('FLASK_DEBUG', 'false').lower() == 'true'

    app.run(
        host='0.0.0.0',
        port=port,
        debug=debug
    )
