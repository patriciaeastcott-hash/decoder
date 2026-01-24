import requests
import datetime

# --- Configuration ---
# Replace this with the specific URL causing the issue
TARGET_URL = "https://decoder-backend-222632046587.australia-southeast1.run.app/health"

def inspect_server_error(url):
    print(f"--- Starting Diagnostic on: {url} ---")
    
    try:
        # We set a timeout to prevent hanging if the server is unresponsive
        response = requests.get(url, timeout=10)
        
        # Check if the status code indicates a server error (5xx)
        if 500 <= response.status_code < 600:
            print(f"[!] Server Error Detected: {response.status_code}")
            
            # Generate a timestamp for the log file
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"error_log_{timestamp}.html"
            
            # Save the content to a file. 
            # In Dev mode, this often contains the Python stack trace.
            with open(filename, "w", encoding="utf-8") as f:
                f.write(response.text)
                
            print(f"[*] Detailed error response saved to: {filename}")
            print("[*] Open this file in your browser to see the stack trace.")
            
        elif response.status_code == 200:
            print("[✓] Success: Endpoint returned 200 OK.")
        else:
            print(f"[?] Unexpected Status: {response.status_code}")
            
    except requests.exceptions.RequestException as e:
        print(f"[!] Connection Failed: {e}")

if __name__ == "__main__":
    inspect_server_error(TARGET_URL)