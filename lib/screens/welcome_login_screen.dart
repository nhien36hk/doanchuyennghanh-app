import 'package:trippo_app/global/global.dart';
import 'package:trippo_app/screens/login_screen.dart';
import 'package:flutter/material.dart';

class WelComeLoginScreen extends StatelessWidget {
  const WelComeLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [Colors.white, Color(0xFF191B2F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter
      )),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                  flex: 1,
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 30),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Text(
                                  'Skip',
                                  style: TextStyle(
                                      color: buttonColor, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Chào mừng đến với",
                                style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'HUB APP',
                                style: TextStyle(
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold,
                                    color: buttonColor),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Mọi hạnh động của bạn đều tác động đến yếu tố môi trường',
                                style: TextStyle(fontSize: 17),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
              Expanded(
                flex: 1,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 110,
                              height: 1,
                              child: Container(
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'đăng nhập với',
                              style: TextStyle(color: buttonColor),
                            ),
                            SizedBox(
                              width: 110,
                              height: 1,
                              child: Container(
                                color: Colors.black,
                              ),
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(36)),
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              child: Row(
                                children: [
                                  Icon(Icons.facebook, color: Colors.black,),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Facebook',
                                    style: TextStyle(fontSize: 17, color: Colors.black),
                                  ),
                                ],
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(36)),
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              child: Row(
                                children: [
                                  Icon(Icons.email,color: Colors.black),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Text(
                                    'Email',
                                    style: TextStyle(fontSize: 17, color: Colors.black),
                                  ),
                                ],
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                              ),
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(36),
                              border: Border.all(
                                color: Color.fromARGB(
                                    255, 255, 255, 255), // Màu của đường viền
                                width: 2.0, // Độ dày của đường viền
                              ),
                            ),
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginScreen(),
                                      ));
                                },
                                child: Text(
                                  'Đăng nhập với email hoặc số điện thoại',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Text(
                              'Bạn đã có tài khoản? ',
                              style: TextStyle(fontSize: 17, color: Colors.white),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Đăng nhập',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                            )
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
