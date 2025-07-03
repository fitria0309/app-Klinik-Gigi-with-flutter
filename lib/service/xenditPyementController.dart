import 'package:http/http.dart' as http;
import 'dart:convert';

class XenditPaymentController {
  static const String _baseUrl = 'https://api.xendit.co';
  final String apiKey;

  XenditPaymentController({required this.apiKey});

  // Buat Virtual Account (Transfer Bank)
  Future<Map<String, dynamic>> createVirtualAccount({
    required String externalId,
    required String bankCode,
    required String name,
    required int amount,
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/callback_virtual_accounts'),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:'))}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'external_id': externalId,
          'bank_code': bankCode,
          'name': name,
          'expected_amount': amount,
          'is_closed': true,
          'is_single_use': true,
          'expiration_date': DateTime.now()
              .add(const Duration(days: 1))
              .toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal membuat Virtual Account: ${response.body}');
      }
    } catch (e) {
      print('Error createVirtualAccount: $e');
      rethrow;
    }
  }

  // Buat E-Wallet Charge
  Future<Map<String, dynamic>> createEWalletCharge({
    required String externalId,
    required int amount,
    required String phone,
    required String ewalletType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/ewallets/charges'),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:'))}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'reference_id': externalId,
          'currency': 'IDR',
          'amount': amount,
          'channel_code': ewalletType, // OVO, DANA, GOPAY, LINKAJA
          'channel_properties': {
            'mobile_number': phone,
            'success_redirect_url': 'https://your-school.com/success',
            'failure_redirect_url': 'https://your-school.com/failed',
          },
          'checkout_method': 'ONE_TIME_PAYMENT',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal membuat E-Wallet charge: ${response.body}');
      }
    } catch (e) {
      print('Error createEWalletCharge: $e');
      rethrow;
    }
  }

  // Buat QR Code (QRIS)
  Future<Map<String, dynamic>> createQRCode({
    required String externalId,
    required int amount,
    required String qrCodeType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/qr_codes'),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:'))}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'external_id': externalId,
          'type': qrCodeType, // DYNAMIC atau STATIC
          'currency': 'IDR',
          'amount': amount,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal membuat QR Code: ${response.body}');
      }
    } catch (e) {
      print('Error createQRCode: $e');
      rethrow;
    }
  }

  // Buat Retail Outlet Payment
  Future<Map<String, dynamic>> createRetailOutletPayment({
    required String externalId,
    required String retailOutletName,
    required String name,
    required int amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/fixed_payment_code'),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:'))}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'external_id': externalId,
          'retail_outlet_name': retailOutletName, // INDOMARET, ALFAMART
          'name': name,
          'expected_amount': amount,
          'is_single_use': true,
          'expiration_date': DateTime.now()
              .add(const Duration(days: 1))
              .toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Gagal membuat Retail Outlet payment: ${response.body}',
        );
      }
    } catch (e) {
      print('Error createRetailOutletPayment: $e');
      rethrow;
    }
  }

  // Cek Status Pembayaran (untuk semua metode)
  Future<Map<String, dynamic>> checkPaymentStatus({
    required String id,
    required String paymentMethod,
  }) async {
    try {
      String endpoint;
      switch (paymentMethod) {
        case 'transfer_bank':
          endpoint = '$_baseUrl/callback_virtual_accounts/$id';
          break;
        case 'e_wallet':
          endpoint = '$_baseUrl/ewallets/charges/$id';
          break;
        case 'qris':
          endpoint = '$_baseUrl/qr_codes/$id';
          break;
        case 'retail_outlet':
          endpoint = '$_baseUrl/fixed_payment_code/$id';
          break;
        default:
          throw Exception('Metode pembayaran tidak dikenali: $paymentMethod');
      }

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:'))}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal memeriksa status pembayaran: ${response.body}');
      }
    } catch (e) {
      print('Error checkPaymentStatus: $e');
      rethrow;
    }
  }
}
