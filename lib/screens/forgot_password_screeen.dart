import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trippo_app/global/global.dart';
import 'package:trippo_app/screens/login_screen.dart';

class ForgotPasswordScreeen extends StatefulWidget {
  const ForgotPasswordScreeen({super.key});

  @override
  State<ForgotPasswordScreeen> createState() => _ForgotPasswordScreeenState();
}

class _ForgotPasswordScreeenState extends State<ForgotPasswordScreeen> {
  final emailTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submit() async{
    await firebaseAuth.sendPasswordResetEmail(email: emailTextEditingController.text.trim()).then((value){
      Fluttertoast.showToast(msg: 'We have sent you an email recove password, please check email');
    }).onError((error, StackTrace){
      Fluttertoast.showToast(msg: 'Error Occured: \n ${error.toString()}');
    });
  }

  @override
  Widget build(BuildContext context) {
     bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Image.asset(darkTheme
                    ? 'images/city_dark.jpg'
                    : 'images/city_light.jpg'),
                Text(
                  'Quên Mật Khẩu',
                  style: TextStyle(
                      color:  darkTheme ? Colors.amber.shade400 : buttonColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              decoration: InputDecoration(
                                hintText: 'Email',
                                hintStyle: TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: darkTheme
                                    ? Colors.black45
                                    : Colors.grey.shade200,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                        width: 0, style: BorderStyle.none)),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: darkTheme
                                      ? Colors.amber.shade400
                                      : Colors.grey,
                                ),
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return "Email không thể trống";
                                }

                                if (text.length < 2) {
                                  return 'Nhập đủ ký tự email';
                                }

                                if (EmailValidator.validate(text) == true) {
                                  return null;
                                }

                                if (text.length > 100) {
                                  return "Email không thể dài quá 100 ký tự";
                                }
                              },
                              onChanged: (text) => setState(() {
                                emailTextEditingController.text = text;
                              }),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: double
                                  .infinity, // Nút sẽ chiếm toàn bộ chiều rộng của màn hình
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: darkTheme ? Colors.amber.shade400 : buttonColor,
                                  foregroundColor:
                                      darkTheme ? Colors.black : Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                ),
                                onPressed: () {
                                  _submit();
                                },
                                child: Text(
                                  'Gửi Email Khôi Phục Mật Khẩu',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'Quên mật khẩu',
                                style: TextStyle(
                                    color: darkTheme ? Colors.amber.shade400 : buttonColor),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Bạn đã có tài khoản?',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(),));
                                  },
                                  child: Text(
                                    'Đăng nhập',
                                    style: TextStyle(
                                      color: darkTheme ? Colors.amber.shade400 : buttonColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
              ],
            ),
          ],
        ),
      ),
    );
  }
}
