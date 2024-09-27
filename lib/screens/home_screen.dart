import 'package:app_intern/constants.dart';
import 'package:app_intern/controller/auth_controller.dart';
import 'package:app_intern/models/object.dart';
import 'package:app_intern/screens/product_detail_screen.dart';
import 'package:app_intern/screens/sell_screen.dart';
import 'package:app_intern/widgets/drawer_header_custom.dart';
import 'package:app_intern/widgets/rac_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
  final AuthController authController = Get.put(AuthController());
}

class _HomeScreenState extends State<HomeScreen> {
  int cuttentIndex = 0;

  Widget DrawerBody() {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.document_scanner,
              size: 26,
              color: Colors.grey,
            ),
            SizedBox(
              width: 14,
            ),
            Text(
              'My Order',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 33,
        ),
        Row(
          children: [
            Icon(
              Icons.person,
              size: 26,
              color: Colors.grey,
            ),
            SizedBox(
              width: 14,
            ),
            Text(
              'My Profile',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 33,
        ),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 26,
              color: Colors.grey,
            ),
            SizedBox(
              width: 14,
            ),
            Text(
              'Delivery Address',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 33,
        ),
        Row(
          children: [
            Icon(
              Icons.credit_card,
              size: 26,
              color: Colors.grey,
            ),
            SizedBox(
              width: 14,
            ),
            Text(
              'Payment Methods',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 33,
        ),
        Row(
          children: [
            Icon(
              Icons.mail,
              size: 26,
              color: Colors.grey,
            ),
            SizedBox(
              width: 14,
            ),
            Text(
              'Contact Us',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 33,
        ),
        Row(
          children: [
            Icon(
              Icons.settings,
              size: 26,
              color: Colors.grey,
            ),
            SizedBox(
              width: 14,
            ),
            Text(
              'Settings',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 33,
        ),
        Row(
          children: [
            Icon(
              Icons.contact_support,
              size: 26,
              color: Colors.grey,
            ),
            SizedBox(
              width: 14,
            ),
            Text(
              'Helps & FAQs',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DrawerHeaderCustom(),
                    SizedBox(
                      height: 43,
                    ),
                    DrawerBody(),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 22,
              bottom: 32,
              child: Container(
                decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: buttonColor.withOpacity(0.2),
                        offset: Offset(0, 6),
                        blurRadius: 7,
                        spreadRadius: 7,
                      )
                    ]),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: InkWell(
                  onTap: () {authController.logOut();},
                  child: Row(
                    children: [
                      Icon(
                        Icons.power_settings_new,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Log Out',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: buttonColor,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SellScreen(),));
          },
          shape: const CircleBorder(),
          backgroundColor: buttonColor,
          child: Text(
            'Tôi bán',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        elevation: 1,
        height: 60,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  cuttentIndex = 0;
                });
              },
              icon: Icon(
                Icons.grid_view_outlined,
                size: 30,
                color: cuttentIndex == 0 ? buttonColor : Colors.grey.shade400,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  cuttentIndex = 1;
                });
              },
              icon: Icon(
                Icons.notifications,
                size: 30,
                color: cuttentIndex == 1 ? buttonColor : Colors.grey.shade400,
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  cuttentIndex = 2;
                });
              },
              icon: Icon(
                Icons.history,
                size: 30,
                color: cuttentIndex == 2 ? buttonColor : Colors.grey.shade400,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  cuttentIndex = 3;
                });
              },
              icon: Icon(
                Icons.person,
                size: 30,
                color: cuttentIndex == 3 ? buttonColor : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
      body: pages[cuttentIndex],
    );
  }
}
