
import 'package:flutter/material.dart';
import 'package:trippo_app/global/global.dart';
class DrawerHeaderCustom extends StatelessWidget {
  DrawerHeaderCustom({super.key});


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
                image: AssetImage('images/avatar.png'),
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
             userModelCurrentInfo != null &&
                            userModelCurrentInfo!.name != null
                        ? userModelCurrentInfo!.name!
                        : 'Guest',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            userModelCurrentInfo != null &&
                            userModelCurrentInfo!.email != null
                        ? userModelCurrentInfo!.email!
                        : 'Email',
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
