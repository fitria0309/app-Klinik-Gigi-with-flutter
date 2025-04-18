import 'package:flutter/material.dart';
import 'package:my_project_pui/loginpage.dart';
import 'package:my_project_pui/payment.dart';

class DashboardPage extends StatefulWidget {
  final String username;
  const DashboardPage({super.key, required this.username});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<Map<String, dynamic>> services = [
    {
      'name': 'Konsultasi dengan Dokter Gigi',
      'price': 50000,
      'image': 'assets/konsultasi.jpg'
    },
    {
      'name': 'Pembersihan Karang Gigi',
      'price': 150000,
      'image': 'assets/pembersihan.jpg'
    },
    {
      'name': 'Penambalan Gigi',
      'price': 200000,
      'image': 'assets/tambal.jpg'
    },
    {
      'name': 'Pencabutan Gigi',
      'price': 250000,
      'image': 'assets/cabut.jpg'
    },
  ];

  final List<Map<String, dynamic>> _bookingList = [];

  void _bookService(Map<String, dynamic> service) {
    setState(() {
      _bookingList.add(service);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${service['name']} ditambahkan ke daftar layanan.")),
    );
  }

  void _goToBookingList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingListPage(bookings: _bookingList),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Keluar"),
          content: const Text("Apakah Anda yakin ingin keluar dari akun?"),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Keluar"),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, ${widget.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: _goToBookingList,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: services.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final service = services[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.asset(service['image'], fit: BoxFit.cover),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          service['name'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Rp ${service['price']}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentPage(service: service),
                              ),
                            );
                          },
                          child: const Text('Pesan Layanan'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class BookingListPage extends StatelessWidget {
  final List<Map<String, dynamic>> bookings;

  const BookingListPage({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Layanan Anda')),
      body: bookings.isEmpty
          ? const Center(child: Text('Belum ada layanan yang dipesan.'))
          : ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final item = bookings[index];
                return ListTile(
                  leading: Image.asset(item['image'], width: 50, fit: BoxFit.cover),
                  title: Text(item['name']),
                  subtitle: Text('Rp ${item['price']}'),
                );
              },
            ),
    );
  }
}
