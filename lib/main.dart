import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_watchlist_app/models/movie.dart';
import 'package:movie_watchlist_app/screens/login_screen.dart';
import 'package:movie_watchlist_app/screens/register_screen.dart';
import 'package:movie_watchlist_app/screens/home_screen.dart';
import 'package:movie_watchlist_app/screens/movie_detail_screen.dart';
import 'package:movie_watchlist_app/screens/watchlist_screen.dart';
import 'package:movie_watchlist_app/screens/profile_screen.dart';
import 'firebase_option.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Watchlist App',
      theme: ThemeData(
        primaryColor: Color(0xFF1C1C1C),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color(0xFF00AEEF),
        ),
        scaffoldBackgroundColor: Color(0xFF1C1C1C),
        appBarTheme: AppBarTheme(
          color: Color(0xFF1C1C1C),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black26,
                offset: Offset(0, 5),
              ),
            ],
          ),
          elevation: 0,
        ),
        textTheme: TextTheme(
          headlineMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black26,
                offset: Offset(0, 5),
              ),
            ],
          ),
          titleMedium: TextStyle(
            color: Colors.white70,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black26,
                offset: Offset(0, 5),
              ),
            ],
          ),
          bodyLarge: TextStyle(
            color: Colors.white70,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black26,
                offset: Offset(0, 5),
              ),
            ],
          ),
          bodyMedium: TextStyle(
            color: Colors.white70,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black26,
                offset: Offset(0, 5),
              ),
            ],
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF00AEEF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            shadowColor: Colors.black26,
            elevation: 10,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white24,
          hintStyle: TextStyle(color: Colors.white54),
          labelStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.white),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1C1C1C),
          selectedItemColor: Color(0xFF00AEEF),
          unselectedItemColor: Colors.white70,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthWrapper(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/movie-detail':
            (context) => MovieDetailScreen(
              movie: ModalRoute.of(context)!.settings.arguments as Movie,
            ),
        '/watchlist': (context) => WatchlistScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return HomeScreen();
        }
        return LoginScreen();
      },
    );
  }
}
