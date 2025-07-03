import 'package:supabase_flutter/supabase_flutter.dart';

class PembayaranService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Menyimpan detail pembayaran ke tabel pembayaran.
  /// [externalId]: ID unik untuk transaksi pembayaran.
  /// [pendaftaranId]: ID pendaftaran yang terkait.
  /// [amount]: Jumlah pembayaran dalam IDR.
  /// [paymentMethod]: Metode pembayaran (transfer_bank, e_wallet, qris, retail_outlet).
  /// [paymentData]: Data respons dari Xendit (misalnya, nomor VA, QR code).
  /// Mengembalikan data pembayaran yang disimpan atau melempar exception jika gagal.
  Future<Map<String, dynamic>> simpanPembayaran({
    required String externalId,
    required String pendaftaranId,
    required int amount,
    required String paymentMethod,
    required Map<String, dynamic> paymentData,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Pengguna tidak terautentikasi.');
      }

      // Validasi metode pembayaran
      const validPaymentMethods = [
        'transfer_bank',
        'e_wallet',
        'qris',
        'retail_outlet',
      ];
      if (!validPaymentMethods.contains(paymentMethod)) {
        throw Exception('Metode pembayaran tidak valid.');
      }

      // Validasi jumlah
      if (amount <= 0) {
        throw Exception('Jumlah pembayaran harus lebih dari 0.');
      }

      // Simpan pembayaran ke database
      final response = await _supabase
          .from('pembayaran')
          .insert({
            'external_id': externalId,
            'pendaftaran_id': pendaftaranId,
            'user_id': userId,
            'amount': amount,
            'payment_method': paymentMethod,
            'status': 'PENDING',
            'payment_data': paymentData,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Gagal menyimpan pembayaran: $e');
    }
  }

  /// Memeriksa apakah ada pembayaran untuk pendaftaran tertentu.
  /// [pendaftaranId]: ID pendaftaran yang akan diperiksa.
  /// Mengembalikan Map<String, dynamic>? berisi detail pembayaran jika ada,
  /// atau null jika tidak ada pembayaran.
  Future<Map<String, dynamic>?> cekPembayaranByPendaftaran(
    String pendaftaranId,
  ) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Pengguna tidak terautentikasi.');
      }

      final response = await _supabase
          .from('pembayaran')
          .select()
          .eq('pendaftaran_id', pendaftaranId)
          .eq('user_id', userId)
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Gagal memeriksa status pembayaran: $e');
    }
  }

  /// Memeriksa status pembayaran berdasarkan user_id.
  /// Mengembalikan daftar pembayaran yang terkait dengan pengguna.
  // Future<List<Map<String, dynamic>>> cekPembayaranByUser() async {
  //   try {
  //     final userId = _supabase.auth.currentUser?.id;
  //     if (userId == null) {
  //       throw Exception('Pengguna tidak terautentikasi.');
  //     }

  //     final response = await _supabase
  //         .from('pembayaran')
  //         .select()
  //         .eq('user_id', userId)
  //         .order('created_at', ascending: false);

  //     return List<Map<String, dynamic>>.from(response);
  //   } catch (e) {
  //     throw Exception('Gagal memeriksa riwayat pembayaran: $e');
  //   }
  // }

  /// Memperbarui status pembayaran berdasarkan external_id.
  /// Digunakan untuk menangani callback dari Xendit webhook.
  /// [externalId]: ID unik transaksi pembayaran.
  /// [status]: Status baru (PENDING, PAID, FAILED, EXPIRED).
  Future<void> perbaruiStatusPembayaran({
    required String externalId,
    required String status,
  }) async {
    try {
      const validStatuses = ['PENDING', 'PAID', 'FAILED', 'EXPIRED'];
      if (!validStatuses.contains(status)) {
        throw Exception('Status pembayaran tidak valid.');
      }

      await _supabase
          .from('pembayaran')
          .update({'status': status})
          .eq('external_id', externalId);
    } catch (e) {
      throw Exception('Gagal memperbarui status pembayaran: $e');
    }
  }

  // This method is used to check if ANY payment record exists for the user.
  // It should return a list, but we'll adapt it to return a single record or null
  // for the specific use case in TagihanPage.
  // It's generally better to have a dedicated method for single record lookup.
  Future<Map<String, dynamic>?> getPaymentByPendaftaranId(
    String pendaftaranId,
  ) async {
    try {
      final response = await _supabase
          .from('pembayaran')
          .select('*')
          .eq('pendaftaran_id', pendaftaranId)
          .limit(1)
          .maybeSingle(); // Use maybeSingle to get a single map or null

      return response;
    } catch (e) {
      throw Exception('Gagal mendapatkan data pembayaran: $e');
    }
  }

  // Keep this if it's used elsewhere, otherwise it can be removed if 'cekPembayaranByUser'
  // is fully replaced by 'getPaymentByPendaftaranId' in TagihanPage.
  // For the purpose of this request, I'm assuming 'cekPembayaranByUser' is not critical
  // for the TagihanPage's primary logic anymore.
  Future<List<Map<String, dynamic>>> cekPembayaranByUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    try {
      final response = await _supabase
          .from('pembayaran')
          .select('*')
          .eq('user_id', user.id);
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Error checking payments by user: $e');
    }
  }
}

