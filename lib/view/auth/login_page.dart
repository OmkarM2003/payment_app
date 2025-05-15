import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:payment_app/services/auth_services.dart';
import 'package:payment_app/view/home_page.dart';
import 'package:payment_app/view/auth/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  // Function to handle sign-up logic
  Future<void> _handleLogIn() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All fields are required")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await AuthServices().loginUser(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (result == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LottieBuilder.asset(
                "assets/animations/loginanimation.json",
                height: 300,
              ),
              // Email Field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  style: GoogleFonts.lato(color: Colors.white),
                  controller: emailController,
                  decoration: InputDecoration(
                    floatingLabelStyle: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    labelText: "Email",
                    labelStyle: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
              // Password Field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  style: GoogleFonts.lato(color: Colors.white),

                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(
                    floatingLabelStyle: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    labelText: "Password",
                    labelStyle: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: isLoading ? null : _handleLogIn,
                  child: Container(
                    padding: isLoading ? EdgeInsets.all(0) : EdgeInsets.all(8),
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Color(0xFFE1FF8A),
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 2,
                          blurRadius: 5,
                          color: Colors.black,
                          offset: Offset(5, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child:
                          isLoading
                              ? LottieBuilder.asset(
                                "assets/animations/loading.json",
                                height: 100,
                              )
                              : Text(
                                "Login",
                                style: GoogleFonts.lato(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: GoogleFonts.lato(color: Colors.white, fontSize: 18),
                    children: [
                      TextSpan(
                        text: "SignUp",
                        style: GoogleFonts.lato(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegisterPage(),
                                  ),
                                );
                              },
                      ),
                    ],
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
