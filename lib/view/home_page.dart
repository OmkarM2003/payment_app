import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payment_app/helper/helper_fuction.dart';

import 'package:payment_app/services/auth_services.dart';
import 'package:payment_app/services/database_services.dart';
import 'package:payment_app/view/feature_widgets/add_balance_page.dart';
import 'package:payment_app/view/balance_page.dart';
import 'package:payment_app/view/feature_widgets/button.dart';
import 'package:payment_app/view/auth/login_page.dart';
import 'package:payment_app/view/feature_widgets/qr_code_page.dart';
import 'package:payment_app/view/payment_page.dart';
import 'package:payment_app/view/feature_widgets/pin_verify_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "";
  String email = "";
  String qrCodeResult = "";
  TextEditingController amtController = TextEditingController();
  TextEditingController idController = TextEditingController();
  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  Future<void> gettingUserData() async {
    try {
      email = (await HelperFunctions.getUserEmailFromSF())!;
      userName = (await HelperFunctions.getUserNameFromSF())!;

      setState(() {});
    } catch (e) {
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthServices().firebaseAuth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    final userId = user.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF4E0D3A),
      drawer: Drawer(
        backgroundColor: Color(0xFF4E0D3A),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 212, 211, 211),
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 2,
                          blurRadius: 5,
                          color: Colors.black,
                          offset: Offset(5, 5),
                        ),
                      ],
                    ),
                    child: Icon(Icons.person, size: 150),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "Name: $userName",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),

              Text(
                "Email: $email",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomButton(
                    hg: 50,
                    wg: 125,
                    onpressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddBalancePage(),
                        ),
                      );
                    },
                    display: "Add Money",
                  ),
                  CustomButton(
                    hg: 50,
                    wg: 125,
                    onpressed: () async {
                      await AuthServices().signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    display: "Log out",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      appBar: AppBar(
        backgroundColor: Color(0xFF4E0D3A),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Hello, $userName",
          style: TextStyle(fontSize: 35, color: Colors.white),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QrCodePage()),
              );
            },
            child: Icon(Icons.qr_code_2),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseServices(uid: userId).gettingUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No user data found'));
          }

          final userData =
              snapshot.data!.docs.first.data() as Map<String, dynamic>;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(),
                            ),
                          );
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height / 5,
                          width: MediaQuery.of(context).size.width / 2.2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Color(0xFF720D5D),
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_upward_rounded,
                                  size: 100,
                                  color: Colors.white,
                                ),
                                Text(
                                  "PAY NOW",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => PinVerifyPage(
                                    onVerified: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const BalancePage(),
                                        ),
                                      );
                                    },
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height / 5,
                          width: MediaQuery.of(context).size.width / 2.2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Color(0xFF720D5D),
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
                            child: Text(
                              "Check\nBalance",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  padding: EdgeInsets.only(top: 7, left: 25, right: 25),
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Transactions:",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Sort by recent",
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 1.7,
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: DatabaseServices(uid: userId).getTransactionData(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();

                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final transactions =
                          (data['transactions'] as List<dynamic>).reversed
                              .toList();

                      return ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          return Card(
                            elevation: 5,
                            shadowColor: Color(0xFF720D5D),
                            margin: EdgeInsets.only(
                              left: 8,
                              right: 8,
                              bottom: 8,
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color.fromARGB(
                                    255,
                                    212,
                                    211,
                                    211,
                                  ),
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.black,
                                ),
                              ),
                              title: Text("${tx['name']}"),
                              subtitle: Text(tx['timestamp']),
                              trailing:
                                  tx['type'] == 'Sent'
                                      ? Text(
                                        "- ${tx['amount']}",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 15,
                                        ),
                                      )
                                      : Text(
                                        "+ ${tx['amount']}",
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 15,
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
          );
        },
      ),
    );
  }
}
