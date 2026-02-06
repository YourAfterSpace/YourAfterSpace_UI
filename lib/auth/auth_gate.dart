import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../home/home_page.dart';
import 'login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  bool _signedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
  try {
    final session = await Amplify.Auth.fetchAuthSession();

    print('🔐 isSignedIn: ${session.isSignedIn}');
    print('🔐 session type: ${session.runtimeType}');

    _signedIn = session.isSignedIn;
  } catch (e) {
    print('❌ fetchAuthSession error: $e');
    _signedIn = false;
  }

  setState(() => _loading = false);
}


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(),),
      );
    }

    return _signedIn ? const HomePage() : const LoginPage();
  }
}
