import os
import json
import smtplib
import logging
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from flask import Flask, request, jsonify
from flask_cors import CORS
import google.generativeai as genai
from dotenv import load_dotenv

# --- CONFIGURATION ---
load_dotenv()
app = Flask(__name__)

# Configure Logging
logging.basicConfig(level=logging.INFO)

# Allow CORS for app communication
CORS(app)

API_KEY = os.getenv("GEMINI_API_KEY")
EMAIL_HOST = os.getenv("EMAIL_HOST", "smtp.gmail.com")
EMAIL_PORT = int(os.getenv("EMAIL_PORT", 587))
EMAIL_USER = os.getenv("EMAIL_USER")
EMAIL_PASS = os.getenv("EMAIL_PASS")
ALERT_RECEIVER = "info@digitalabcs.com.au"

if not API_KEY:
    logging.error("CRITICAL WARNING: GEMINI_API_KEY is missing from .env")
else:
    genai.configure(api_key=API_KEY)


# --- SYSTEM PROMPT (PRESERVED EXACTLY) ---
SYSTEM_INSTRUCTION = """
You are an expert Linguistic Analyst specializing in multi-perspective communication analysis and intent detection.

YOUR ROLE:
Analyze conversations of ANY size (1 on 1 OR Group) to identify intents, alliances, hidden meanings, communication styles, rhetorical strategies, and underlying intent through objective linguistic analysis FROM EVERY PARTICIPANT'S PERSPECTIVE. Provide actionable insights for all parties involved.

UNLABELED RAW DATA INPUT HANDLING:
The user input may be raw "Copy/Paste" text (e.g., Apple Messages, WhatsApp, SMS) where speaker labels are MISSING.

CRITICAL DETECTION RULES:
1. **DETECT SPEAKER COUNT** First, count the distinct participants based on linguistic cues.
2. **LOOK FOR NAMES:** If the text contains labels like "John: Hello" or "Mom: Stop it", you MUST use "John" and "Mom" as the speaker labels. DO NOT use "Speaker A" if a name is available.
3. **STRICT SEGMENTATION:** You must correctly attribute every sentence to the correct speaker.
5. **ADAPT ANALYSIS** - If 2 speakers: Focus on the relationship dynamics between them. (Speaker A vs. Speaker B).
    - If 3+ speakers: Focus on Group Dynamics (Alliances, Outliers, Power Structures).
6. **DETECT VOICE SHIFTS:** You MUST infer when speakers change based on:
   - Context clues (defensive statement -> clarifying statement)
   - Pronoun usage changes ("I think you..." -> "No, I didn't...")
   - Response patterns (question -> answer, accusation -> defense)
   - Topic shifts and conversational turn-taking
   - Temporal markers ("earlier you said..." indicates response)
   - Contrasting emotional tones (anger -> calm explanation)
7. **TREAT AS MULTI-PARTY INTERACTION:** Never analyze as a monologue. Always assume there is an interlocutor(s) responding, even if not explicitly shown.
8. **IGNORE FORMATTING NOISE:** Disregard typos ("your" vs "you're"), inconsistent newlines, missing punctuation, or casual text abbreviations. These can be common in digital communication, and may provide clues to whom is speaking.

CORE ANALYTICAL PRINCIPLES:
1. **Objectivity**: Describe what the language reveals, NOT what the person "is"
2. **Observable Patterns**: Focus on word choice, sentence structure, tone markers, rhetorical devices
3. **Surface vs. Depth**: Distinguish between explicit content and underlying communicative function
4. **Multi-Lens Analysis**: Examine from EACH participant's emotional, strategic, and relational perspective
5. **Evidence-Based**: Cite specific linguistic features supporting each interpretation

STRICT ETHICAL BOUNDARIES:
NO psychological/medical diagnoses (e.g., "narcissist," "borderline," "manipulative personality")
USE linguistic descriptors: "high-conflict language," "persuasive framing," "defensive rhetoric," "guilt-inducing phrasing"

NO character judgments ("they are selfish," "bad person")
DESCRIBE text properties: "language patterns suggest prioritization of speaker's needs," "text employs blame-shifting tactics"

NO speculation beyond textual evidence
GROUND insights in observable linguistic features

COMPREHENSIVE ANALYSIS FRAMEWORK:

For EACH PARTICIPANT analyze:

EMOTIONAL DIMENSION
- Tone markers (formal/informal, warm/cold, urgent/relaxed)
- Emotional valence (positive, negative, neutral, mixed)
- Stress indicators (repetition, capitalization, punctuation, silent pauses)
- Vulnerability markers (admissions, apologies, concessions)

STRATEGIC DIMENSION
- Intent signals (requesting, defending, persuading, deflecting)
- Rhetorical strategies (emotion, logic, authority, identity)
- Framing tactics (victim, hero, mediator positioning)
- Information control (withholding, revealing, redirecting)

RELATIONAL DIMENSION
- Power dynamics (assertive, submissive, collaborative language)
- Boundary setting (clear, porous, rigid, absent)
- Reciprocity patterns (balanced, one-sided, transactional)
- Empathy signals (perspective-taking, validation, dismissal)

UNDERLYING NEEDS (often unspoken)
- Recognition, validation, control, safety, autonomy, connection
- What they're REALLY asking for beneath the words

DEEP DIVE METHODOLOGY:
For the "deep_dive" field, identify specific PSYCHOLOGICAL/LINGUISTIC TACTICS:
- Double Bind: Creates no-win scenarios ("if you do X you're bad, if you don't you're also bad")
- DARVO: Deny, Attack, Reverse Victim & Offender
- Gaslighting Language: Undermines other's perception of reality
- Guilt Induction: Uses obligation, shame, or emotional debt
- Stonewalling: Shuts down communication through withdrawal
- Reactive Devaluation: Dismisses other's perspective due to who said it
- Minimization: Downplays harm or concerns
- Deflection: Redirects focus from the issue
- False Equivalence: "Both sides" argument where contexts differ
- Emotional Flooding: Overwhelming with intensity to prevent rational response

MUST cite specific phrases demonstrating the tactic.

CRITICAL OUTPUT REQUIREMENT:
You must output VALID JSON only. No markdown formatting.

Your JSON must match this structure exactly:
{
  "transcript_log": [
    {"speaker": "Exact Name or Label", "text": "The exact sentence spoken"}
  ],
  "speakers": [
    {
      "label": "Speaker Name",
      "likely_emotional_state": "Emotion",
      "translation": "What they really mean",
      "deep_dive": "Specific tactic used (Gaslighting, DARVO, etc) with evidence.",
      "advice": "Actionable advice for dealing with this person."
    }
  ],
  "conversation_overview": {
    "detected_speakers": 2,
    "primary_issue": "Summary of conflict"
  }
}

RULES:
1. Identify speakers by name if present in text.
2. If no names, use "Speaker A", "Speaker B".
3. 'transcript_log' MUST list every sentence segment with the assigned speaker so the user can verify accuracy.
4. 'deep_dive' should identify psychological tactics (Double Bind, Projection, Stonewalling, etc.).
"""

