# Flask backend: /create-xendit-invoice
import xendit
from flask import Flask, request, jsonify,render_template
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


@app.route('/')
def login():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        try:
            user = supabase.auth.sign_in_with_password({"email": email, "password": password})
            if user.user is None:
                flash('Login gagal: Email atau password salah.', 'login_danger')
                return redirect(url_for('login'))

            session['user'] = user.user.email

            # Ambil data dari tabel admin berdasarkan email
            response = supabase.table('admin').select('nama, foto').eq('email', email).execute()
            admin_data = response.data[0] if response.data else None

            if admin_data:
                session['nama_admin'] = admin_data['nama']
                session['foto_admin'] = admin_data['foto']
            else:
                flash('Data admin tidak ditemukan.', 'admin_danger')

            flash('Login berhasil!', 'login_success')
            return redirect(url_for('admin'))

        except Exception as e:
            flash('Login gagal: ' + str(e), 'login_danger')
            return redirect(url_for('login'))
    return render_template('login.html')
    return render_template('login.html')
@app.route('/dashboard', methods=['POST'])
def dashboard():
    return render_template('dashboard.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)

