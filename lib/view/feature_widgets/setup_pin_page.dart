import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:number_pad_keyboard/number_pad_keyboard.dart';
import 'package:payment_app/services/database_services.dart';
import 'package:payment_app/view/home_page.dart';

class SetUpPin extends StatefulWidget {
  const SetUpPin({super.key});

  @override
  _SetUpPinState createState() => _SetUpPinState();
}

class _SetUpPinState extends State<SetUpPin> {
  final TextEditingController _textController = TextEditingController();

  void _addDigit(int digit) {
    if (_textController.text.length < 4) {
      setState(() {
        _textController.text = _textController.text + digit.toString();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Set Up 4 Digit PIN",
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
                controller: _textController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'PIN Code',
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
              enterButtonText: 'ENTER',
              onEnter: () async {
                if (_textController.text.length != 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("PIN must be exactly 4 digits"),
                    ),
                  );
                  return;
                }

                try {
                  await DatabaseServices(
                    uid: FirebaseAuth.instance.currentUser!.uid,
                  ).savePin(int.parse(_textController.text));

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to save PIN: $e")),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
