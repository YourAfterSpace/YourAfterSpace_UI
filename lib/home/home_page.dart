import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../auth/login_page.dart';
import '../experience/experience_discovery_page.dart';
import '../experience/my_experiences_page.dart';
import '../experience/selected_experiences_page.dart';
import '../profile/profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await Amplify.Auth.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign out failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YAS App'),
        backgroundColor: const Color(0xFF1C3FAA),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: const Center(
        child: Text("Welcome 🎉", style: TextStyle(fontSize: 24)),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.travel_explore_rounded, size: 28),
                tooltip: 'Experience Discovery',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExperienceDiscoveryPage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.event_note_rounded, size: 28),
                tooltip: 'My Experiences',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyExperiencesPage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.shopping_bag_rounded, size: 28),
                tooltip: 'Selected experiences',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SelectedExperiencesPage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.person_rounded, size: 28),
                tooltip: 'Profile',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
