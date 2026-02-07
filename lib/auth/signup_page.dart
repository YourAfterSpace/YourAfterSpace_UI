import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../widgets/error_parser.dart';
import '../widgets/google_button.dart';
import '../widgets/helper.dart';
import '../home/home_page.dart';
import 'login_page.dart';
import 'confirm_signup_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  bool loading = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  // ================= GOOGLE SIGN UP =================
  Future<void> signUpGoogle() async {
    try {
      if (mounted) setState(() => loading = true);
      await Amplify.Auth.signInWithWebUI(
        provider: AuthProvider.google,
      );
      if (mounted) _goHome();
    } catch (e) {
      if (mounted) showError(context, parseAmplifyError(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ================= EMAIL SIGN UP =================
  Future<void> signUpEmail() async {
      if (email.text.trim().isEmpty) {
    showError(context, "Email can’t be empty");
    return;
  }

  if (password.text.trim().isEmpty) {
    showError(context, "Password can’t be empty");
    return;
  }

  if (confirmPassword.text.trim().isEmpty) {
    showError(context, "Confirm password can’t be empty");
    return;
  }

  if (password.text != confirmPassword.text) {
    showError(context, "Passwords do not match");
    return;
  }


    try {
      setState(() => loading = true);

      final result = await Amplify.Auth.signUp(
        username: email.text.trim(),
        password: password.text.trim(),
        options: SignUpOptions(
          userAttributes: {
            AuthUserAttributeKey.email: email.text.trim(),
          },
        ),
      );

      if (!result.isSignUpComplete) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConfirmSignUpPage(email: email.text.trim(),),
          ),
        );
      }
    } catch (e) {
      showError(context, parseAmplifyError(e));
    } finally {
      setState(() => loading = false);
    }
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage(),),
    );
  }

  // ================= UI =================
  static const _primaryDark = Color(0xFF1C3FAA);
  static const _primaryLight = Color(0xFF5FB2E8);
  static const _primaryButton = Color(0xFF1C5ED5);
  static const _surfaceLight = Color(0xFFF5F6F8);

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width > 400 ? 24.0 : 20.0;

    return Scaffold(
      backgroundColor: _surfaceLight,
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1C5ED5)))
          : SingleChildScrollView(
              padding: EdgeInsets.only(
                top: padding.top,
                left: padding.left,
                right: padding.right,
                bottom: viewInsets.bottom + padding.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipPath(
                    clipper: _BottomCurveClipper(),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.48,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_primaryDark, _primaryLight],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        const SizedBox(height: 32),
                        const Text(
                          "Create Account",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Sign up to get started",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 28),

                        /// EMAIL
                        _inputField(
                          icon: Icons.email,
                          hint: "Email Address",
                          controller: email,
                        ),
                        const SizedBox(height: 16,),

                        /// PASSWORD
                        _passwordField(
                          controller: password,
                          hint: "Password",
                          hide: hidePassword,
                          onToggle: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                        ),
                        const SizedBox(height: 16,),

                        /// CONFIRM PASSWORD
                        _passwordField(
                          controller: confirmPassword,
                          hint: "Confirm Password",
                          hide: hideConfirmPassword,
                          onToggle: () {
                            setState(() {
                              hideConfirmPassword = !hideConfirmPassword;
                            });
                          },
                        ),

                 

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: signUpEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryButton,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Create Account",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: Container(height: 1, color: Colors.white24)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                "OR",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(child: Container(height: 1, color: Colors.white24)),
                          ],
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),

                Transform.translate(
                  offset: const Offset(0, -1),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      24,
                      horizontalPadding,
                      20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GoogleButton(
                          text: "Sign Up with Google",
                          onTap: signUpGoogle,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _primaryButton,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
            ),
    );
  }

  // ================= EMAIL FIELD =================
  Widget _inputField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12,),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 14,),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600),
            const SizedBox(width: 12,),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= PASSWORD FIELD =================
  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool hide,
    required VoidCallback onToggle,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12,),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 14,),
        child: Row(
          children: [
            Icon(Icons.lock, color: Colors.grey.shade600),
            const SizedBox(width: 12,),

            Expanded(
              child: TextField(
                controller: controller,
                obscureText: hide,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),

            IconButton(
              icon: Icon(
                hide ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade600,
              ),
              onPressed: onToggle,
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= CURVE CLIPPER =================
class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 30,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
