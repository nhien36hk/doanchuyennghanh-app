import "package:email_validator/email_validator.dart";
import "package:firebase_database/firebase_database.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:trippo_app/Assistants/assistants_method.dart";
import "package:trippo_app/global/global.dart";
import "package:trippo_app/screens/forgot_password_screeen.dart";
import "package:trippo_app/screens/main_screen.dart";
import "package:trippo_app/screens/register_screen.dart";
import "package:trippo_app/splashScreen/splash_screen.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();

  // declare
  bool _passwordVisible = false;

  // Declare a GlobalKey
  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    // Validate all the form fields
    if (_formKey.currentState!.validate()) {
      await firebaseAuth
          .signInWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      )
          .then((auth) async {
        DatabaseReference userRef =
            FirebaseDatabase.instance.ref().child("users");
        userRef.child(firebaseAuth.currentUser!.uid).once().then((value) async {
          final snap = value.snapshot;
          if (snap.value != null) {
            currentUser = auth.user;

            await Fluttertoast.showToast(msg: 'Successfully Logged In');
            await AssistantsMethod.readCurrnetOnlineUserInfo();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SplashScreen(),
              ),
            );
          } else {
            await Fluttertoast.showToast(
                msg: 'No record exists with this email');
            firebaseAuth.signOut();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SplashScreen(),
              ),
            );
          }
        }).catchError((errorMessage) {
          Fluttertoast.showToast(msg: 'Error occurred: \n $errorMessage');
        });
      }).catchError((errorMessage) {
        Fluttertoast.showToast(msg: 'Error occurred: \n $errorMessage');
      });
    } else {
      Fluttertoast.showToast(msg: "Not all fields are valid");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

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
                  'Đăng nhập',
                  style: TextStyle(
                      color: darkTheme ? Colors.amber.shade400 : buttonColor,
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
                              controller: emailTextEditingController,
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
                                  return "Email can't be empty";
                                }

                                if (text.length < 2) {
                                  return 'Please enter a valid email';
                                }

                                if (EmailValidator.validate(text) == true) {
                                  return null;
                                }

                                if (text.length > 100) {
                                  return "Email can't be more than 100";
                                }
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: passwordTextEditingController,
                              obscureText: !_passwordVisible,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              decoration: InputDecoration(
                                hintText: 'Password',
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
                                  Icons.lock,
                                  color: darkTheme
                                      ? Colors.amber.shade400
                                      : Colors.grey,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: darkTheme
                                        ? Colors.amber.shade400
                                        : Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      // toggle the visibility of the password
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return "Password can't be empty";
                                }

                                if (text.length < 6) {
                                  return 'Please enter a valid password';
                                }

                                if (text.length > 49) {
                                  return "Password can't be more than 50";
                                }

                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: darkTheme
                                      ? Colors.amber.shade400
                                      : buttonColor,
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
                                  'Đăng nhập',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ForgotPasswordScreeen()),
                                );
                              },
                              child: Text(
                                'Quên mật khẩu',
                                style: TextStyle(
                                    color: darkTheme
                                        ? Colors.amber.shade400
                                        : buttonColor),
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Bạn chưa có tài khoản?',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(width: 5),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RegisterScreen()),
                                    );
                                  },
                                  child: Text(
                                    'Tạo tài khoản',
                                    style: TextStyle(
                                      color: darkTheme
                                          ? Colors.amber.shade400
                                          : buttonColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
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
                              borderRadius: BorderRadius.circular(36),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.2), // Màu sắc của bóng đổ
                                  spreadRadius:
                                      7, // Kích thước mở rộng của bóng
                                  blurRadius: 7, // Mờ của bóng đổ
                                  offset: Offset(0,
                                      3), // Vị trí của bóng đổ (nghĩa là x và y offset)
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 25),
                            child: Row(
                              children: [
                                Icon(Icons.facebook),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  'Facebook',
                                  style: TextStyle(fontSize: 17),
                                ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(36),
                                boxShadow: [
                                  BoxShadow(
                                    spreadRadius: 7,
                                    blurRadius: 7,
                                    color: Colors.grey.withOpacity(0.2),
                                    offset: Offset(0, 3),
                                  ),
                                ]),
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 25),
                            child: Row(
                              children: [
                                Icon(Icons.email),
                                SizedBox(
                                  width: 30,
                                ),
                                Text(
                                  'Email',
                                  style: TextStyle(fontSize: 17),
                                ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            ),
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
