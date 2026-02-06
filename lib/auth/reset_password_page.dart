import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

import '../widgets/helper.dart';
import '../home/home_page.dart';
import '../widgets/error_parser.dart';
class ResetPasswordPage extends StatefulWidget {
  final String email;
  const ResetPasswordPage({super.key, required this.email,});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final code = TextEditingController();
  final pass = TextEditingController();
  final confirm = TextEditingController();

  bool hidePassword = true;
  bool hideConfirm = true;
  bool loading = false;

  // ================= RESET PASSWORD LOGIC (UNCHANGED) =================
  Future<void> reset() async {
     if (code.text.trim().isEmpty) {
    showError(context, "Verification code can’t be empty");
    return;
  }

  if (pass.text.trim().isEmpty) {
    showError(context, "Password can’t be empty");
    return;
  }

  if (confirm.text.trim().isEmpty) {
    showError(context, "Confirm password can’t be empty");
    return;
  }

  if (pass.text != confirm.text) {
    showError(context, "Passwords do not match");
    return;
  }
    try {
      setState(() => loading = true);

      await Amplify.Auth.confirmResetPassword(
        username: widget.email,
        confirmationCode: code.text.trim(),
        newPassword: pass.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage(),),
      );
    } catch (e) {
      showError(context, parseAmplifyError(e));
    } finally {
      setState(() => loading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context,).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: loading
          ? const Center(child: CircularProgressIndicator(),)
          : Column(
              children: [
                /// 🔵 TOP CURVED GRADIENT
                ClipPath(
                  clipper: _BottomCurveClipper(),
                  child: Container(
                    height: height * 0.72,
                    padding: const EdgeInsets.symmetric(horizontal: 24,),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1C3FAA,),
                          Color(0xFF5FB2E8,),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40,),

                        const Text(
                          "Reset Password",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8,),
                        Text(
                          "Enter the code sent to\n${widget.email}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 32,),

                        /// CODE FIELD
                        _inputField(
                          icon: Icons.key,
                          hint: "Verification Code",
                          controller: code,
                        ),
                        const SizedBox(height: 16,),

                        /// NEW PASSWORD
                        _passwordField(
                          controller: pass,
                          hint: "New Password",
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
                          controller: confirm,
                          hint: "Confirm Password",
                          hide: hideConfirm,
                          onToggle: () {
                            setState(() {
                              hideConfirm = !hideConfirm;
                            });
                          },
                        ),

                        const SizedBox(height: 24,),

                        /// CONFIRM BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: reset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1C5ED5,),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10,),
                              ),
                            ),
                            child: const Text(
                              "Confirm Password",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ================= INPUT FIELD =================
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
