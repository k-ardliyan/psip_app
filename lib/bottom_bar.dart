import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psip_app/screen/menu/home_screen.dart';
import 'package:psip_app/screen/menu/profile_screen.dart';
import 'package:psip_app/screen/menu/standing_screen.dart';
import 'package:psip_app/screen/menu/ticket_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int quota = 0;
  int quantity = 0;

  Future<void> _deleteOldData() async {
    final now = Timestamp.now();
    final collection = FirebaseFirestore.instance.collection('tickets');

    try {
      final querySnapshot = await collection
          .where('paymentStatus', isEqualTo: 'menunggu')
          .where('countdownPayment', isLessThanOrEqualTo: now)
          .get();
      for (var doc in querySnapshot.docs) {
        quantity = doc['quantity'];
        await FirebaseFirestore.instance
            .collection('match')
            .doc(doc['teamMatch'])
            .collection('tribun')
            .doc(doc['tribun'])
            .get()
            .then((onValue) async {
          quota = onValue.data()!['quota'];
          setState(() {
            quota = quota + quantity;
          });
          if (onValue.data()!['ticketStatus'] == 'keranjang') {
            collection.doc(doc.id).delete();
          } else {
            await FirebaseFirestore.instance
                .collection('match')
                .doc(doc['teamMatch'])
                .collection('tribun')
                .doc(doc['tribun'])
                .update({'quota': quota}).whenComplete(() {
              collection.doc(doc.id).delete();
            });
          }
        });
      }
      if (kDebugMode) {
        print('Old documents deleted successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting old documents: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _deleteOldData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<BottomBarController>(
        init: BottomBarController(),
        builder: (controller) =>
            Obx(() => controller.screens[controller.selectedIndex]),
      ),
      bottomNavigationBar: GetBuilder<BottomBarController>(
        init: BottomBarController(),
        builder: (controller) => Obx(
          () => NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                (Set<WidgetState> states) =>
                    states.contains(WidgetState.selected)
                        ? const TextStyle(
                            color: Color.fromRGBO(196, 13, 15, 1),
                            fontWeight: FontWeight.bold,
                          )
                        : const TextStyle(color: Colors.black),
              ),
            ),
            child: NavigationBar(
              height: 75,
              elevation: 0,
              backgroundColor: Colors.white,
              indicatorColor: Colors.transparent,
              selectedIndex: controller.selectedIndex,
              onDestinationSelected: (index) => controller.changeIndex(index),
              destinations: [
                NavigationDestination(
                    icon: Icon(
                      color: controller.selectedIndex == 0
                          ? const Color.fromRGBO(196, 13, 15, 1)
                          : Colors.grey.shade700,
                      controller.selectedIndex == 0
                          ? FluentIcons.home_12_filled
                          : FluentIcons.home_12_regular,
                    ),
                    label: "Beranda"),
                NavigationDestination(
                    icon: Icon(
                        color: controller.selectedIndex == 1
                            ? const Color.fromRGBO(196, 13, 15, 1)
                            : Colors.black,
                        controller.selectedIndex == 1
                            ? FluentIcons.ticket_diagonal_28_filled
                            : FluentIcons.ticket_diagonal_28_regular),
                    label: "Tiket"),
                NavigationDestination(
                    icon: Icon(
                        color: controller.selectedIndex == 2
                            ? const Color.fromRGBO(196, 13, 15, 1)
                            : Colors.grey.shade700,
                        controller.selectedIndex == 2
                            ? Icons.leaderboard_rounded
                            : Icons.leaderboard_outlined),
                    label: "Klasemen"),
                NavigationDestination(
                    icon: Icon(
                        color: controller.selectedIndex == 3
                            ? const Color.fromRGBO(196, 13, 15, 1)
                            : Colors.black,
                        controller.selectedIndex == 3
                            ? FluentIcons.person_48_filled
                            : FluentIcons.person_48_regular),
                    label: "Akun"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomBarController extends GetxController {
  final RxInt _selectedIndex = 0.obs;
  int get selectedIndex => _selectedIndex.value;

  final screens = [
    const HomeScreen(),
    const TicketScreen(),
    const StandingScreen(),
    const ProfileScreen(),
  ];

  void changeIndex(int index) {
    _selectedIndex.value = index;
  }
}
