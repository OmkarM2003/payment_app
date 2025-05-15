import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:payment_app/helper/helper_fuction.dart';
import 'package:payment_app/services/auth_services.dart';
import 'package:payment_app/view/auth/login_page.dart';
import 'package:payment_app/view/feature_widgets/setup_pin_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  // Function to handle sign-up logic
  Future<void> _handleSignUp() async {
    // Input validation
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All fields are required")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await AuthServices().createuser(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (result == true) {
      await HelperFunctions.saveUserLoggedInStatus(true);
      await HelperFunctions.saveUserEmailSF(emailController.text);
      await HelperFunctions.saveUserNameSF(nameController.text);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SetUpPin()),
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
              LottieBuilder.asset("assets/animations/signupanimation.json"),
              // Name Field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  style: GoogleFonts.lato(color: Colors.white),

                  controller: nameController,
                  decoration: InputDecoration(
                    floatingLabelStyle: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    labelText: "Name",
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
              // Email Field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  style: GoogleFonts.lato(color: Colors.white),

                  controller: emailController,
                  decoration: InputDecoration(
                    floatingLabelStyle: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
                      color: Colors.black,
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
                  onTap: isLoading ? null : _handleSignUp,
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
                                "Sign Up",
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
                    text: "Already have an account? ",
                    style: GoogleFonts.lato(color: Colors.white, fontSize: 18),
                    children: [
                      TextSpan(
                        text: "LogIn",
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
                                    builder: (context) => LoginPage(),
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
