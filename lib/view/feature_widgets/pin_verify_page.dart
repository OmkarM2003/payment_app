import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:number_pad_keyboard/number_pad_keyboard.dart';
import 'package:payment_app/services/database_services.dart';

class PinVerifyPage extends StatefulWidget {
  final VoidCallback onVerified;

  const PinVerifyPage({super.key, required this.onVerified});

  @override
  _PinVerifyPageState createState() => _PinVerifyPageState();
}

class _PinVerifyPageState extends State<PinVerifyPage> {
  final TextEditingController _textController = TextEditingController();
  bool isLoading = false;
  bool issubmitted = false;

  void _addDigit(int digit) {
    if (_textController.text.length < 4) {
      setState(() {
        _textController.text += digit.toString();
      });
    }
  }

  void _backspace() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        _textController.text = _textController.text.substring(
          0,
          _textController.text.length - 1,
        );
      });
    }
  }

  Future<void> _verifyPin() async {
    if (_textController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PIN must be exactly 4 digits")),
      );
      return;
    }

    setState(() {
      isLoading = true;
      issubmitted = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final isCorrect = await DatabaseServices(
        uid: uid,
      ).verifyPin(_textController.text);

      if (isCorrect) {
        issubmitted = true;
        widget.onVerified();
      } else {
        issubmitted = false;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Incorrect PIN")));
        _textController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error verifying PIN: $e")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return issubmitted
        ? Scaffold(body: Center(child: CircularProgressIndicator()))
        : Scaffold(
          appBar: AppBar(
            title: const Text(
              "Verify PIN",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            centerTitle: true,
          ),
          body: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    obscureText: true,
                    controller: _textController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter PIN',
                    ),
                    readOnly: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24.0),
                  ),
                ),
                const SizedBox(height: 200.0),
                NumberPadKeyboard(
                  addDigit: _addDigit,
                  backspace: _backspace,
                  enterButtonText: isLoading ? 'Verifying...' : 'ENTER',
                  onEnter: isLoading ? null : _verifyPin,
                ),
              ],
            ),
          ),
        );
  }
}
