# Flask backend: /create-xendit-invoice
import xendit
from flask import Flask, request, jsonify
from xendit import Xendit
import os

XENDIT_API_KEY = 'xnd_development_3zbddl8l3arHCZdj3VzdjyFwpUydNsdroxrXE8paUVWTIhfsZVNZFNTUx7iC8j'
app = Flask(__name__)

xendit = Xendit(api_key=XENDIT_API_KEY)

@app.route('/create-xendit-invoice', methods=['POST'])
def create_invoice():
    data = request.json
    order_id = data.get('order_id')
    gross_amount = data.get('gross_amount')
    customer_name = data.get('customer_name')
    customer_email = data.get('customer_email')

    try:
        invoice = xendit.Invoice.create(
            external_id=order_id,
            amount=gross_amount,
            payer_email=customer_email,
            description=f"Pembayaran untuk {customer_name}",
        )
        return jsonify({'invoice_url': invoice.invoice_url})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)

