import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DatabaseServices {
  final String uid;
  DatabaseServices({required this.uid});

  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection("users");

  Future saveUserData(String fullName, String email) {
    return userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "pin": 0,
      "uid": uid,
      "balance": 10000,
      "transactions": [],
    }, SetOptions(merge: true)); // Avoid overwriting other data
  }

  Stream<QuerySnapshot> gettingUserData() {
    return userCollection.where("uid", isEqualTo: uid).snapshots();
  }

  Stream<DocumentSnapshot> getTransactionData() {
    return userCollection.doc(uid).snapshots();
  }

  Stream<QuerySnapshot> gettingUsers() {
    return userCollection.snapshots();
  }

  Future<void> addMoney(int amount) async {
    final docRef = userCollection.doc(uid);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception("User does not exist!");
      }

      int currentBalance = snapshot.get('balance');
      int newBalance = currentBalance + amount;

      transaction.update(docRef, {'balance': newBalance});
    });
  }

  Future<void> sendMoney(int amount, String receiverUid) async {
    final senderRef = userCollection.doc(uid);
    final receiverRef = userCollection.doc(receiverUid);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final senderSnap = await transaction.get(senderRef);
        final receiverSnap = await transaction.get(receiverRef);

        if (!senderSnap.exists || !receiverSnap.exists) {
          throw Exception("One or both users do not exist.");
        }

        int senderBalance = senderSnap.get('balance');
        int receiverBalance = receiverSnap.get('balance');
        String senderName = senderSnap.get('fullName');
        String receiverName = receiverSnap.get('fullName');

        if (senderBalance < amount) {
          throw Exception("Insufficient balance");
        }

        int updatedSenderBalance = senderBalance - amount;
        int updatedReceiverBalance = receiverBalance + amount;

        final String dateOnly = DateFormat.yMMMd().format(DateTime.now());

        final senderTransaction = {
          'type': 'Sent',
          'amount': amount,
          'name': receiverName,
          'to': receiverUid,
          'timestamp': dateOnly,
        };

        final receiverTransaction = {
          'type': 'Received',
          'amount': amount,
          'name': senderName,
          'from': uid,
          'timestamp': dateOnly,
        };

        List senderTxns = List.from(senderSnap.get('transactions') ?? []);
        List receiverTxns = List.from(receiverSnap.get('transactions') ?? []);

        senderTxns.add(senderTransaction);
        receiverTxns.add(receiverTransaction);

        transaction.update(senderRef, {
          'balance': updatedSenderBalance,
          'transactions': senderTxns,
        });

        transaction.update(receiverRef, {
          'balance': updatedReceiverBalance,
          'transactions': receiverTxns,
        });
      });
    } catch (e) {
      throw e;
    }
  }

  Future<bool> verifyPin(String enteredPin) async {
    try {
      DocumentSnapshot doc = await userCollection.doc(uid).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      final storedPin = data['pin'].toString();

      return storedPin == enteredPin;
    } catch (e) {
      print("Error verifying PIN: $e");
      return false;
    }
  }

  Future savePin(int pin) {
    return userCollection.doc(uid).update({"pin": pin});
  }
}
