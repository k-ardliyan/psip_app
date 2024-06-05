import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psip_app/screen/home_screen.dart';
import 'package:psip_app/screen/menu/profile_screen.dart';

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
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: (index) =>
                controller.selectedIndex.value = index,
            destinations: [
              NavigationDestination(
                  icon: Icon(
                    color: controller.selectedIndex.value == 0
                        ? const Color.fromRGBO(196, 13, 15, 1)
                        : Colors.black,
                    controller.selectedIndex.value == 0
                        ? FluentIcons.home_12_filled
                        : FluentIcons.home_12_regular,
                  ),
                  label: "Beranda"),
              NavigationDestination(
                  icon: Icon(
                      color: controller.selectedIndex.value == 1
                          ? const Color.fromRGBO(196, 13, 15, 1)
                          : Colors.black,
                      controller.selectedIndex.value == 1
                          ? FluentIcons.ticket_diagonal_28_filled
                          : FluentIcons.ticket_diagonal_28_regular),
                  label: "Tiket"),
              NavigationDestination(
                  icon: Icon(
                      color: controller.selectedIndex.value == 2
                          ? const Color.fromRGBO(196, 13, 15, 1)
                          : Colors.black,
                      controller.selectedIndex.value == 2
                          ? Icons.leaderboard_rounded
                          : Icons.leaderboard_outlined),
                  label: "Klasemen"),
              NavigationDestination(
                  icon: Icon(
                      color: controller.selectedIndex.value == 3
                          ? const Color.fromRGBO(196, 13, 15, 1)
                          : Colors.black,
                      controller.selectedIndex.value == 3
                          ? FluentIcons.person_48_filled
                          : FluentIcons.person_48_regular),
                  label: "Akun"),
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
    const ProfileScreen(),
  ];
}
