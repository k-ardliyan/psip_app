import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:psip_app/screen/home_screen.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      NavigationController(),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
              (Set<WidgetState> states) => states.contains(WidgetState.selected)
                  ? const TextStyle(color: Color.fromRGBO(196, 13, 15, 1))
                  : const TextStyle(color: Colors.black),
            ),
          ),
          child: NavigationBar(
            height: 75,
            elevation: 0,
            backgroundColor: Colors.white,
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: (index) =>
                controller.selectedIndex.value = index,
            destinations: [
              NavigationDestination(
                  icon: Icon(
                    color: controller.selectedIndex.value == 0
                        ? const Color.fromRGBO(196, 13, 15, 1)
                        : Colors.black,
                    Iconsax.home,
                  ),
                  label: "Beranda"),
              NavigationDestination(
                  icon: Icon(
                      color: controller.selectedIndex.value == 1
                          ? const Color.fromRGBO(196, 13, 15, 1)
                          : Colors.black,
                      Iconsax.ticket),
                  label: "Tiket"),
              NavigationDestination(
                  icon: Icon(
                      color: controller.selectedIndex.value == 2
                          ? const Color.fromRGBO(196, 13, 15, 1)
                          : Colors.black,
                      Iconsax.status_up),
                  label: "Klasemen"),
              NavigationDestination(
                  icon: Icon(
                      color: controller.selectedIndex.value == 3
                          ? const Color.fromRGBO(196, 13, 15, 1)
                          : Colors.black,
                      Iconsax.user),
                  label: "Profil"),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const HomeScreen(),
    Container(
      color: Colors.purple,
    ),
    Container(
      color: Colors.orange,
    ),
    Container(
      color: Colors.blue,
    ),
  ];
}
