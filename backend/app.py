import os
import json
import smtplib
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

# 1. CORS CONFIGURATION
# In production, replace '*' with your specific web domain
CORS(app, resources={r"/*": {"origins": ["https://digitalabcs.com.au", "http://localhost:3000"]}})

API_KEY = os.getenv("GEMINI_API_KEY")
EMAIL_HOST = os.getenv("EMAIL_HOST", "smtp.gmail.com")
EMAIL_PORT = int(os.getenv("EMAIL_PORT", 587))
EMAIL_USER = os.getenv("EMAIL_USER") # Your sending email address
EMAIL_PASS = os.getenv("EMAIL_PASS") # Your email app password
ALERT_RECEIVER = "info@digitalabcs.com.au"

if not API_KEY:
    print("CRITICAL WARNING: GEMINI_API_KEY is missing from .env")

genai.configure(api_key=API_KEY)

# --- SECURITY FOR MOBILE ---
@app.before_request
def restrict_mobile_app():
    # Optional: Enforce that requests come from your specific App Bundle ID
    allowed_bundles = ['com.digitalabcs.decoder', 'com.example.decoder'] 
    
    # Skip check for OPTIONS requests (CORS preflight)
    if request.method == 'OPTIONS':
        return
        
    # Check header (Open logic for dev, strict for prod)
    # client_bundle = request.headers.get('X-Bundle-ID')
    # if client_bundle and client_bundle not in allowed_bundles:
    #     return jsonify({"error": "Unauthorized Client"}), 403

# --- SYSTEM PROMPT ---
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

