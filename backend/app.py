import os
import json
import smtplib
import logging
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import google.generativeai as genai
from dotenv import load_dotenv

# --- CONFIGURATION ---
load_dotenv()
app = Flask(__name__)

# Configure Logging
logging.basicConfig(level=logging.INFO)

# 1. CORS CONFIGURATION
# Set to allow all for debugging, restrict in production if needed
CORS(app, resources={r"/*": {"origins": "*"}})

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

OUTPUT FORMAT (STRICT JSON):
{
  "conversation_overview": {
    "detected_speakers": 2,
    "speaker_labels": ["Speaker A", "Speaker B"],
    "overall_dynamic": "Brief description of interaction type (e.g., 'Conflict escalation with unbalanced power dynamics')",
    "conflict_level": "Low / Medium / High",
    "primary_issue": "Core disagreement or tension point"
  },
  
  "speakers": [
    {
      "label": "Speaker A",
      "likely_emotional_state": "Primary emotion + secondary emotions",
      "communication_goals": ["goal1", "goal2", "goal3"],
      "linguistic_patterns": ["observable pattern1", "pattern2"],
      "rhetorical_strategies": ["strategy1", "strategy2"],
      "unmet_needs": ["underlying need1", "need2"],
      "sentiment_category": "Defensive / Aggressive / Conciliatory / Neutral / Anxious / etc.",
      "translation": "Plain English: What Speaker A is really saying beneath the words",
      "deep_dive": "4-6 sentences identifying the SPECIFIC psychological/linguistic tactic being employed, with direct quote examples.",
      "potential_impact_on_others": "How this communication style likely affects the other speaker(s)",
      "advice": "Actionable guidance: What this speaker should understand about their communication and concrete next steps",
      "response_options": [
        {
          "style": "Diplomatic",
          "text": "A drafted reply that acknowledges emotion, validates where possible, and seeks to reduce tension"
        },
        {
          "style": "Assertive",
          "text": "A drafted reply that is respectful but firm, establishing clear boundaries without aggression"
        },
        {
          "style": "Collaborative",
          "text": "A drafted reply that focuses on shared goals and practical solutions"
        }
      ]
    }
  ],
  
  "interaction_dynamics": {
    "power_balance": "Analysis of who holds conversational power and how",
    "escalation_pattern": "Escalating / De-escalating / Stable / Cyclical",
    "communication_barriers": ["barrier1", "barrier2", "barrier3"],
    "productive_elements": ["any positive patterns", "collaborative moments"],
    "cycle_risk": "If this pattern continues, what relational damage might occur"
  },
  
  "path_forward": {
    "immediate_steps": ["step1 for de-escalation", "step2", "step3"],
    "if_unresolved": "Likely trajectory if communication patterns continue unchanged",
    "optimal_outcome": "What successful resolution would look like and how to achieve it"
  }
}

CRITICAL REQUIREMENTS:
✓ Output ONLY valid JSON - no markdown, no preamble, no commentary
✓ Always analyze from BOTH/ALL participant perspectives equally
✓ Ground every insight in specific textual evidence
✓ Maintain clinical objectivity while providing empathetic guidance
✓ Identify concrete, actionable interventions
✓ Never reproduce harmful communication patterns in your analysis language
✓ The "deep_dive" field for each speaker MUST explain specific tactics with quoted examples
✓ EACH speaker object MUST include ALL fields: label, likely_emotional_state, communication_goals, linguistic_patterns, rhetorical_strategies, unmet_needs, sentiment_category, translation, deep_dive, potential_impact_on_others, advice, response_options
✓ Use proper JSON escaping for quotes (use single quotes in text or escape with backslash)

