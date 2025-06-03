import 'package:flutter/material.dart';
import 'package:my_project_pui/paymentpage.dart';
import 'package:my_project_pui/profile.dart';
import 'package:my_project_pui/boking.dart';
import 'package:my_project_pui/chatpage.dart';
import 'dart:async';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.username});
  final String username;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  late PageController _pageController;
  late Timer _timer;
  int _currentBannerIndex = 0;
  bool _showGreeting = true;

  final List<Map<String, dynamic>> services = [
    {
      'name': 'Konsultasi dengan Dokter Gigi',
      'price': [50000],
      'options': ['Konsultasi Langsung'],
      'image': 'assets/konsultasi.jpg',
      'description': 'Pilih layanan konsultasi dengan dokter gigi.'
    },
    {
      'name': 'Pembuatan Gigi Tiruan',
      'price': [200000, 2500000],
      'options': ['Acrylik', 'Porcelain'],
      'image': 'assets/gigitiruan.jpg',
      'description': 'Pilih bahan untuk pembuatan gigi tiruan.'
    },
    {
      'name': 'Tambalan Gigi',
      'price': [100000, 150000],
      'options': ['Depan', 'Belakang'],
      'image': 'assets/tambal.jpg',
      'description': 'Pilih jenis tambalan gigi.'
    },
    {
      'name': 'Scalling',
      'price': [150000],
      'options': ['Scalling'],
      'image': 'assets/pembersihan.jpg',
      'description': 'Pembersihan karang gigi (scalling).'
    },
    {
      'name': 'Pencabutan Gigi',
      'price': [100000],
      'options': ['Biasa'],
      'image': 'assets/cabut.jpg',
      'description': 'Pencabutan gigi biasa.'
    },
    {
      'name': 'Pemasangan Kawat Gigi',
      'price': [4000000],
      'options': ['Pemasangan Kawat Gigi'],
      'image': 'assets/kawat.jpg',
      'description': 'Layanan pemasangan kawat gigi.'
    },
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        _currentBannerIndex = (_currentBannerIndex + 1) % 3;
        _pageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });

    Timer(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _showGreeting = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHome() {
    final List<String> bannerImages = [
      'assets/banner1.jpg',
      'assets/banner2.jpg',
      'assets/banner3.jpg',
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          // Banner Slider
          Container(
            margin: const EdgeInsets.all(16),
            height: 200,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: bannerImages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentBannerIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[300],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          bannerImages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
                
                // Dot Indicator
                Positioned(
                  bottom: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(bannerImages.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentBannerIndex == index ? 12 : 8,
                        height: _currentBannerIndex == index ? 12 : 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentBannerIndex == index
                              ? const Color.fromARGB(255, 139, 187, 227)
                              : const Color.fromARGB(255, 207, 205, 205),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Judul
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text(
              "Pilih Layanan Kami",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          // Grid Services
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final service = services[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          PaymentPage(service: service),
                      transitionsBuilder: (_, anim, __, child) =>
                          FadeTransition(opacity: anim, child: child),
                    ),
                  );
                },
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.asset(service['image'], fit: BoxFit.cover),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Text(
                              service['name'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            // Harga tidak ditampilkan di sini
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBooking() {
    return BookingMenu();
  }

  Widget _buildProfile() {
    return ProfilePage(username: widget.username);
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF7B1FA2);
    List<Widget> pages = [_buildHome(), _buildBooking(), _buildProfile()];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _showGreeting
            ? Text('Halo, ${widget.username}')
            : Image.asset(
                'assets/logoklinik2.png',
                height: 150,
              ),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.message_outlined),
            tooltip: 'Pesan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: primaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}


