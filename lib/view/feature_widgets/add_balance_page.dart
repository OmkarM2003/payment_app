import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:number_pad_keyboard/number_pad_keyboard.dart';
import 'package:payment_app/helper/helper_fuction.dart';
import 'package:payment_app/services/database_services.dart';
import 'package:payment_app/view/feature_widgets/payment_success_page.dart';
import 'package:payment_app/view/home_page.dart';

class AddBalancePage extends StatefulWidget {
  const AddBalancePage({super.key});

  @override
  _AddBalancePageState createState() => _AddBalancePageState();
}

class _AddBalancePageState extends State<AddBalancePage> {
  final TextEditingController _textController = TextEditingController();
  String? name = '';
  @override
  void initState() {
    super.initState();
    setname();
  }

  void setname() async {
    name = await HelperFunctions.getUserNameFromSF();
  }

  void _addDigit(int digit) {
    if (_textController.text.length < 6) {
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
          "Add Money",
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
                  labelText: 'Enter Amount',
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
                if (_textController.text.length > 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Amount must not be more than 6 digits"),
                    ),
                  );
                  return;
                }

                try {
                  await DatabaseServices(
                    uid: FirebaseAuth.instance.currentUser!.uid,
                  ).addMoney(int.parse(_textController.text));

                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => HomePage()),
                  // );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => PaymentSuccessPage(
                            amount: int.parse(_textController.text),
                            receiverName: name!,
                            type: 'Added',
                          ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to add money: $e")),
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
