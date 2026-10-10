
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'custom_text_input.dart';
import 'custom_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'common_widgets.dart';
import 'login_screen.dart'; // Import LoginScreen for navigation

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  String userType = "student";
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();

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

  Future<void> handleRegister() async {
    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      showCustomDialog(
        context: context,
        title: "Error",
        message: "Passwords do not match!",
      );
      return;
    }
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      showCustomDialog(
        context: context,
        title: "Success",
        message: "Registration Successful 🎉",
        onOkPressed: () {
          Navigator.of(context).pop();
          // Redirect to LoginScreen after successful registration
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
      );
    } catch (e) {
      showCustomDialog(
        context: context,
        title: "Error",
        message: e.toString(),
      );
    }
  }

  Widget userTypeButton(String type, Icon icon) {
    final bool isActive = userType == type;
    return GestureDetector(
      onTap: () => setState(() => userType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xff007BFF) : Colors.white,
          border: Border.all(color: const Color(0xff007BFF), width: 1.5),
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              type == "student" ? "Student" : "PG/Hostel Owner",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xff007BFF),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f4f4),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppTitle(),
              const SizedBox(height: 30),
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 25),
                      child: Column(
                        children: [
                          const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff007BFF),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 25),
                          // User Type Selection
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              userTypeButton(
                                "student",
                                Icon(
                                  FontAwesomeIcons.graduationCap,
                                  size: 20,
                                  color: userType == "student"
                                      ? Colors.white
                                      : const Color(0xff007BFF),
                                ),
                              ),
                              userTypeButton(
                                "owner",
                                Icon(
                                  Icons.apartment,
                                  size: 22,
                                  color: userType == "owner"
                                      ? Colors.white
                                      : const Color(0xff007BFF),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (userType == "owner") ...[
                            CustomTextInput(
                              controller: _usernameController,
                              hintText: "Enter Name",
                            ),
                            const SizedBox(height: 15),
                            CustomTextInput(
                              controller: _phoneController,
                              hintText: "Enter Phone",
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 15),
                          ],
                          CustomTextInput(
                            controller: _emailController,
                            hintText: "Enter Email",
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 15),
                          CustomTextInput(
                            controller: _passwordController,
                            hintText: "Enter Password",
                            obscureText: true,
                          ),
                          const SizedBox(height: 15),
                          CustomTextInput(
                            controller: _confirmPasswordController,
                            hintText: "Confirm Password",
                            obscureText: true,
                          ),
                          const SizedBox(height: 25),
                          CustomButton(
                            title: "Register",
                            onPressed: handleRegister,
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              // Redirect to LoginScreen on tap
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                              );
                            },
                            child: const Text(
                              "Already registered? Login",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
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
            ],
          ),
        ),
      ),
    );
  }
}
