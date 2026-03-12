import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../home/home_page.dart';
import '../profile/profile_api.dart';
import '../profile/profile_onboarding_page.dart';
import 'login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  bool _signedIn = false;
  bool _profileComplete = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      _signedIn = session.isSignedIn;
      if (_signedIn) {
        _profileComplete = await getProfileExists();
      } else {
        _profileComplete = false;
      }
    } catch (e) {
      // Only auth/session failure → treat as not signed in
      debugPrint('AuthGate error: $e');
      _signedIn = false;
      _profileComplete = false;
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_signedIn) return const LoginPage();
    return _profileComplete ? const HomePage() : const ProfileOnboardingPage();
  }
}