@app.route('/analyze', methods=['POST'])
def analyze_text():
    try:
        data = request.json
        user_text = data.get('text', '')

        if not user_text:
            return jsonify({"error": "No text provided"}), 400
        
        # Safety settings for conflict analysis
        safety_settings = [
            {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"},
            {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_NONE"},
            {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_NONE"},
            {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_NONE"},
        ]

        model = genai.GenerativeModel(
            model_name='gemini-3.0-pro',
            system_instruction=SYSTEM_INSTRUCTION,
            safety_settings=safety_settings
        )
        
        prompt = f"Analyze this text strictly according to the JSON schema. Identify speakers by NAME if possible. Output ONLY valid JSON with no markdown formatting: {user_text}"
        response = model.generate_content(prompt)
        
        clean_text = response.text.strip().replace('```json', '').replace('```', '').strip()
        parsed_json = json.loads(clean_text)
        
    except Exception as e:
        print(f"Analyze Error: {e}")
        return jsonify({"error": str(e)}), 500
        
        # Validate required fields
        if 'speakers' not in parsed_json or not isinstance(parsed_json['speakers'], list):
            # Optional: Add specific validation logic here if needed
            pass

        return jsonify(parsed_json)

    except json.JSONDecodeError as e:
        print(f"\n❌ JSON PARSE ERROR: {e}")
        return jsonify({
            "error": "Invalid JSON response from AI", 
            "details": str(e),
            "message": "The AI returned malformed data. Please try again."
        }), 500
        
    except ValueError as e:
        print(f"\n❌ VALIDATION ERROR: {e}")
        return jsonify({
            "error": "Invalid response structure",
            "details": str(e),
            "message": "The AI response is missing required fields."
        }), 500
        
    except Exception as e:
        print(f"\n❌ ERROR DETAIL: {e}")
        print(f"Error type: {type(e).__name__}")
        
        if "finish_reason" in str(e).lower() or "SAFETY" in str(e):
            return jsonify({
                "error": "Content blocked by safety filter",
                "message": "The text contains content that triggered safety filters. Please try different text."
            }), 400
            
        return jsonify({
            "error": str(e), 
            "error_type": type(e).__name__,
            "message": "Analysis failed. Please check your connection and try again."
        }), 500
        
# --- NEW: PROFILE ANALYST ENDPOINT (Fixes Connection Error) ---
@app.route('/analyze-profile', methods=['POST'])
def analyze_profile():
    try:
        data = request.json
        speaker_name = data.get('name', 'Target')
        logs = data.get('logs', [])
        
        # Merge history
        history = "\n".join([f"[{log['date']}] {log['text']}" for log in logs[-15:]])

        prompt = f"""
        You are a **Forensic Behavioral Analyst & Communication Psychologist**.

        You specialize in identifying psychological patterns, defense mechanisms, relational strategies, and risk indicators *strictly from written communication over time*. 
        You do **not** diagnose mental illness. You infer behavioral strategies only where supported by textual evidence.

        ────────────────────────────
        INPUT DATA
        ────────────────────────────

        1. Target Speaker Identifier:
           - Speaker Name / Label: "{speaker_name}"

        2. Conversation Logs (Chronological):
           - Each log entry may contain:
             • Speaker identifier (name, handle, role, or index)
             • Timestamp (if available)
             • Message content

           Raw Log:
           {history}

        ────────────────────────────
        PRE-PROCESSING INSTRUCTIONS
        ────────────────────────────

        1. **Speaker Isolation**
           - Identify all speakers in the log.
           - Isolate and analyze only messages authored by "{speaker_name}".
           - Use other speakers' messages *only for contextual interpretation* (triggers, responses, power dynamics).

        2. **Temporal Awareness**
           - Preserve chronological order.
           - Detect changes across time (early vs later behaviour).
           - Identify state shifts after conflict, reassurance, rejection, silence, or boundary enforcement.

        ────────────────────────────
        ANALYTICAL OBJECTIVES
        ────────────────────────────

        Build a comprehensive behavioral profile of "{speaker_name}" based *solely* on communication patterns.

        Analyze across the following dimensions:

        ### 1. Engagement Style
        - How does the speaker initiate, maintain, escalate, or withdraw from interaction?
        - Do they seek control, reassurance, dominance, validation, avoidance, or symmetry?
        - Do they respond proportionally or disproportionately to stimuli?

        ### 2. Defense Mechanisms (Primary & Secondary)
        Identify **defense mechanisms inferred from language**, such as:
        - Intellectualization
        - Minimization
        - Rationalization
        - Projection
        - Deflection / Humor as avoidance
        - Gaslighting
        - Stonewalling
        - Emotional Withholding
        - Over-Explanation as Control
        - Victim Positioning
        - Aggressive Compliance
        - Passive Aggression

        For each identified mechanism:
        - Explain *how* it appears linguistically.
        - Explain *what function* it serves for the speaker.

        ### 3. Power & Control Strategies
        - Boundary testing
        - Guilt induction
        - Obligation framing
        - Conditional affection
        - Intermittent reinforcement
        - DARVO (Deny → Attack → Reverse Victim/Offender)
        - Love bombing followed by withdrawal
        - Threats (explicit or implied)
        - Compliance pressure disguised as concern

        ### 4. Emotional Regulation Patterns
        - How does the speaker handle:
          • Rejection
          • Delay or silence
          • Disagreement
          • Accountability
        - Do they externalize distress or internalize it?
        - Is emotional expression used to connect or to control?

        ### 5. Consistency & Contradictions
        - Identify stated values vs enacted behaviour.
        - Highlight contradictions across time.
        - Note narrative shifts that reframe past events.

        ### 6. Escalation & Risk Trajectory
        - Is behaviour intensifying, stabilizing, or de-escalating?
        - Are there indicators of:
          • Obsession
          • Dependency
          • Retaliation
          • Entitlement
          • Psychological coercion

        ────────────────────────────
        EVIDENCE STANDARDS
        ────────────────────────────

        - Every conclusion must be grounded in **observable language patterns**.
        - Avoid speculative motive claims unless repeatedly supported.
        - When uncertain, flag ambiguity rather than over-assert.

        ────────────────────────────
        OUTPUT FORMAT (STRICT JSON ONLY)
        ────────────────────────────

        {{
          "risk_level": "Low" | "Medium" | "High" | "Critical",

          "dominant_engagement_style": "Concise descriptor (e.g., 'Anxious-Pursuit', 'Control-Oriented Avoidance', 'Validation-Seeking with Withdrawal')",

          "core_behavioral_pattern": "Name of dominant pattern (e.g., 'Intermittent Reinforcement', 'Defensive Victimization Cycle', 'Escalating Control Through Emotional Leverage')",

          "defense_mechanisms": [
            {{
              "mechanism": "Name",
              "evidence": "Brief description of repeated linguistic indicators",
              "function": "What this defense protects or achieves for the speaker"
            }}
          ],

          "summary": "2–4 sentences explaining the core psychological dynamic observed over time.",

          "notable_contradictions": [
            "Example contradiction with brief explanation"
          ],

          "escalation_trend": "Increasing" | "Decreasing" | "Stable",

          "risk_indicators": [
            "Specific observable behaviors that elevate concern"
          ],

          "strategic_recommendation": "Clear, practical guidance for engaging safely and effectively with this individual, tailored to their patterns"
        }}

        IMPORTANT:
        - Return JSON only.
        - Do not moralize.
        - Do not diagnose.
        - Do not include advice unrelated to the observed behavior.
        """
        
        model = genai.GenerativeModel('gemini-3.0-pro')
        response = model.generate_content(prompt)
        clean_text = response.text.strip().replace('```json', '').replace('```', '').strip()
        return jsonify(json.loads(clean_text))

    # --- BACKWARDS COMPATIBILITY LAYER ---
        # 1. Map 'core_behavioral_pattern' -> 'pattern'
        if 'core_behavioral_pattern' in analysis_data:
            analysis_data['pattern'] = analysis_data['core_behavioral_pattern']
            
        # 2. Map 'strategic_recommendation' -> 'recommendation'
        if 'strategic_recommendation' in analysis_data:
            analysis_data['recommendation'] = analysis_data['strategic_recommendation']
            
        # 3. Create 'traits' array from mechanisms + risk indicators
        traits = []
        if 'defense_mechanisms' in analysis_data:
            traits += [d.get('mechanism') for d in analysis_data['defense_mechanisms']]
        if 'risk_indicators' in analysis_data:
            traits += analysis_data['risk_indicators']
        analysis_data['traits'] = traits[:8] # Limit to 8 tags for UI
        
        return jsonify(analysis_data)

    except Exception as e:
        print(f"Profile Error: {e}")
        return jsonify({"error": str(e)}), 500

    except Exception as e:
        print(f"Profile Error: {e}")
        return jsonify({"error": str(e)}), 500

# --- NEW: RESPONSE SIMULATOR ENDPOINT ---
@app.route('/simulate', methods=['POST'])
def simulate_response():
    try:
        data = request.json
        context = data.get('context', '')
        draft = data.get('draft', '')
        
        prompt = f"""
        CONTEXT: {context}
        DRAFT REPLY: {draft}
        
        Simulate how the other person will likely react to this draft.
        OUTPUT JSON ONLY:
        {{
          "score": 85,
          "response": "Likely Reaction (e.g. 'Defensive Escalation')",
          "analysis": "Explanation of why this draft is good or bad."
        }}
        """
        model = genai.GenerativeModel('gemini-3.0-pro')
        response = model.generate_content(prompt)
        clean_text = response.text.strip().replace('```json', '').replace('```', '').strip()
        return jsonify(json.loads(clean_text))

    except Exception as e:
        return jsonify({"error": str(e)}), 500
    

@app.route('/analyze_impact', methods=['POST'])
def analyze_impact():
    """Endpoint for analyzing the impact of a proposed response"""
    try:
        data = request.json
        user_text = data.get('text', '')

        if not user_text:
            return jsonify({"error": "No text provided"}), 400
        
        safety_settings = [
            {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"},
            {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_NONE"},
            {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_NONE"},
            {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_NONE"},
        ]

        model = genai.GenerativeModel(
            model_name='gemini-3.0-pro',
            system_instruction="You are an expert communication analyst. Analyze proposed responses and provide impact assessments in JSON format only.",
            safety_settings=safety_settings
        )
        
        response = model.generate_content(user_text)
        clean_text = response.text.strip()
        clean_text = clean_text.replace('```json', '').replace('```', '').strip()
        parsed_json = json.loads(clean_text)
            
        return jsonify(parsed_json)

    except json.JSONDecodeError as e:
        print(f"\n❌ JSON PARSE ERROR: {e}")
        return jsonify({
            "error": "Invalid JSON response from AI", 
            "message": "The AI returned malformed data. Please try again."
        }), 500
        
    except Exception as e:
        print(f"\n❌ ERROR DETAIL: {e}")
        return jsonify({
            "error": str(e), 
            "message": "Impact analysis failed. Please try again."
        }), 500


@app.route('/report', methods=['POST'])
def report_issue():
    """
    Sends an email alert to the business when a user reports an issue.
    """
    try:
        data = request.json
        reported_text = data.get('input_text', 'N/A')
        ai_output = data.get('output_text', 'N/A')
        user_reason = data.get('reason', 'User reported offensive content')

        print(f"⚠️ CONTENT REPORT: {user_reason}")

        # Construct Email
        msg = MIMEMultipart()
        msg['From'] = EMAIL_USER
        msg['To'] = ALERT_RECEIVER
        msg['Subject'] = f"URGENT: Content Report in Linguistic Decoder"

        body = f"""
        A user has reported an AI generation issue.
        
        Reason: {user_reason}
        
        --------------------------------------------------
        USER INPUT:
        {reported_text}
        
        --------------------------------------------------
        AI OUTPUT:
        {ai_output}
        --------------------------------------------------
        """
        msg.attach(MIMEText(body, 'plain'))

        # Send Email
        if EMAIL_USER and EMAIL_PASS:
            server = smtplib.SMTP(EMAIL_HOST, EMAIL_PORT)
            server.starttls()
            server.login(EMAIL_USER, EMAIL_PASS)
            server.send_message(msg)
            server.quit()
            return jsonify({"status": "reported", "message": "Admin alerted via email"}), 200
        else:
            print("❌ Email credentials not set. Logged to console only.")
            return jsonify({"status": "logged_only", "message": "Report logged (Email not configured)"}), 200

    except Exception as e:
        print(f"Report error: {e}")
        return jsonify({"error": "Failed to process report"}), 500

@app.route('/verify-purchase', methods=['POST'])
def verify_purchase():
    """
    Validate Apple In-App Purchase Receipt.
    Handles the Production -> Sandbox fallback automatically.
    """
    try:
        data = request.json
        receipt_data = data.get('receipt_data')
        shared_secret = os.getenv("APPLE_SHARED_SECRET") # Optional: Required for subscriptions

        if not receipt_data:
            return jsonify({"valid": False, "error": "No receipt data"}), 400

        # Apple Verify Receipt URLs
        SANDBOX_URL = "https://sandbox.itunes.apple.com/verifyReceipt"
        PROD_URL = "https://buy.itunes.apple.com/verifyReceipt"

        payload = {"receipt-data": receipt_data}
        if shared_secret:
            payload["password"] = shared_secret

        # 1. Try Production First
        response = requests.post(PROD_URL, json=payload)
        result = response.json()

        # 2. Check for Sandbox environment error (21007)
        # If Apple says "This is a sandbox receipt sent to prod", retry in Sandbox
        if result.get('status') == 21007:
            print("⚠️ Sandbox receipt detected. Retrying with Sandbox URL...")
            response = requests.post(SANDBOX_URL, json=payload)
            result = response.json()

        # 3. Check final status (0 = Valid)
        if result.get('status') == 0:
            return jsonify({"valid": True, "receipt": result.get("receipt")}), 200
        else:
            print(f"❌ Invalid Receipt. Status: {result.get('status')}")
            return jsonify({"valid": False, "status": result.get('status')}), 400

    except Exception as e:
        print(f"Verification Error: {e}")
        return jsonify({"valid": False, "error": str(e)}), 500

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint for testing connectivity"""
    return jsonify({"status": "healthy", "message": "API is running"}), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)