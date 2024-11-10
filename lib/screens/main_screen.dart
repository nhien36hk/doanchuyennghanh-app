import 'package:drivers_android/Assistants/assistants_method.dart';
import 'package:drivers_android/global/global.dart';
import 'package:drivers_android/screens/trips_history_screen.dart';
import 'package:drivers_android/splashScreen/splash_screen.dart';
import 'package:drivers_android/tabPages/earning_tab_page.dart';
import 'package:drivers_android/tabPages/home_tab_page.dart';
import 'package:drivers_android/tabPages/profile_tab_page.dart';
import 'package:drivers_android/tabPages/rating_tab_page.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  int selectedIndex = 0;

  ontItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    selectedIndex = 0;

    tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: [
          HomeTabPage(),
          EarningTabPage(),
          RatingTabPage(),
          ProfileTabPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card), label: 'Thu nhập'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Đánh giá'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
        unselectedItemColor: darkTheme ? Colors.black54 : Colors.white54,
        selectedItemColor: darkTheme ? Colors.black : Colors.white,
        backgroundColor: darkTheme ? Colors.amber.shade400 : buttonColor,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 14),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: ontItemClicked,
      ),
    );
  }
}
