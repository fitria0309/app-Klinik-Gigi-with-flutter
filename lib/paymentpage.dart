import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> service;
  final String username;

  const PaymentPage({
    super.key,
    required this.service,
    required this.username,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int _selectedOptionIndex = 0;

  String formatRupiah(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final selectedPrice = service['price'][_selectedOptionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(service['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Layanan
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  service['image'],
                  width: double.infinity,
                  fit: BoxFit.contain, // <- Ubah dari cover ke contain
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image, size: 80),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Deskripsi Layanan
            Text(
              service['description'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Dropdown Opsi Layanan
            if (service['options'].isNotEmpty)
              DropdownButton<int>(
                value: _selectedOptionIndex,
                items: List.generate(service['options'].length, (index) {
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(service['options'][index]),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _selectedOptionIndex = value!;
                  });
                },
                hint: const Text('Pilih Jenis Layanan'),
              ),
            const SizedBox(height: 16),

            // Menampilkan Harga
            Text(
              'Harga: ${formatRupiah(selectedPrice)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Tombol Booking
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final selectedOption =
                      service['options'][_selectedOptionIndex];
                  final selectedPrice = service['price'][_selectedOptionIndex];
                  final user = Supabase.instance.client.auth.currentUser;

                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User belum login')),
                    );
                    return;
                  }

                  final bookingData = {
                    'user_id': user.id,
                    'nama': widget.username,
                    'service_name': service['name'],
                    'option': selectedOption,
                    'price': selectedPrice,
                    'status': 'Menunggu Pembayaran',
                  };

                  try {
                    await Supabase.instance.client
                        .from('booking')
                        .insert(bookingData);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Booking berhasil')),
                    );

                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal booking: $e')),
                    );
                  }
                },
                child: const Text('Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
