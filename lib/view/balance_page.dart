import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payment_app/services/auth_services.dart';
import 'package:payment_app/services/database_services.dart';
import 'package:payment_app/view/feature_widgets/button.dart';
import 'package:payment_app/view/home_page.dart';

class BalancePage extends StatelessWidget {
  const BalancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream:
            DatabaseServices(
              uid: FirebaseAuth.instance.currentUser!.uid,
            ).gettingUserData(),
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
                Text(
                  "Balance ",
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                ),
                Text(
                  "₹ ${userData['balance']}",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                CustomButton(
                  hg: 50,
                  wg: 200,
                  onpressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  display: "Back",
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
