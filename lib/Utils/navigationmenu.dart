import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:jutcapp/Userscreens/accountscreen.dart';
import 'package:jutcapp/Userscreens/news.dart';
import 'package:jutcapp/Userscreens/topup.dart';

import '../Userscreens/userhomepage.dart';
import 'drawer.dart';

class Navigationmenu extends StatelessWidget {
  const Navigationmenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Navdrawer(controller: controller),
      bottomNavigationBar: Obx(
            ()=> Container(
               decoration: const BoxDecoration(                                                   
                  borderRadius: BorderRadius.only(                                           
                    topRight: Radius.circular(30), topLeft: Radius.circular(30)),            
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
                        onDestinationSelected: (index)=> controller.selectedIndex.value = index,
              
                        destinations: const [
              NavigationDestination(icon: Icon(Iconsax.home, color: Colors.black), label: 'Home'),
              NavigationDestination(icon: Icon(Iconsax.card,color: Colors.black), label: 'Top Up'),
              NavigationDestination(icon: Icon(CupertinoIcons.news, color: Colors.black), label: 'News'),
              NavigationDestination(icon: Icon(Iconsax.user,color: Colors.black), label: 'Account'),
                        ],
                      ),
            ),
      ),
      ),
      body:Obx(()=> controller.screens[controller.selectedIndex.value]),
    );
  }
}


class NavigationController extends GetxController{
  final Rx<int> selectedIndex = 0.obs;

  final screens = [const Userhomepage(), const Topup(), const News(), const Accountscreen()];
}
