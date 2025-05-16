import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:security_rental/Screen/Home/completed.dart';
import 'package:security_rental/Screen/Home/homepage.dart';
import 'package:security_rental/Screen/Home/profile.dart';

class MainNavbar extends StatefulWidget {
  const MainNavbar({super.key});

  @override
  State<MainNavbar> createState() => _MainNavbarState();
}

class _MainNavbarState extends State<MainNavbar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Homepage(),
    Completed(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
        child: SizedBox(
          height: 70.h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Icon(Icons.home, size: 32.h),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Icon(Icons.history, size: 32.h),
                  ),
                  label: 'Completed',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Icon(Icons.person, size: 32.h),
                  ),
                  label: 'Profile',
                ),
              ],
              iconSize: 28, // Ukuran default icon (jika tidak diatur per item)
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              backgroundColor: Colors.blue,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 12.sp,
              unselectedFontSize: 12.sp,
              showUnselectedLabels: false,
            ),
          ),
        ),
      ),
    );
  }
}
