import 'package:flutter/material.dart';

class PengaturanPage extends StatelessWidget {
  const PengaturanPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF7B1FA2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 1,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          _buildSettingItem(
            icon: Icons.notifications,
            title: 'Notifikasi',
            subtitle: 'Aktifkan atau nonaktifkan notifikasi',
            onTap: () {
              // Aksi untuk pengaturan notifikasi
            },
          ),
          _buildSettingItem(
            icon: Icons.lock_outline,
            title: 'Privasi & Keamanan',
            subtitle: 'Ubah kata sandi dan keamanan akun',
            onTap: () {
              // Aksi untuk pengaturan keamanan
            },
          ),
          _buildSettingItem(
            icon: Icons.palette_outlined,
            title: 'Tema Aplikasi',
            subtitle: 'Mode terang / gelap',
            onTap: () {
              // Aksi untuk pengaturan tema
            },
          ),
          _buildSettingItem(
            icon: Icons.language,
            title: 'Bahasa',
            subtitle: 'Pilih bahasa aplikasi',
            onTap: () {
              // Aksi pengaturan bahasa
            },
          ),
          _buildSettingItem(
            icon: Icons.help_outline,
            title: 'Pusat Bantuan',
            subtitle: 'Lihat FAQ atau hubungi admin',
            onTap: () {
              // Aksi ke halaman bantuan
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.grey[700]),
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle!) : null,
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}

