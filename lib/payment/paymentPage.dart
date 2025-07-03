import 'package:flutter/material.dart';
import 'package:my_project_pui/service/pembayaranService.dart';
import 'package:my_project_pui/service/xenditPyementController.dart';
import 'package:my_project_pui/payment/paymentStatus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
 
class PembayaranPage extends StatefulWidget {
  final String jenisPelayanan;
  final String bokingId;
  final int totalAmount;

  const PembayaranPage({
    super.key,
    required this.jenisPelayanan,
    required this.totalAmount,
    required this.bokingId,
  });

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  late XenditPaymentController _xenditController;
  late PembayaranService _pembayaranService;
  String? _selectedPaymentMethod;
  String? _selectedBank;
  bool _isPaying = false;
  Map<String, dynamic>? _paymentResponse;
  String? _paymentError;

  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color warningRed = Color(0xFFE53935);

  @override
  void initState() {
    super.initState();
    _xenditController = XenditPaymentController(
      apiKey: 'xnd_development_3zbddl8l3arHCZdj3VzdjyFwpUydNsdroxrXE8paUVWTIhfsZVNZFNTUx7iC8j',
    );
    _pembayaranService = PembayaranService();
  }

  Future<void> _initiatePayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih metode pembayaran terlebih dahulu.'),
          backgroundColor: warningRed,
        ),
      );
      return;
    }

    if (_selectedPaymentMethod == 'transfer_bank' && _selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih bank terlebih dahulu.'),
          backgroundColor: warningRed,
        ),
      );
      return;
    }

    setState(() {
      _isPaying = true;
      _paymentError = null;
    });

    try {
      final externalId =
          '${DateTime.now().millisecondsSinceEpoch}_${widget.jenisPelayanan}';

      Map<String, dynamic>? paymentResponse;
      if (_selectedPaymentMethod == 'transfer_bank') {
        paymentResponse = await _xenditController.createVirtualAccount(
          externalId: externalId,
          bankCode: _selectedBank!,
          name: widget.jenisPelayanan,
          amount: widget.totalAmount,
          email: 'test@mail.com',
        );
      } else if (_selectedPaymentMethod == 'retail_outlet') {
        paymentResponse = await _xenditController.createRetailOutletPayment(
          externalId: externalId,
          retailOutletName: 'INDOMARET',
          name: widget.jenisPelayanan,
          amount: widget.totalAmount,
        );
      }

      if (paymentResponse != null) {
        setState(() {
          _paymentResponse = paymentResponse;
        });
        final supabase = Supabase.instance.client;

        final updateResponse = await supabase
            .from('booking')
            .update({'status': 'Pembayaran Berhasil'})
            .eq('id', widget.bokingId)
            .select();

        if (updateResponse.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal memperbarui status booking.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Status booking berhasil diperbarui.')),
          );
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessPage(
              paymentDetails: paymentResponse!,
              paymentMethod: _selectedPaymentMethod!,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _paymentError = 'Gagal memproses pembayaran: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_paymentError!), backgroundColor: warningRed),
      );
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: primaryBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Layanan: ${widget.jenisPelayanan}'),
                    Text(
                      'Total: Rp ${widget.totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Pilih Metode Pembayaran:'),
            _buildPaymentMethodTile(
              value: 'transfer_bank',
              title: 'Transfer Bank (VA)',
              icon: Icons.account_balance,
            ),
            if (_selectedPaymentMethod == 'transfer_bank')
              _buildBankSelection(),
            _buildPaymentMethodTile(
              value: 'retail_outlet',
              title: 'Indomaret/Alfamart',
              icon: Icons.store,
            ),
            const SizedBox(height: 30),
            _isPaying
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _initiatePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                    ),
                    child: const Text('Lanjut Bayar'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required String value,
    required String title,
    required IconData icon,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: primaryBlue),
        title: Text(title),
        trailing: Radio<String>(
          value: value,
          groupValue: _selectedPaymentMethod,
          onChanged: (val) {
            setState(() {
              _selectedPaymentMethod = val;
              _selectedBank = null;
              _paymentResponse = null;
            });
          },
        ),
      ),
    );
  }

  Widget _buildBankSelection() {
    final banks = ['BCA', 'BNI', 'BRI', 'MANDIRI'];
    return Wrap(
      spacing: 8,
      children: banks
          .map(
            (bank) => ChoiceChip(
              label: Text(bank),
              selected: _selectedBank == bank,
              onSelected: (selected) {
                setState(() {
                  _selectedBank = selected ? bank : null;
                });
              },
            ),
          )
          .toList(),
    );
  }
}
