import 'package:firebase_auth/firebase_auth.dart';
import 'package:payment_app/helper/helper_fuction.dart';
import 'package:payment_app/services/database_services.dart';

class AuthServices {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future createuser(String fullName, String email, String password) async {
    try {
      User user =
          (await firebaseAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          )).user!;

      if (user != null) {
        await DatabaseServices(uid: user.uid).saveUserData(fullName, email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future loginUser(String email, String password) async {
    try {
      User user =
          (await firebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          )).user!;

      if (user != null) {
        // Fetch user data from Firestore
        final snapshot =
            await DatabaseServices(
              uid: user.uid,
            ).userCollection.doc(user.uid).get();
        final userData = snapshot.data() as Map<String, dynamic>;

        await HelperFunctions.saveUserLoggedInStatus(true);
        await HelperFunctions.saveUserEmailSF(email);
        await HelperFunctions.saveUserNameSF(userData["fullName"]);

        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveUserEmailSF("");
      await HelperFunctions.saveUserNameSF("");
      await firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }
}
