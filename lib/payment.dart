import 'package:flutter/material.dart';
import 'package:my_project_pui/dashboardpage.dart';

class PaymentPage extends StatelessWidget {
  final Map<String, dynamic> service;

  const PaymentPage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Layanan: ${service['name']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Harga: Rp ${service['price']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pilih Metode Pembayaran:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Kartu Kredit / Debit'),
              onTap: () {
                _showSuccessDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('E-Wallet (OVO, GoPay, DANA)'),
              onTap: () {
                _showSuccessDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('QRIS'),
              onTap: () {
                _showSuccessDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Pembayaran Berhasil"),
        content: const Text("Layanan Anda berhasil dipesan!"),
        actions: [
          TextButton(
          onPressed: () {
            Navigator.pop(context); 
            Navigator.pop(context);
          },
          child: const Text('Kembali'),
        ),
        ],
      ),
    );
  }
}
