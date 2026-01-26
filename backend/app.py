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
# Allow explicit domains for security + localhost for dev
CORS(app, resources={r"/*": {"origins": [
    "https://digitalabcs.com.au", 
    "http://localhost:3000", 
    "http://localhost:19000", 
    "http://localhost:8081"
]}})

API_KEY = os.getenv("GEMINI_API_KEY")
EMAIL_HOST = os.getenv("EMAIL_HOST", "smtp.gmail.com")
EMAIL_PORT = int(os.getenv("EMAIL_PORT", 587))
EMAIL_USER = os.getenv("EMAIL_USER") 
EMAIL_PASS = os.getenv("EMAIL_PASS") 
ALERT_RECEIVER = "info@digitalabcs.com.au"

if not API_KEY:
    logging.error("CRITICAL WARNING: GEMINI_API_KEY is missing from .env")

genai.configure(api_key=API_KEY)

# --- SYSTEM PROMPT (Optimized) ---
SYSTEM_INSTRUCTION = """
You are an expert Linguistic Analyst. Analyze conversations for intent, hidden meanings, and dynamics.
CRITICAL RULES:
1. DETECT SPEAKERS: Identify participants.
2. OBJECTIVITY: Describe language, do not diagnose.
3. OUTPUT JSON ONLY.

OUTPUT FORMAT (STRICT JSON):
{
  "conversation_overview": { "detected_speakers": 2, "speaker_labels": ["A", "B"], "overall_dynamic": "Summary", "conflict_level": "Low/Med/High" },
  "speakers": [
    {
      "label": "Name",
      "likely_emotional_state": "State",
      "communication_goals": ["Goal"],
      "linguistic_patterns": ["Pattern"],
      "translation": "Plain English meaning",
      "deep_dive": "Specific linguistic tactic used with quote.",
      "advice": "Actionable advice"
    }
  ],
  "transcript_log": [{"speaker": "Name", "text": "Message"}],
  "path_forward": { "immediate_steps": ["Step 1"] }
}
"""

def generate_with_fallback(prompt, config):
    """Attempts generation with Flash, falls back to Pro if 404/Error occurs."""
    models_to_try = ['gemini-1.5-flash', 'gemini-1.5-flash-latest', 'gemini-pro']
    
    for model_name in models_to_try:
        try:
            logging.info(f"Attempting analysis with model: {model_name}")
            model = genai.GenerativeModel(
                model_name=model_name,
                system_instruction=SYSTEM_INSTRUCTION,
                safety_settings=config
            )
            response = model.generate_content(prompt)
            return response
        except Exception as e:
            logging.warning(f"Model {model_name} failed: {e}")
            continue
    
    raise Exception("All AI models failed to respond.")

@app.route('/analyze', methods=['POST'])
def analyze_text():
    try:
        data = request.json
        user_text = data.get('text', '')

        if not user_text:
            return jsonify({"error": "No text provided"}), 400
        
        # Safety settings (High tolerance for analysis context)
        safety_settings = [
            {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"},
            {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_NONE"},
            {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_NONE"},
            {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_NONE"},
        ]

        prompt = f"Analyze strictly as JSON. Input: {user_text}"
        
        # USE FALLBACK FUNCTION
        response = generate_with_fallback(prompt, safety_settings)
        
        clean_text = response.text.strip().replace('```json', '').replace('```', '').strip()
        parsed_json = json.loads(clean_text)
        
        return jsonify(parsed_json)

    except Exception as e:
        logging.error(f"Analyze Error: {e}")
        return jsonify({
            "error": "Analysis Failed", 
            "message": "We could not process this text. It may be too short or unclear.",
            "details": str(e)
        }), 500

# --- SIMULATE ENDPOINT ---
@app.route('/simulate', methods=['POST'])
def simulate_response():
    try:
        data = request.json
        context = data.get('context', '')
        draft = data.get('draft', '')
        
        prompt = f"""
        CONTEXT: {context}
        DRAFT REPLY: {draft}
        Simulate reaction. OUTPUT JSON: {{ "score": 85, "response": "Reaction", "analysis": "Reason" }}
        """
        model = genai.GenerativeModel('gemini-1.5-flash') # Simpler prompt, usually safe
        response = model.generate_content(prompt)
        clean_text = response.text.strip().replace('```json', '').replace('```', '').strip()
        return jsonify(json.loads(clean_text))

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# --- REPORTING (REQUIRED FOR APPLE APP STORE) ---
@app.route('/report', methods=['POST'])
def report_issue():
    try:
        data = request.json
        reason = data.get('reason', 'User Report')
        text = data.get('text', 'N/A')
        
        logging.info(f"REPORT: {reason}")
        
        # Email Logic Here (Simplified for stability)
        if EMAIL_USER and EMAIL_PASS:
            msg = MIMEMultipart()
            msg['From'] = EMAIL_USER
            msg['To'] = ALERT_RECEIVER
            msg['Subject'] = f"Content Report: {reason}"
            msg.attach(MIMEText(f"User reported content.\nReason: {reason}\nContent: {text}", 'plain'))
            
            server = smtplib.SMTP(EMAIL_HOST, EMAIL_PORT)
            server.starttls()
            server.login(EMAIL_USER, EMAIL_PASS)
            server.send_message(msg)
            server.quit()

        return jsonify({"status": "reported"}), 200
    except Exception as e:
        logging.error(f"Report Error: {e}")
        return jsonify({"status": "error"}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy", "version": "1.0.2"}), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)