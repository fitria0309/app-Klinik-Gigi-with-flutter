import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:midtrans_sdk/midtrans_sdk.dart';
class Payment extends StatelessWidget {
  final String orderId = 'order-001';
  final int grossAmount = 10000;  // Dalam rupiah

  Future<void> createTransaction() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/create-transaction'),  // Ganti dengan URL backend
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'order_id': orderId,
        'gross_amount': grossAmount,
        'customer_name': 'Budi',
        'customer_email': 'budi@example.com',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final snapToken = data['token']; // Ambil Snap Token

      // Proses pembayaran dengan Snap
      Midtrans_Sdk().setClientKey('YOUR_CLIENT_KEY');  // Client Key dari Midtrans
      Midtrans_Sdk().setServerKey('YOUR_SERVER_KEY');  // Server Key dari Midtrans
      Midtrans_Sdk().setTransactionToken(snapToken);
      Midtrans_Sdk().startPayment();
    } else {
      print('Failed to create transaction');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pembayaran')),
      body: Center(
        child: ElevatedButton(
          onPressed: createTransaction,
          child: Text('Bayar'),
        ),
      ),
    );
  }
}

