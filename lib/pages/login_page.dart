import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../constants/color_constants.dart';
import '../providers/auth_provider.dart';
import 'sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  String? errorMessage;

  void _login(BuildContext context) {
    setState(() {
      errorMessage = null;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider
        .loginWithEmailAndPassword(
          emailController.text.trim(),
          passwordController.text.trim(),
        )
        .then((result) {
          if (!context.mounted) return;

          if (result == false) {
            setState(() {
              errorMessage = 'Login failed. Check your credentials.';
            });
          } else {
            final user = authProvider.currentUser;
            if (user != null) {
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/home');
            } else {
              if (!context.mounted) return;
              setState(() {
                errorMessage = 'User data not loaded properly.';
              });
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Login',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ColorConstants.primaryColor,
          ),
        ),
        backgroundColor: ColorConstants.themeColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/splash.json',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            Text(
              'Login',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: ColorConstants.softBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ColorConstants.softBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ColorConstants.accentColor),
                ),
                hintText: 'Email',
                hintStyle: GoogleFonts.poppins(color: ColorConstants.greyColor),
              ),
              style: GoogleFonts.poppins(color: ColorConstants.primaryColor),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: ColorConstants.softBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ColorConstants.softBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ColorConstants.accentColor),
                ),
                hintText: 'Password',
                hintStyle: GoogleFonts.poppins(color: ColorConstants.greyColor),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: ColorConstants.greyColor,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
              style: GoogleFonts.poppins(color: ColorConstants.primaryColor),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _login(context),
                child: Text(
                  'LOGIN',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
              child: Text(
                'NEW USER? SIGN UP',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.greyColor,
                ),
              ),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  errorMessage!,
                  style: GoogleFonts.poppins(
                    color: ColorConstants.errorColor,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
