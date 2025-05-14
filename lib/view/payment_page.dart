import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payment_app/services/auth_services.dart';
import 'package:payment_app/services/database_services.dart';
import 'package:payment_app/view/feature_widgets/button.dart';
import 'package:payment_app/view/feature_widgets/pin_verify_page.dart';
import 'package:payment_app/view/feature_widgets/payment_success_page.dart';
import 'package:payment_app/view/home_page.dart';

class PaymentPage extends StatefulWidget {
  String? recevieQrUid;
  PaymentPage({super.key, this.recevieQrUid});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController amtController = TextEditingController();
  String recevierUid = "";
  String recevierName = "";
  bool invalid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.recevieQrUid != null) {
      recevierUid = widget.recevieQrUid!;
      fetchReceiverName(recevierUid);
    }
  }

  Future<void> fetchReceiverName(String uid) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        setState(() {
          invalid = true;
          recevierName = "";
        });
        return;
      }

      final data = snapshot.data();
      setState(() {
        recevierName = data?['fullName'] ?? '';
        invalid = false;
      });
    } catch (e) {
      print('Error fetching receiver name: $e');
      setState(() {
        invalid = true;
        recevierName = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthServices().firebaseAuth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    final userId = user.uid;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return invalid
        ? Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
          ),
          body: const Center(
            child: Text(
              "Invalid User or QR \nPlease scan a valid QR code of user",
              textAlign: TextAlign.center,
            ),
          ),
        )
        : Scaffold(
          backgroundColor: const Color(0xFF4E0D3A),
          appBar: AppBar(
            title: const Text(
              "Payment Page",
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: const Color(0xFF4E0D3A),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      controller: amtController,
                      decoration: InputDecoration(
                        labelText: "Amount",
                        floatingLabelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        labelStyle: const TextStyle(
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
                            color: Colors.blue,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      recevierName == ""
                          ? "Select User To Send Money"
                          : "Receiver Name: $recevierName",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  CustomButton(
                    hg: 50,
                    wg: 200,
                    onpressed: () async {
                      final amount = int.tryParse(amtController.text);
                      final receiverUid = recevierUid;

                      if (amount == null || receiverUid.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Enter valid amount and select a user",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => PinVerifyPage(
                                onVerified: () async {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    await DatabaseServices(
                                      uid: userId,
                                    ).sendMoney(amount, receiverUid);

                                    amtController.clear();

                                    if (mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => PaymentSuccessPage(
                                                amount: amount,
                                                receiverName: recevierName,
                                                type: 'sent',
                                              ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Transaction failed: ${e.toString()}",
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomePage(),
                                      ),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                },
                              ),
                        ),
                      );
                    },
                    display: "Send Money",
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 500,
                    width: MediaQuery.of(context).size.width,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: DatabaseServices(uid: userId).gettingUsers(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text('No user data found'),
                          );
                        }

                        final users =
                            snapshot.data!.docs
                                .where((doc) => doc['uid'] != userId)
                                .toList();

                        return ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final userData =
                                users[index].data() as Map<String, dynamic>;

                            return GestureDetector(
                              onTap: () {
                                recevierUid = userData['uid'];
                                recevierName = userData['fullName'];
                                setState(() {});
                              },
                              child: Card(
                                margin: const EdgeInsets.all(8),
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.fromARGB(255, 212, 211, 211),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Colors.black,
                                    ),
                                  ),
                                  title: Text(
                                    userData['fullName'] ?? 'No Name',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17.5,
                                    ),
                                  ),
                                  subtitle: Text(
                                    userData['email'] ?? 'No Email',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}
