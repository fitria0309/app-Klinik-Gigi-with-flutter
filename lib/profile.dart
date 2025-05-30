import 'package:flutter/material.dart';
import 'package:my_project_pui/loginpage.dart';
import 'package:my_project_pui/editprofilepage.dart';
import 'package:my_project_pui/pengaturanpage.dart';

class ProfilePage extends StatefulWidget {
  final String username;

  const ProfilePage({super.key, required this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String currentUsername;

  @override
  void initState() {
    super.initState();
    currentUsername = widget.username;
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF7B1FA2); // Ungu elegan
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ListView(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage('assets/profile.png'),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUsername,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pasien Klinik Gigi Oktavian',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildMenuItem(Icons.edit, 'Edit Profil', () async {
            final newName = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfilePage(username: currentUsername),
              ),
            );

            if (newName != null && newName is String) {
              setState(() {
                currentUsername = newName;
              });
            }
          }, primaryColor),
          _buildMenuItem(Icons.settings, 'Pengaturan', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PengaturanPage()),
            );
          }, primaryColor),
          _buildMenuItem(Icons.info_outline, 'Tentang Aplikasi', () {
            // Aksi tentang aplikasi
          }, primaryColor),
          _buildMenuItem(Icons.logout, 'Keluar Akun', () => _logout(context), primaryColor, isLogout: true),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, Color color, {bool isLogout = false}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: isLogout ? Colors.redAccent : color),
          title: Text(
            title,
            style: TextStyle(
              color: isLogout ? Colors.redAccent : Colors.black87,
              fontWeight: isLogout ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
