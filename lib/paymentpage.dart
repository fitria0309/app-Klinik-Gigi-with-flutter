import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project_pui/payment.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> service;

  const PaymentPage({super.key, required this.service});

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
            Image.asset(service['image'], width: double.infinity, fit: BoxFit.cover),
            const SizedBox(height: 16),

            // Deskripsi Layanan
            Text(service['description'], style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),

            // Dropdown untuk memilih jenis layanan jika ada
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

            // Menampilkan Harga dengan Format Rupiah
            Text(
              'Harga: ${formatRupiah(selectedPrice)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Tombol untuk ke Halaman Pembayaran
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final selectedOption = service['options'][_selectedOptionIndex];

                  // Tambahkan info tambahan ke dalam map service
                  final updatedService = Map<String, dynamic>.from(service);
                  updatedService['option'] = selectedOption;
                  updatedService['price'] = selectedPrice;

                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => Payment(),
                      transitionsBuilder: (_, anim, __, child) =>
                          FadeTransition(opacity: anim, child: child),
                    ),
                  );
                },
                child: const Text('Lanjut ke Pembayaran'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}