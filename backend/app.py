# Flask backend: /create-xendit-invoice
from io import BytesIO
import requests
import xendit
from flask import Flask, flash, redirect, request, jsonify,render_template,session, url_for
from xendit import Xendit
from supabase import create_client, Client
from werkzeug.utils import secure_filename
import os

app = Flask(__name__)


SUPABASE_URL = 'https://vmmuwiveipgmbsrovbmf.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZtbXV3aXZlaXBnbWJzcm92Ym1mIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NTgyMTU3NCwiZXhwIjoyMDYxMzk3NTc0fQ.KzY7el1keHsamvcxi8nsojfmOtxsML7x_qT3jnmfwFM'

XENDIT_API_KEY = 'xnd_development_3zbddl8l3arHCZdj3VzdjyFwpUydNsdroxrXE8paUVWTIhfsZVNZFNTUx7iC8j'
xendit = Xendit(api_key=XENDIT_API_KEY)

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
app.secret_key = 'super-secret-key' 
app.config['UPLOAD_FOLDER'] = os.path.join('static', 'foto_admin')


os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
UPLOAD_FOLDER = 'static/foto_admin'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}


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
def index():
    return render_template('login.html')

@app.route('/login', methods=['POST'])
def login():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']

        try:
            # Ambil data dari tabel admin berdasarkan email
            response = supabase.table('akun_admin').select('email, password, nama, foto').eq('email', email).execute()
            admin_data = response.data[0] if response.data else None
            if admin_data:
                if password == admin_data['password']:
                    session['user'] = admin_data['email']
                    session['nama_admin'] = admin_data['nama']
                    session['foto_admin'] = admin_data['foto']

                    flash('Login berhasil!', 'login_success')
                    return redirect(url_for('dashboard'))
                else:
                    flash('Login gagal: Password salah.', 'login_danger')
            else:
                flash('Login gagal: Email tidak ditemukan.', 'login_danger')

        except Exception as e:
            flash('Login gagal: ' + str(e), 'login_danger')

        return redirect(url_for('index'))

    return redirect(url_for('index'))


@app.route('/admin_add', methods=['POST'])
def admin_add():
    if 'user' not in session:
        return redirect(url_for('login'))

    nama = request.form['nama']
    email = request.form['email']
    password = request.form['password']
    foto = request.files['foto']

    existing = supabase.table("akun_admin").select("*").or_(f"email.eq.{email},nama.eq.{nama}").execute()
    if existing.data:
        flash("Email atau nama sudah digunakan.", "admin_danger")
        return redirect(url_for("admin"))

    filename = secure_filename(nama.lower().replace(" ", "_") + "_" + foto.filename)
    file_bytes = BytesIO(foto.read())

    try:
        supabase.storage.from_('admin-foto').upload(
            path=filename,
            file=file_bytes.getvalue(),
            file_options={"content-type": foto.mimetype}
        )
    except Exception as e:
        flash("Gagal upload foto: " + str(e), "admin_danger")
        return redirect(url_for('admin'))
    foto_url = f"https://{SUPABASE_URL.split('//')[1]}/storage/v1/object/public/admin-foto/{filename}"
    try:
        data_admin = {
            "nama": nama,
            "email": email,
            "password": password,
            "foto": foto_url
        }

        supabase.table("akun_admin").insert(data_admin).execute()
        flash('Akun berhasil ditambahkan!', 'admin_success')
    except Exception as e:
        flash('Gagal menambahkan akun: ' + str(e), 'admin_danger')

    return redirect(url_for('dashboard'))
def get_all_users():
    url = f"{SUPABASE_URL}/auth/v1/admin/users"
    headers = {
        "apikey": SUPABASE_KEY,
        "Authorization": f"Bearer {SUPABASE_KEY}",
        "Content-Type": "application/json"
    }

    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        data = response.json()
        return data.get("users", [])
    else:
        print("Gagal mengambil data user:", response.text)
        return []
    
@app.route('/dashboard', methods=['GET'])
def dashboard():
    if 'user' not in session:
        flash('Silakan login terlebih dahulu.', 'login_danger')
        return redirect(url_for('login'))

    users = get_all_users()
    return render_template('dashboard.html', users=users,
                           nama_admin=session.get('nama_admin'),
                           foto_admin=session.get('foto_admin'))
@app.route('/akun_admin')
def akun_admin():
    if 'user' not in session:
        return redirect(url_for('login'))

    try:
        response = supabase.table("akun_admin").select("*").execute()
        users = response.data if response.data else []
    except Exception as e:
        flash("Gagal mengambil data akun admin: " + str(e), "admin_danger")
        users = []

    return render_template("akun_admin.html",
                           nama_admin=session.get('nama_admin'),
                           foto_admin=session.get('foto_admin'),
                           users=users)

@app.route('/delete_user', methods=['POST'])
def delete_user():
    user_id = request.form.get('uid') 

    try:
        supabase.table("akun_admin").delete().eq("id", user_id).execute()
        flash("Akun berhasil dihapus", "admin_success")
    except Exception as e:
        flash("Terjadi kesalahan saat menghapus akun: " + str(e), "admin_danger")

    return redirect(url_for('dashboard'))

@app.route('/edit_user', methods=['POST'])
def edit_user():
    user_id = request.form.get('uid')  
    new_email = request.form.get('email')
    new_nama = request.form.get('nama')
    new_password = request.form.get('new_password')
    try:
        update_data = {"email": new_email}
        if new_nama:
            update_data["nama"] = new_nama
        if new_password:
            update_data["password"] = new_password

        supabase.table("akun_admin").update(update_data).eq("id", user_id).execute()
        flash("Akun berhasil diperbarui", "admin_success")
    except Exception as e:
        flash("Terjadi kesalahan: " + str(e), "admin_danger")

    return redirect(url_for('dashboard'))

@app.route('/konfirmasi_booking')
def konfirmasi_booking():
    if 'user' not in session:
        return redirect(url_for('login'))

    try:
        booking_resp = supabase.table("booking").select("*").execute()
        bookings = booking_resp.data if booking_resp.data else []
        pasien_resp = supabase.table("akun_pasien").select("id, username").execute()
        pasien_list = pasien_resp.data if pasien_resp.data else []
        pasien_dict = {p['id']: p['username'] for p in pasien_list}
        for b in bookings:
            b['username_pasien'] = pasien_dict.get(b.get('user_id'), "Tidak Diketahui")

    except Exception as e:
        flash("Gagal mengambil data booking atau pasien: " + str(e), "admin_danger")
        bookings = []

    return render_template("konfirmasi_booking.html",
                           nama_admin=session.get('nama_admin'),
                           foto_admin=session.get('foto_admin'),
                           bookings=bookings)


@app.route('/update_status_booking', methods=['POST'])
def update_status_booking():
    booking_id = request.form.get('booking_id')
    new_status = request.form.get('status')

    try:
        supabase.table("booking").update({"status": new_status}).eq("id", booking_id).execute()
        flash("Status booking berhasil diperbarui", "admin_success")
    except Exception as e:
        flash("Gagal memperbarui status booking: " + str(e), "admin_danger")

    return redirect(url_for('konfirmasi_booking'))



@app.route('/logout', methods=['POST'])
def logout():
    session.clear() 
    return redirect(url_for('index')) 


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)

