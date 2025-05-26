import 'package:flutter/material.dart';
import 'package:koopon/presentation/views/auth/login_screen.dart';
import 'package:koopon/presentation/views/auth/register_screen.dart';

void main() {
  runApp(MaterialApp(
    home: WelcomeScreen(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Make entire background white
      body: Column(
        children: [
          
          // White section with logo and app name
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo image
                    Image.asset(
                      'images/koopon_logo.png',
                      height: 150,
                    ),
                    
                    // App name
                    Text(
                      'KOOPON',
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    // Tagline
                    Text(
                      'U N I  D E A L S,  R E A L  F E E L S',
                      style: TextStyle(
                        fontSize: 14.0,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Blue section with welcome text and buttons
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFF1E64A0), // Blue color
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome text
                Text(
                  'Welcome !',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                SizedBox(height: 12.0),
                
                // Welcome description
                Text(
                  'Where university students connect, buy & sell preloved treasures - verified, trusted, and just for you.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
                
                SizedBox(height: 40.0),
                
                // Sign in and Sign up buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Sign In button
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          child: Text('Sign In'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFD7A0D7), // Light purple color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                          ),
                        ),
                      ),
                    ),
                    
                    // Sign Up button
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, // White color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}