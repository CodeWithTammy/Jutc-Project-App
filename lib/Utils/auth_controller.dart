import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {

storeUserCard(String number, String expiry, String cvv, String name) async {
  double defaultBalance = 100000.0; // Set default balance here
  await FirebaseFirestore.instance
    .collection('Users')
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .collection('cards')
    .add({'name': name, 'number': number, 'cvv': cvv, 'expiry': expiry, 'balance': defaultBalance});

  return true;
}

  RxList userCards = [].obs;

  getUserCards() {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser?.uid).collection('cards')
    .snapshots().listen((event) {
      userCards.value = event.docs;
    });
  }

  Future<bool> deductCardBalance(String cardId, double amount) async {
    try {
      var cardRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('cards')
          .doc(cardId);

      var cardSnapshot = await cardRef.get();
      if (cardSnapshot.exists) {
        double currentBalance = cardSnapshot.get('balance');
        if (currentBalance >= amount) {
          await cardRef.update({'balance': currentBalance - amount});
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error deducting balance: $e');
      return false;
    }
  }
}
