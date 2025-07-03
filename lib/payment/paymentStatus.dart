import 'package:flutter/material.dart';


class PaymentSuccessPage extends StatelessWidget {
  final Map<String, dynamic> paymentDetails;
  final String paymentMethod;

  const PaymentSuccessPage({
    super.key,
    required this.paymentDetails,
    required this.paymentMethod,
  });

  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color lightGrey = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: Color(0xFF7B1FA2),
        foregroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
          },
          )
      ),
      body: Stack(
        children: [
          // Background circles
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9).withOpacity(0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  // Animated Success Icon
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, value, child) =>
                        Transform.scale(scale: value, child: child),
                    child: const Icon(
                      Icons.check_circle_outline,
                      size: 120,
                      color: accentGreen,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pembayaran Berhasil!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 38, 179, 57),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Terima kasih telah menyelesaikan pembayaran Pelayanan',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),
                  // Payment Details Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detail Pembayaran',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Divider(
                            height: 20,
                            thickness: 1,
                            color: lightGrey,
                          ),
                          if (paymentMethod == 'transfer_bank') ...[
                            _buildDetailRow(
                              'Bank',
                              paymentDetails.getOrNull('bank_code') ?? 'N/A',
                            ),
                            _buildDetailRow(
                              'Nomor VA',
                              paymentDetails.getOrNull('account_number') ??
                                  'N/A',
                            ),
                            _buildDetailRow(
                              'Nama',
                              'Klinik Gigi Drg. Oktavian Lubis',
                            ),
                            _buildDetailRow(
                              'Jumlah',
                              'Rp ${paymentDetails.getOrNull('expected_amount')?.toString() ?? 'N/A'}',
                            ),
                            _buildDetailRow(
                              'Batas Waktu',
                              paymentDetails
                                      .getOrNull('expiration_date')
                                      ?.substring(0, 10) ??
                                  'N/A',
                            ),
                          ] else ...[
                            _buildDetailRow(
                              'Invoice ID',
                              paymentDetails.getOrNull('id') ?? 'N/A',
                            ),
                            _buildDetailRow(
                              'Jumlah',
                              'Rp ${paymentDetails.getOrNull('amount')?.toString() ?? 'N/A'}',
                            ),
                            _buildDetailRow(
                              'Status',
                              paymentDetails.getOrNull('status') ?? 'Pending',
                            ),
                            _buildDetailRow(
                              'Metode',
                              paymentMethod == 'e_wallet'
                                  ? 'E-Wallet'
                                  : 'Indomaret/Alfamart',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Navigation Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [primaryBlue, Color(0xFF2196F3)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

// Extension untuk menangani null safety pada Map
extension MapExtension on Map<String, dynamic> {
  T? getOrNull<T>(String key) => containsKey(key) ? this[key] as T? : null;
}
