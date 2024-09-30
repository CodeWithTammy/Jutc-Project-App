import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:jutcapp/driver/driveraccountscreen.dart';
import 'package:jutcapp/driver/map_view.dart';
import '../driver/driverdrawer.dart';

class Drivernavmenu extends StatelessWidget {
  

  const Drivernavmenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DriverNavigationController());
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: DriverDrawer(controller: controller),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), 
              topLeft: Radius.circular(30)
            ),
            boxShadow: [
              BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 9),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            child: NavigationBar(
              backgroundColor: Colors.white,
              indicatorColor: const Color.fromARGB(210, 255, 225, 0),
              height: 70,
              elevation: 10,
              selectedIndex: controller.selectedIndex.value,
              onDestinationSelected: (index) => controller.selectedIndex.value = index,
              destinations: const [
                NavigationDestination(
                    icon: Icon(Iconsax.map, color: Colors.black), label: 'Route'),
                NavigationDestination(
                    icon: Icon(Iconsax.user, color: Colors.black), label: 'Account'),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class DriverNavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [const DriverMapScreen(), const Driveraccountscreen()];
}
