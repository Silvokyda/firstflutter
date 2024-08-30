from flask import Flask, request, jsonify
import os
import logging
import requests
from dotenv import load_dotenv
from base64 import b64encode
from datetime import datetime
from flask_cors import CORS

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)
CORS(app) 

# Environment variables
MPESA_CONSUMER_KEY = os.getenv("MPESA_CONSUMER_KEY")
MPESA_CONSUMER_SECRET = os.getenv("MPESA_CONSUMER_SECRET")
MPESA_SHORTCODE = os.getenv("MPESA_SHORTCODE")
MPESA_PASSKEY = os.getenv("MPESA_PASSKEY")
CALLBACK_URL = os.getenv("CALLBACK_URL")

logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)

VALID_USERNAME = "testuser"
VALID_PASSWORD = "1234"

@app.route('/api/login', methods=['POST'])
def login():
    data = request.json
    username = data.get("username")
    password = data.get("password")

    if username == VALID_USERNAME and password == VALID_PASSWORD:
        return jsonify({"message": "Login successful", "token": "dummy_token"}), 200
    else:
        return jsonify({"error": "Invalid username or password"}), 401

@app.route('/api/mpesa/payment', methods=['POST'])
def initiate_mpesa_payment():
    data = request.json
    phone_number = data.get("phone_number")
    amount = data.get("amount")

    if not phone_number or not amount:
        return jsonify({"error": "phone_number and amount are required"}), 400

    access_token = get_mpesa_access_token()
    if not access_token:
        logger.error("Failed to obtain MPESA access token.")
        return jsonify({"error": "Failed to obtain access token"}), 500

    url = "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
    headers = {"Authorization": f"Bearer {access_token}"}
    payload = {
        "BusinessShortCode": MPESA_SHORTCODE,
        "Password": generate_password(),
        "Timestamp": get_timestamp(),
        "TransactionType": "CustomerPayBillOnline",
        "Amount": amount,
        "PartyA": phone_number,
        "PartyB": MPESA_SHORTCODE,
        "PhoneNumber": phone_number,
        "CallBackURL": CALLBACK_URL,
        "AccountReference": "Test123",
        "TransactionDesc": "Payment for goods"
    }

    response = requests.post(url, json=payload, headers=headers)
    if response.status_code == 200:
        logger.info("MPESA payment request initiated successfully.")
        return jsonify({"CheckoutRequestID": response.json().get("CheckoutRequestID")}), 200
    else:
        logger.error(f"MPESA payment request failed: {response.text}")
        return jsonify({"error": response.text}), response.status_code

def get_mpesa_access_token() -> str:
    url = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
    response = requests.get(url, auth=(MPESA_CONSUMER_KEY, MPESA_CONSUMER_SECRET))
    if response.status_code == 200:
        logger.info("MPESA access token obtained successfully.")
        return response.json().get("access_token")
    logger.error(f"Failed to obtain MPESA access token: {response.text}")
    return None

def generate_password() -> str:
    timestamp = get_timestamp()
    password_str = f"{MPESA_SHORTCODE}{MPESA_PASSKEY}{timestamp}"
    password = b64encode(password_str.encode()).decode('utf-8')
    return password

def get_timestamp() -> str:
    return datetime.now().strftime('%Y%m%d%H%M%S')

if __name__ == '__main__':
    app.run(debug=True)
