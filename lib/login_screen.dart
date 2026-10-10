import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'common_widgets.dart';
import 'homepage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _linkController = TextEditingController(); // For pasting the email link

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  /// Sends a sign-in email link to the provided email address.
  Future<void> sendSignInEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      showCustomDialog(
        context: context,
        title: "Error",
        message: "Please enter an email address.",
      );
      return;
    }

    final actionCodeSettings = ActionCodeSettings(
      url: 'https://stayspot.web.app/finishSignUp?email=$email',
      handleCodeInApp: true,
      iOSBundleId: 'com.example.ios',           // Replace with your iOS bundle ID
      androidPackageName: 'com.example.stayspot', // Replace with your Android package name
      androidInstallApp: true,
      androidMinimumVersion: '12',
    );

    try {
      await FirebaseAuth.instance.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );
      // Show dialog informing the user that a link has been sent.
      showCustomDialog(
        context: context,
        title: "Verification Email Sent",
        message:
            "A sign-in link has been sent to $email. Please check your inbox (and spam folder) for instructions.",
      );
    } catch (e) {
      showCustomDialog(
        context: context,
        title: "Error Sending Email",
        message: e.toString(),
      );
    }
  }

  /// Verifies the email link and signs in the user.
  Future<void> verifyEmailLinkAndSignIn() async {
    final email = _emailController.text.trim();
    final emailLink = _linkController.text.trim();

    if (emailLink.isEmpty) {
      showCustomDialog(
        context: context,
        title: "Error",
        message: "Please paste the sign-in link you received in the email.",
      );
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Homepage()),
      );
    } catch (e) {
      showCustomDialog(
        context: context,
        title: "Verification Failed",
        message: e.toString(),
      );
    }
  }

  /// Combined flow: send email link, show instruction, then prompt user to paste the link.
  Future<void> handleEmailVerificationFlow() async {
    await sendSignInEmail();

    // Show instructional dialog after sending the email.
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text("Email Sent"),
          content: const Text(
            "A sign-in link has been sent to your email address. Please check your inbox (and spam folder) for instructions. Tap OK once you've done so.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );

    // Then, show the overlay for pasting the verification link.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text("Enter Verification Link"),
          content: TextField(
            controller: _linkController,
            decoration: const InputDecoration(
              hintText: "Paste the complete sign-in link here",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await verifyEmailLinkAndSignIn();
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  /// Google Sign-In remains unchanged.
  Future<void> handleGoogleLogin() async {
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) return;
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Homepage()),
      );
    } catch (e) {
      showCustomDialog(
        context: context,
        title: "Google Login Error",
        message: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f4f4),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppTitle(),
                      const SizedBox(height: 25),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email Address",
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: handleEmailVerificationFlow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: const [
                          Expanded(child: Divider(thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text("OR"),
                          ),
                          Expanded(child: Divider(thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: Image.asset(
                            'assets/images/google-logo.png',
                            width: 24,
                            height: 24,
                          ),
                          label: const Text(
                            "Continue with Google",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: handleGoogleLogin,
                        ),
                      ),
                      const SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          // Navigate to the register screen if needed
                          Navigator.pushReplacementNamed(context, '/register');
                        },
                        child: const Text(
                          "Don't have an account? Register",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff007BFF),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}