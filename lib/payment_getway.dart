import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

class Payment extends StatefulWidget {
  final String orderId;
  final int grossAmount;
  final String customerName;
  final String customerEmail;

  const Payment({
    super.key,
    required this.orderId,
    required this.grossAmount,
    required this.customerName,
    required this.customerEmail,
  });

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String? selectedBank;

  final List<String> banks = [
    'BCA',
    'Mandiri',
    'BNI',
    'BRI',
  ];

  Future<void> createXenditInvoice() async {
    if (selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih metode pembayaran terlebih dahulu')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5001/create-xendit-invoice'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'order_id': widget.orderId,
          'gross_amount': widget.grossAmount,
          'customer_name': widget.customerName,
          'customer_email': widget.customerEmail,
          'payment_method': 'BANK_TRANSFER',
          'bank_code': selectedBank!.toLowerCase(),
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final invoiceUrl = data['invoice_url'];

        if (invoiceUrl != null && invoiceUrl is String) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentWebView(url: invoiceUrl),
            ),
          );
        } else {
          throw 'Invalid invoice URL';
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat invoice: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error creating invoice: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Pilih Bank',
                border: OutlineInputBorder(),
              ),
              value: selectedBank,
              items: banks
                  .map((bank) => DropdownMenuItem(
                        value: bank,
                        child: Text(bank),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedBank = val;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: createXenditInvoice,
              child: const Text('Bayar dengan Xendit'),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentWebView extends StatefulWidget {
  final String url;

  const PaymentWebView({super.key, required this.url});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
