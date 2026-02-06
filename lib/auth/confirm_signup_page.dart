import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

import '../widgets/helper.dart';
import '../home/home_page.dart';
import '../widgets/error_parser.dart';

class ConfirmSignUpPage extends StatefulWidget {
  final String email;
  const ConfirmSignUpPage({super.key, required this.email,});

  @override
  State<ConfirmSignUpPage> createState() => _ConfirmSignUpPageState();
}

class _ConfirmSignUpPageState extends State<ConfirmSignUpPage> {
  final codeCtrl = TextEditingController();
  bool loading = false;

  // ================= CONFIRM OTP (UNCHANGED) =================
  Future<void> confirmCode() async {

      if (codeCtrl.text.trim().isEmpty) {
    showError(context, "Verification code can’t be empty");
    return;
  }
    try {
      setState(() => loading = true);

      await Amplify.Auth.confirmSignUp(
        username: widget.email,
        confirmationCode: codeCtrl.text.trim(),
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

  // ================= RESEND OTP (UNCHANGED) =================
  Future<void> resendCode() async {
    try {
      await Amplify.Auth.resendSignUpCode(
        username: widget.email,
      );

      ScaffoldMessenger.of(context,).showSnackBar(
        const SnackBar(
          content: Text("Verification code resent"),
        ),
      );
    } catch (e) {
      showError(context, parseAmplifyError(e));
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
                          "Verify Your Account",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8,),
                        Text(
                          "Enter the verification code sent to\n${widget.email}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 32,),

                        /// OTP FIELD
                        _inputField(
                          icon: Icons.key,
                          hint: "Verification Code",
                          controller: codeCtrl,
                        ),

                        const SizedBox(height: 24,),

                        /// VERIFY BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: confirmCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1C5ED5,),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10,),
                              ),
                            ),
                            child: const Text(
                              "Verify Account",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12,),

                        /// RESEND CODE
                        TextButton(
                          onPressed: resendCode,
                          child: const Text(
                            "Resend Code",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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
                keyboardType: TextInputType.number,
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
