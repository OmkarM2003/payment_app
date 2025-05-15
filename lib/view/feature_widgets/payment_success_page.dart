import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class PaymentSuccessPage extends StatefulWidget {
  final int amount;
  final String receiverName;
  final String type;

  const PaymentSuccessPage({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.type,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    playSoundAndRedirect();
  }

  Future<void> playSoundAndRedirect() async {
    await player.play(AssetSource('sounds/payment_sound.mp3'));
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: Lottie.asset(
                'assets/animations/animation.json',
                repeat: false,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "₹${widget.amount} ${widget.type} to ${widget.receiverName}",
              style: GoogleFonts.lato(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Text(
              "Redirecting to homepage...",
              style: GoogleFonts.lato(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
