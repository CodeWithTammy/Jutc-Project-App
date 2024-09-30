import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:get/get.dart';
import 'package:jutcapp/Userscreens/add_card.dart';
import 'package:jutcapp/Utils/auth_controller.dart';

class Topup extends StatefulWidget {
  const Topup({super.key});

  @override
  State<Topup> createState() => _TopupState();
}

class _TopupState extends State<Topup> {
  String cardNumber = '5555 5555 5555 4444';
  String expiryDate = '12/25';
  String cardHolderName = 'Osama Qureshi';
  String cvvCode = '123';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  double balance = 0.0;
  late TextEditingController _amountController;

  late AuthController authController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    authController = Get.put(AuthController());
    authController.getUserCards();
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.7),
        width: 2.0,
      ),
    );
  }

  // Function to top up the card
  void topUpCard(String selectedCardId) {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount.')),
      );
      return;
    }
    print('amount: $amount');
    _processPayment(amount, selectedCardId);
    setState(() {
      balance += amount;
    });
  }

  // Function to display the bottom sheet for top-up input
  void showTopUpBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        String selectedCardId = '';

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter amount to top up:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                    ),
                    controller: _amountController,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select a bank card:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Obx(() {
                    if (authController.userCards.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'No bank cards available.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }
                    return DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Select Card'),
                      value: selectedCardId.isEmpty ? null : selectedCardId,
                      items: authController.userCards.map((card) {
                        return DropdownMenuItem<String>(
                          value: card.id,
                          child: Text(
                            '**** **** **** ${card.get('number').substring(card.get('number').length - 4)}',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCardId = value!;
                          print('Selected card ID: $selectedCardId');
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 500,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () => topUpCard(selectedCardId),
                      child: const Text('Check Out'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Function to process the payment
  void _processPayment(double amount, String cardId) {
    print('Processing payment...');
    print('Amount: $amount, Card ID: $cardId');

    if (cardId.isNotEmpty && amount > 0) {
      var selectedCard = authController.userCards
          .firstWhere((card) => card.id == cardId, orElse: () => null);

      if (selectedCard != null) {
        double currentBalance = selectedCard.get('balance');
        if (currentBalance >= amount) {
          // Deduct the amount from the card balance
          authController.deductCardBalance(cardId, amount).then((success) {
            if (success) {
              setState(() {
                balance += amount; // Update the balance displayed on UI
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment successful!')),
              );
            } else {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Payment failed: Insufficient funds')),
              );
            }
          }).catchError((error) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Payment failed: $error')),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment failed: Insufficient funds')),
          );
        }
      } else {
        print('Error: Selected card is null.');
      }
    } else {
      print('Error: Problem with selected card ID or top-up amount is empty.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a card and enter a valid top-up amount.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Top Up'),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.headphones, color: Colors.black),
            onPressed: () {
              // Handle notification icon press
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 225, 0),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: OvalClipper(),
                  child: Container(
                    height: 260,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 255, 225, 0),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Card(
                      elevation: 20,
                      child: Container(
                        height: 200,
                        width: 350,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage('assets/smartercard.png'),
                            fit: BoxFit.fill,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 15,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                width: 350,
                height: 150,
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 241, 241, 241),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Your Balance:',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '\$${balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 67, 67, 67),
                            fontSize: 38,
                          ),
                        ),
                        const Text(
                          'JMD',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 350,
              child: ElevatedButton(
                onPressed: showTopUpBottomSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    'TOP UP SMARTER CARD',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            const Padding(
              padding: EdgeInsets.only(left: 18.0),
              child: Row(
                                children: [
                  Text(
                    'Your Bank Card',
                    style: TextStyle(
                      color: Color.fromARGB(255, 118, 118, 118),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Obx(() {
              if (authController.userCards.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Your bank card will show here.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              }
              return Column(
                children: List.generate(authController.userCards.length, (i) {
                  String cardNumber = '';
                  String expiryDate = '';
                  String cardHolderName = '';
                  String cvvCode = '';

                  try {
                    cardNumber = authController.userCards.value[i].get('number');
                  } catch (e) {
                    cardNumber = '';
                  }

                  try {
                    expiryDate = authController.userCards.value[i].get('expiry');
                  } catch (e) {
                    expiryDate = '';
                  }

                  try {
                    cardHolderName = authController.userCards.value[i].get('name');
                  } catch (e) {
                    cardHolderName = '';
                  }

                  try {
                    cvvCode = authController.userCards.value[i].get('cvv');
                  } catch (e) {
                    cvvCode = '';
                  }

                  return CreditCardWidget(
                    cardBgColor: Colors.black,
                    cardNumber: cardNumber,
                    expiryDate: expiryDate,
                    cardHolderName: cardHolderName,
                    cvvCode: cvvCode,
                    bankName: '',
                    showBackView: isCvvFocused,
                    obscureCardNumber: true,
                    obscureCardCvv: true,
                    isHolderNameVisible: true,
                    isSwipeGestureEnabled: true,
                    onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
                  );
                }),
              );
            }),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.only(right: 18.0, bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Add bank card',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const Addmypayment()),
                        (route) => false,
                      );
                    },
                    backgroundColor: const Color.fromARGB(255, 255, 225, 0),
                    shape: const CircleBorder(),
                    child: const Icon(CupertinoIcons.arrow_right, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

// Class to shape the oval clip
class OvalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 150);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

