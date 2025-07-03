import 'package:flutter/material.dart';
import 'package:my_project_pui/boking.dart';
import 'package:my_project_pui/payment/paymentPage.dart';
// import 'package:my_project_pui/loginpage.dart';
import 'package:my_project_pui/siginuppage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_project_pui/loginpagecoba.dart';
import 'package:my_project_pui/waitingotp.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://vmmuwiveipgmbsrovbmf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZtbXV3aXZlaXBnbWJzcm92Ym1mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU4MjE1NzQsImV4cCI6MjA2MTM5NzU3NH0.lCVNLgJlIjrgQqOHvB0AW85Oq2eeAs5n0GMBAWTMpmA',
  );
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Named Route Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/boking': (context) => BookingMenu(),
        '/otp': (context) => WaitingConfirmationPage(email: 'dummy@email.com'),
        '/payment': (context) => PembayaranPage(jenisPelayanan: 'Belum ada ',totalAmount: 100,bokingId: 'askjand1',),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

