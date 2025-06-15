import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_project_pui/payment_getway.dart'; // Pastikan PaymentWebView ada di sini

class BookingMenu extends StatefulWidget {
  const BookingMenu({super.key});

  @override
  State<BookingMenu> createState() => _BookingMenuState();
}

class _BookingMenuState extends State<BookingMenu> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User belum login')),
        );
        Navigator.of(context).pop();
      });
      return;
    }

    try {
      final response = await supabase
          .from('booking') // nama tabelmu
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        bookings = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching bookings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data: $e')),
      );
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu pembayaran':
      case 'booking dibatalkan':
      case 'menunggu konfirmasi':
        return Colors.red;
      case 'pembayaran berhasil':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<bool> handlePaymentTap(Map<String, dynamic> data) async {
    final orderId = data['order_id'] ?? 'order-${data['id']}';
    final grossAmount = data['price'];
    final customerName = 'Nama Customer'; // Ganti jika ada data customer
    final customerEmail = 'email@example.com'; // Ganti jika ada data email customer

    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5001/create-xendit-invoice'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'order_id': orderId,
          'gross_amount': grossAmount,
          'customer_name': customerName,
          'customer_email': customerEmail,
          'payment_method': 'BANK_TRANSFER',
          'bank_code': 'bca',
        }),
      );

      Navigator.of(context).pop(); // tutup loading

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final invoiceUrl = data['invoice_url'];

        if (invoiceUrl != null && invoiceUrl is String) {
          // Buka PaymentWebView dan tunggu hasilnya (true=bayar sukses)
          final paymentResult = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentWebView(url: invoiceUrl),
            ),
          );

          return paymentResult ?? false;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('URL invoice tidak valid')),
          );
          return false;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat invoice: ${response.body}')),
        );
        return false;
      }
    } catch (e) {
      Navigator.of(context).pop(); // tutup loading kalau error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saat membuat invoice: $e')),
      );
      return false;
    }
  }

  Future<void> updateBookingStatus(int bookingId, String newStatus) async {
    try {
      final response = await supabase
          .from('booking')
          .update({'status':  'Pembayaran Berhasil'})
          .eq('id', bookingId);

      // Response biasanya berupa list data yang diupdate
      if (response == null || response.isEmpty) {
        throw Exception('Update gagal, data kosong');
      }

      // Update local state agar UI berubah
      setState(() {
        final index = bookings.indexWhere((b) => b['id'] == bookingId);
        if (index != -1) {
          bookings[index]['status'] = newStatus;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status booking berhasil diperbarui ke "$newStatus"')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Booking')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? const Center(child: Text('Belum ada booking.'))
              : ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final data = bookings[index];
                    final status = (data['status'] ?? 'Tidak diketahui').toString();

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.medical_services),
                        title: Text(data['service_name'] ?? 'Tanpa Nama Layanan'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pilihan: ${data['option'] ?? '-'}'),
                            Text('Harga: Rp${data['price'] ?? '-'}'),
                            const SizedBox(height: 4),
                            Text(
                              'Status: $status',
                              style: TextStyle(
                                color: getStatusColor(status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          if (status.toLowerCase() == 'menunggu pembayaran') {
                            final bookingId = data['id'];
                            final currentStatus = data['status'];

                            // ✅ Tampilkan id & status saat ini sebelum lanjut
                            print('Booking ID: $bookingId');
                            print('Status sekarang: $currentStatus');

                            // ATAU tampilkan ke pengguna pakai dialog
                            await showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Konfirmasi'),
                                content: Text('ID Booking: $bookingId\nStatus: $currentStatus'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context), // Cancel
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, 'lanjut'),
                                    child: const Text('Lanjut Bayar'),
                                  ),
                                ],
                              ),
                            );
                            final paid = await handlePaymentTap(data);
                            if (paid && bookingId != null) {
                              await updateBookingStatus(bookingId, 'Pembayaran Selesai');
                            }
                          }
                        },
                        trailing: status.toLowerCase() == 'Menunggu Pembayaran'
                            ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red)
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}
