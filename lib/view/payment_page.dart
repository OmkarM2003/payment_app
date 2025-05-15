import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payment_app/services/auth_services.dart';
import 'package:payment_app/services/database_services.dart';
import 'package:payment_app/view/feature_widgets/button.dart';
import 'package:payment_app/view/feature_widgets/pin_verify_page.dart';
import 'package:payment_app/view/feature_widgets/payment_success_page.dart';
import 'package:payment_app/view/home_page.dart';

class PaymentPage extends StatefulWidget {
  final String? recevieQrUid;
  const PaymentPage({super.key, this.recevieQrUid});

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
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator()),
      );
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
          backgroundColor: Color(0xFF121212),
          appBar: AppBar(
            title: Text(
              "Payment Page",
              style: GoogleFonts.lato(fontSize: 25, color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: Color(0xFF121212),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      style: GoogleFonts.lato(color: Colors.white),
                      keyboardType: TextInputType.number,
                      controller: amtController,
                      decoration: InputDecoration(
                        labelText: "Amount",
                        floatingLabelStyle: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        labelStyle: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
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
                    child: Text(
                      recevierName == ""
                          ? "Select User To Send Money"
                          : "Receiver Name: $recevierName",
                      style: GoogleFonts.lato(
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

                      if (amount == null ||
                          amount <= 0 ||
                          receiverUid.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Enter a valid positive amount and select a user",
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
                    height: MediaQuery.of(context).size.height / 1.55,
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

                        return GridView.builder(
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
                              child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    padding: const EdgeInsets.all(13),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.fromARGB(255, 212, 211, 211),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      userData['fullName'],
                                      style: GoogleFonts.lato(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                              ),
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