# --- ROBUST AI HANDLERS ---

def clean_and_parse_json(text):
    """
    Cleans AI response to ensure valid JSON.
    """
    try:
        clean = text.strip()
        # Remove Markdown formatting if present
        if clean.startswith("```json"):
            clean = clean[7:]
        if clean.startswith("```"):
            clean = clean[3:]
        if clean.endswith("```"):
            clean = clean[:-3]
        
        return json.loads(clean.strip())
    except Exception as e:
        logging.error(f"JSON Parsing Failed: {e}. Raw text: {text}")
        return {
            "error": "JSON_PARSE_ERROR", 
            "message": "The AI analysis could not be formatted correctly.",
            "transcript_log": [],
            "speakers": [] 
        }

def generate_with_fallback(prompt, system_instruction=None, json_mode=True):
    # FIXED: Removed the \t tab character that was causing connection errors
    models_to_try = ['gemini-1.5-flash', 'gemini-1.5-pro']
    
    last_error = None

    for model_name in models_to_try:
        try:
            logging.info(f"Attempting generation with model: {model_name}")
            
            model = genai.GenerativeModel(
                model_name=model_name,
                system_instruction=system_instruction
            )
            
            # Safety settings to prevent blocking analysis of heated arguments
            safety_settings = [
                {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_ONLY_HIGH"},
                {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_ONLY_HIGH"},
                {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
                {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_ONLY_HIGH"},
            ]

            response = model.generate_content(prompt, safety_settings=safety_settings)
            
            if json_mode:
                return clean_and_parse_json(response.text)
            return response.text

        except Exception as e:
            logging.warning(f"Model {model_name} failed: {e}")
            last_error = e
            continue
    
    # Return a graceful error structure instead of crashing
    return {
        "error": "AI_SERVICE_UNAVAILABLE",
        "message": "Analysis service is currently busy. Please try again in a moment.",
        "transcript_log": [],
        "speakers": []
    }
    
# --- API ENDPOINTS ---

@app.route('/analyze', methods=['POST'])
def analyze_text():
    try:
        data = request.json
        user_text = data.get('text', '')

        if not user_text:
            return jsonify({"error": "No text provided"}), 400

        prompt = f"Analyze this text. Output ONLY valid JSON: {user_text}"
        
        result = generate_with_fallback(prompt, system_instruction=SYSTEM_INSTRUCTION, json_mode=True)
        return jsonify(result)

    except Exception as e:
        logging.error(f"Analyze Error: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/analyze-profile', methods=['POST'])
def analyze_profile():
    try:
        data = request.json
        speaker_name = data.get('name', 'Target')
        logs = data.get('logs', [])
        
        history = "\n".join([f"[{log.get('date', 'Unknown')}] {log.get('text', '')}" for log in logs[-15:]])

        prompt = f"""
        Target: "{speaker_name}"
        History: {history}
        
        Build a behavioral profile. Output STRICT JSON ONLY:
        {{
          "risk_level": "Low/Medium/High/Critical",
          "pattern": "Name of dominant pattern",
          "traits": ["Trait 1", "Trait 2"],
          "summary": "Short explanation.",
          "recommendation": "Strategic advice."
        }}
        """
        result = generate_with_fallback(prompt, json_mode=True)
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/simulate', methods=['POST'])
def simulate_response():
    try:
        data = request.json
        context = data.get('context', '')
        draft = data.get('draft', '')
        
        prompt = f"""
        CONTEXT: {context}
        DRAFT REPLY: {draft}
        
        Simulate reaction. OUTPUT JSON ONLY:
        {{ "score": 85, "response": "Likely Reaction", "analysis": "Why." }}
        """
        result = generate_with_fallback(prompt, json_mode=True)
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy", "version": "1.1.0"}), 200

if __name__ == '__main__':
    # Using 0.0.0.0 allows connections from external devices/emulators
    app.run(debug=True, host='0.0.0.0', port=8080)