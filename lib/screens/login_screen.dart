import 'package:flutter/material.dart';
import 'package:movie_watchlist_app/screens/register_screen.dart';
import 'package:movie_watchlist_app/services/auth_firebase.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white30,
              Color(0xFF004d7a), // เปลี่ยนเป็นสีน้ำเงิน
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Container(
                  padding: EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15.0,
                        offset: Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: Colors.white30, width: 1.5),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Logo/Icon
                        Image.asset(
                          'assets/logo.png', // Path to your logo image
                          height: 80,
                        ),
                        SizedBox(height: 16),
                        // App Title
                        Text(
                          'Movie Watchlist',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'เข้าสู่ระบบเพื่อดำเนินการต่อ',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                        SizedBox(height: 32),
                        // Email Field
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) => email = value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'โปรดป้อนที่อยู่อีเมลของคุณ';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'โปรดป้อนที่อยู่อีเมลที่ถูกต้อง';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'อีเมล',
                            hintStyle: TextStyle(color: Colors.white60),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Colors.white70,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide: BorderSide(
                                color: Colors.white30,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 2.0,
                              ),
                            ),
                            errorStyle: TextStyle(color: Colors.redAccent),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 16.0,
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        // Password Field
                        TextFormField(
                          obscureText: _obscureText,
                          onChanged: (value) => password = value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'โปรดป้อนรหัสผ่านของคุณ';
                            }
                            if (value.length < 6) {
                              return 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'รหัสผ่าน',
                            hintStyle: TextStyle(color: Colors.white60),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.white70,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide: BorderSide(
                                color: Colors.white30,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 2.0,
                              ),
                            ),
                            errorStyle: TextStyle(color: Colors.redAccent),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 16.0,
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 12),
                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Implement forgot password functionality
                            },
                            child: Text(
                              'ลืมรหัสผ่าน?',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        // Login Button
                        _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => _isLoading = true);
                                  try {
                                    final user = await _authService
                                        .signInWithEmailAndPassword(
                                          email,
                                          password,
                                        );
                                    if (user != null) {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/home',
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'อีเมลหรือรหัสผ่านไม่ถูกต้อง',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: Colors.redAccent,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10.0,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'ผิดพลาด: ${e.toString()}',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.redAccent,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10.0,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  setState(() => _isLoading = false);
                                }
                              },
                              child: Text(
                                'เข้าสู่ระบบ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Color(
                                  0xFF004d7a,
                                ), // เปลี่ยนเป็นสีน้ำเงิน
                                backgroundColor: Colors.white,
                                minimumSize: Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                elevation: 5,
                              ),
                            ),
                        SizedBox(height: 24),
                        // Sign Up Text & Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ยังไม่มีบัญชี?',
                              style: TextStyle(color: Colors.white70),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegisterScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'ลงทะเบียน',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
