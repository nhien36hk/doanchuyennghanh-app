import 'package:app_intern/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DrawerHeaderCustom extends StatelessWidget {
  DrawerHeaderCustom({super.key});

  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/avatar.png'),
                fit: BoxFit.cover,
                repeat: ImageRepeat.noRepeat,
              ),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Huu Nhien',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'kingofpro1410@gmail.com',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
