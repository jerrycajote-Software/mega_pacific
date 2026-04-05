import 'package:flutter/material.dart';
import 'dart:convert';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/customer/customer_home_screen.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MegaPacificApp());
}

class MegaPacificApp extends StatelessWidget {
  const MegaPacificApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mega Pacific Roofing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
        ),
        useMaterial3: true,
      ),
      home: const _SplashRouter(),
    );
  }
}

/// Checks existing session on startup and routes without showing a flash login screen.
class _SplashRouter extends StatefulWidget {
  const _SplashRouter();

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final token = await ApiService.getToken();
      final role = await ApiService.getRole();

      print('Session check — token exists: ${token != null}, role: $role');

      Widget destination;

      if (token != null && role != null) {
        // Check JWT expiry
        bool isExpired = true;
        try {
          final parts = token.split('.');
          if (parts.length == 3) {
            final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
            final map = json.decode(payload) as Map<String, dynamic>;
            final exp = map['exp'] as int?;
            isExpired = exp == null ||
                DateTime.fromMillisecondsSinceEpoch(exp * 1000).isBefore(DateTime.now());
          }
        } catch (e) {
          print('JWT decode error: $e');
        }

        if (!isExpired) {
          destination = role == 'admin' ? const AdminShell() : const CustomerHomeScreen();
          print('Session valid — routing to: $role');
        } else {
          await ApiService.logout();
          destination = const LoginScreen();
          print('Session expired — routing to login');
        }
      } else {
        destination = const LoginScreen();
        print('No session — routing to login');
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination),
      );
    } catch (e) {
      print('Session check error: $e');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a branded loading screen while checking the session
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.roofing, color: Colors.white, size: 38),
            ),
            const SizedBox(height: 24),
            const Text(
              'Mega Pacific',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Roofing System',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Color(0xFF1E88E5)),
          ],
        ),
      ),
    );
  }
}

