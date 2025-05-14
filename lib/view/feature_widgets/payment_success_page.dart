import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
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
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            const Text(
              "Redirecting to home...",
              style: TextStyle(fontSize: 16, color: Colors.grey),
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
