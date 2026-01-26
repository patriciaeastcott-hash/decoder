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
logging.basicConfig(level=logging.INFO)

# Allow ALL connections to fix "Connection Error"
CORS(app, resources={r"/*": {"origins": "*"}})

API_KEY = os.getenv("GEMINI_API_KEY")
EMAIL_HOST = os.getenv("EMAIL_HOST", "smtp.gmail.com")
EMAIL_PORT = int(os.getenv("EMAIL_PORT", 587))
EMAIL_USER = os.getenv("EMAIL_USER")
EMAIL_PASS = os.getenv("EMAIL_PASS")
ALERT_RECEIVER = "info@digitalabcs.com.au"

if API_KEY:
    genai.configure(api_key=API_KEY)

# --- HELPER: CLEAN AI RESPONSE ---
def clean_and_parse_json(text):
    """
    Strips Markdown (```json ... ```) to prevent 'Could not process' errors.
    """
    try:
        clean = text.strip()
        if "```json" in clean:
            clean = clean.split("```json")[1].split("```")[0]
        elif "```" in clean:
            clean = clean.split("```")[1].split("```")[0]
        return json.loads(clean.strip())
    except Exception as e:
        logging.error(f"JSON Parse Error: {e} | Raw Text: {text}")
        raise ValueError(f"AI returned invalid JSON: {str(e)}")

# --- ENDPOINT 1: ANALYZE (The Core) ---
@app.route('/analyze', methods=['POST'])
def analyze_text():
    try:
        data = request.json
        user_text = data.get('text', '')
        if not user_text: return jsonify({"error": "No text provided"}), 400

        # Use 'gemini-pro' as it is more stable than Flash for structure
        model = genai.GenerativeModel('gemini-pro')
        
        prompt = f"""
        Analyze this text. Output STRICT JSON ONLY. No markdown.
        Schema:
        {{
            "speakers": [
                {{
                    "label": "Name",
                    "likely_emotional_state": "Emotion",
                    "translation": "Meaning",
                    "advice": "Advice",
                    "deep_dive": "Tactic used"
                }}
            ],
            "transcript_log": [{{"speaker": "Name", "text": "Message"}}]
        }}
        Input: {user_text}
        """
        
        response = model.generate_content(prompt)
        parsed = clean_and_parse_json(response.text)
        return jsonify(parsed)

    except Exception as e:
        logging.error(f"Analyze Failed: {e}")
        # Return the REAL error so you can see it
        return jsonify({"error": str(e), "message": "Analysis failed on server."}), 500

# --- ENDPOINT 2: PROFILE (Restored!) ---
@app.route('/analyze-profile', methods=['POST'])
def analyze_profile():
    try:
        data = request.json
        name = data.get('name', 'Speaker')
        logs = data.get('logs', [])
        
        history = "\n".join([f"[{l.get('date','')}]: {l.get('text','')}" for l in logs[-5:]])
        
        model = genai.GenerativeModel('gemini-pro')
        prompt = f"""
        Profile the speaker '{name}' based on this history:
        {history}
        
        Output STRICT JSON ONLY:
        {{
            "risk_level": "High/Medium/Low",
            "pattern": "Core behavior pattern",
            "summary": "Brief summary",
            "recommendation": "Strategic advice",
            "traits": ["Trait 1", "Trait 2"]
        }}
        """
        
        response = model.generate_content(prompt)
        parsed = clean_and_parse_json(response.text)
        return jsonify(parsed)

    except Exception as e:
        logging.error(f"Profile Failed: {e}")
        return jsonify({"error": str(e)}), 500

# --- ENDPOINT 3: SIMULATE ---
@app.route('/simulate', methods=['POST'])
def simulate_response():
    try:
        data = request.json
        model = genai.GenerativeModel('gemini-pro')
        
        prompt = f"""
        Context: {data.get('context')}
        Draft Reply: {data.get('draft')}
        
        Predict the reaction. Output JSON ONLY:
        {{
            "score": 85,
            "response": "Likely Reaction",
            "analysis": "Reasoning"
        }}
        """
        
        response = model.generate_content(prompt)
        parsed = clean_and_parse_json(response.text)
        return jsonify(parsed)

    except Exception as e:
        logging.error(f"Simulate Failed: {e}")
        return jsonify({"error": str(e)}), 500

# --- ENDPOINT 4: REPORT ---
@app.route('/report', methods=['POST'])
def report_issue():
    try:
        data = request.json
        if EMAIL_USER and EMAIL_PASS:
            msg = MIMEMultipart()
            msg['From'] = EMAIL_USER
            msg['To'] = ALERT_RECEIVER
            msg['Subject'] = f"Report: {data.get('reason')}"
            msg.attach(MIMEText(str(data), 'plain'))
            
            server = smtplib.SMTP(EMAIL_HOST, EMAIL_PORT)
            server.starttls()
            server.login(EMAIL_USER, EMAIL_PASS)
            server.send_message(msg)
            server.quit()
        return jsonify({"status": "reported"}), 200
    except Exception:
        return jsonify({"status": "logged"}), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)