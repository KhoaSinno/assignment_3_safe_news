import 'package:flutter/material.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});
  @override
  WelcomeState createState() => WelcomeState();
}

class WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaPadding = MediaQuery.of(context).padding;
    // Calculate available height within SafeArea
    final availableHeight =
        screenHeight - safeAreaPadding.top - safeAreaPadding.bottom;

    return Scaffold(
      body: SafeArea(
        child: Container(
          // This container has the gradient, acts as the ultimate background
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1, -1),
              end: Alignment(-1, 1),
              colors: [Color(0xFF2148D4), Color(0xFFE9EEFA)],
            ),
          ),
          child: Stack(
            children: [
              // Layer 1: Background Image
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height:
                    availableHeight * 0.75, // Image takes ~75% height from top
                child: Image.network(
                  "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/FHs4UB5GEK/wjp8ruhh_expires_30_days.png",
                  fit: BoxFit.cover,
                ),
              ),

              // Layer 2: Bottom White Section with "Explore" button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height:
                    availableHeight *
                    0.35, // Bottom section takes ~35% height from bottom
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    color: Color(0xFFFFFFFF),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          // Navigate to desired screen
                          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(128),
                            color: Color(0xFF2C5AD0),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 23,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Explore",
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 11),
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(128),
                                  child: Image.network(
                                    "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/FHs4UB5GEK/okvoq8py_expires_30_days.png",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Layer 3: Overlay Text (positioned over the image, above the white section)
              Positioned(
                top:
                    availableHeight *
                    0.40, // Adjust this percentage for vertical positioning
                left: 32,
                right: 32,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Get The Latest News And Updates",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.black.withValues(alpha: 0.7),
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "From Politics to Entertainment: Your One-Stop Source for Comprehensive Coverage of the Latest News and Developments Across the Glob will be right on your hand.",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 18,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withValues(alpha: 0.6),
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
