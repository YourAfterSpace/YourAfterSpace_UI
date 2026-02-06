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
      setState(() => loading = true);
      await Amplify.Auth.signInWithWebUI(
        provider: AuthProvider.google,
      );
      _goHome();
    } catch (e) {
     showError(context, parseAmplifyError(e));
    } finally {
      setState(() => loading = false);
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
                    height: height * 0.74,
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
                          "Create Account",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8,),
                        const Text(
                          "Sign up to get started",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 32,),

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

                 

                        const SizedBox(height: 16,),

                        /// EMAIL SIGN UP
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: signUpEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1C5ED5,),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10,),
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

                           
                           const SizedBox(height: 20,),
                        /// GOOGLE SIGN UP
                        GoogleButton(
                          text: "Sign Up with Google",
                          onTap: signUpGoogle,
                        ),
   
   
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18,),

                const Text(
                  "Already have an account?",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9A9A9A,),
                  ),
                ),
                const SizedBox(height: 12,),

                SizedBox(
                  width: 220,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage(),),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF1C5ED5,),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10,),
                      ),
                    ),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C5ED5,),
                      ),
                    ),
                  ),
                ),
              ],
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
