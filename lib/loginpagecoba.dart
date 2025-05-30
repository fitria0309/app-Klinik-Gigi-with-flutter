import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_project_pui/dashboardpage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email atau Password tidak boleh kosong")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
      try {
        final pasienData = await Supabase.instance.client
            .from('akun_pasien')
            .select('username')
            .eq('email', email)
            .single();

        final username = pasienData['username'];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(username: username),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mengambil data admin.")),
        );
      }
    }

    } on AuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan. Coba lagi.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ScaleTransition(
                  scale: _animation,
                  child: Image.asset('assets/logoklinik.png', height: 200),
                ),
                const SizedBox(height: 25),
                _buildTextField(_emailController, 'Email', false),
                const SizedBox(height: 20),
                _buildTextField(_passwordController, 'Password', true),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    backgroundColor: const Color.fromARGB(255, 7, 89, 253),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text(
                    'Daftar Akun',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, bool isPassword) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      obscureText: isPassword,
    );
  }
}