EXAMPLE DEEP DIVE (DO THIS):
"This employs Guilt Induction through obligation language. The phrase 'after everything I have done for you' creates emotional debt, while 'I guess I am just not important to you' positions the speaker as a victim, making disagreement feel like betrayal."
"""

# --- ROBUST AI HANDLERS ---

def clean_and_parse_json(text):
    """
    Cleans AI response to ensure valid JSON.
    Removes Markdown ticks, leading/trailing whitespace, and handles common AI errors.
    """
    try:
        clean = text.strip()
        # Remove Markdown formatting if present
        if "```json" in clean:
            clean = clean.split("```json")[1].split("```")[0]
        elif "```" in clean:
            clean = clean.split("```")[1].split("```")[0]
        
        return json.loads(clean.strip())
    except Exception as e:
        logging.error(f"JSON Parsing Failed: {e} | Raw Text: {text[:100]}...")
        # Fallback: attempt to find the first '{' and last '}'
        try:
            start = text.find('{')
            end = text.rfind('}') + 1
            if start != -1 and end != -1:
                return json.loads(text[start:end])
        except:
            pass
        raise ValueError(f"AI returned invalid JSON: {str(e)}")

def generate_with_fallback(prompt, system_instruction=None, json_mode=True):
    """
    Tries multiple models in order of stability.
    Solves the '404' and 'Model not found' errors.
    """
    # Priority list: Stable -> Legacy. 
    # Removed non-existent 'gemini-3' models to prevent immediate 404s.
    models_to_try = [
        '	gemini-1.5-flash'
    ]
    
    last_error = None

    for model_name in models_to_try:
        try:
            logging.info(f"Attempting generation with model: {model_name}")
            
            model = genai.GenerativeModel(
                model_name=model_name,
                system_instruction=system_instruction
            )
            
            # Use safety settings to prevent blocking legitimate analysis
            safety_settings = [
                {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"},
                {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_NONE"},
                {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_NONE"},
                {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_NONE"},
            ]

            response = model.generate_content(prompt, safety_settings=safety_settings)
            
            if json_mode:
                return clean_and_parse_json(response.text)
            return response.text

        except Exception as e:
            logging.warning(f"Model {model_name} failed: {e}")
            last_error = e
            continue
    
    # If all fail
    raise RuntimeError(f"All AI models failed. Last error: {last_error}")

# --- API ENDPOINTS ---

@app.route('/analyze', methods=['POST'])
def analyze_text():
    try:
        data = request.json
        user_text = data.get('text', '')

        if not user_text:
            return jsonify({"error": "No text provided"}), 400

        prompt = f"Analyze this text strictly according to the JSON schema. Identify speakers by NAME if possible. Output ONLY valid JSON with no markdown formatting: {user_text}"
        
        # Use the robust generator
        result = generate_with_fallback(prompt, system_instruction=SYSTEM_INSTRUCTION, json_mode=True)
        return jsonify(result)

    except Exception as e:
        logging.error(f"Analyze Error: {e}")
        return jsonify({"error": str(e), "message": "Analysis failed. Please try again."}), 500

@app.route('/analyze-profile', methods=['POST'])
def analyze_profile():
    try:
        data = request.json
        speaker_name = data.get('name', 'Target')
        logs = data.get('logs', [])
        
        # Merge history
        history = "\n".join([f"[{log.get('date', 'Unknown')}] {log.get('text', '')}" for log in logs[-15:]])

        prompt = f"""
        You are a Forensic Behavioral Analyst.
        Target: "{speaker_name}"
        History: {history}
        
        Build a behavioral profile. Output STRICT JSON ONLY:
        {{
          "risk_level": "Low/Medium/High/Critical",
          "pattern": "Name of dominant pattern",
          "traits": ["Trait 1", "Trait 2", "Trait 3"],
          "summary": "2-4 sentences explaining the dynamic.",
          "recommendation": "Strategic advice."
        }}
        """
        
        result = generate_with_fallback(prompt, json_mode=True)
        return jsonify(result)

    except Exception as e:
        logging.error(f"Profile Error: {e}")
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
        
        Simulate how the other person will likely react.
        OUTPUT JSON ONLY:
        {{
          "score": 85,
          "response": "Likely Reaction",
          "analysis": "Explanation."
        }}
        """
        
        result = generate_with_fallback(prompt, json_mode=True)
        return jsonify(result)

    except Exception as e:
        logging.error(f"Simulate Error: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/report', methods=['POST'])
def report_issue():
    try:
        data = request.json
        user_reason = data.get('reason', 'User reported issue')
        
        logging.info(f"REPORT RECEIVED: {user_reason}")

        if EMAIL_USER and EMAIL_PASS:
            msg = MIMEMultipart()
            msg['From'] = EMAIL_USER
            msg['To'] = ALERT_RECEIVER
            msg['Subject'] = f"URGENT: Content Report - {user_reason}"
            msg.attach(MIMEText(str(data), 'plain'))

            server = smtplib.SMTP(EMAIL_HOST, EMAIL_PORT)
            server.starttls()
            server.login(EMAIL_USER, EMAIL_PASS)
            server.send_message(msg)
            server.quit()
            return jsonify({"status": "reported"}), 200
        else:
            return jsonify({"status": "logged_only"}), 200

    except Exception as e:
        logging.error(f"Report Error: {e}")
        return jsonify({"error": "Failed to report"}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy", "version": "1.0.5"}), 200

# --- MAIN EXECUTION ---
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)