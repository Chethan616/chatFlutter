import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/assets_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    checkAuthentication();
    super.initState();
  }

  void checkAuthentication() async {
    final authProvider = context.read<AuthenticationProvider>();
    bool isAuthenticated = await authProvider.checkAuthenticationState();

    navigate(isAuthenticated: isAuthenticated);
  }

  navigate({required bool isAuthenticated}) {
    if (isAuthenticated) {
      Navigator.pushReplacementNamed(context, Constants.homeScreen);
    } else {
      Navigator.pushReplacementNamed(context, Constants.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.purple.shade400,
            ],
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // To make the column take only the space it needs
              children: [
                // Lottie Animation
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Lottie.asset(
                    AssetsManager.chatBubble,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20), // Spacing
                // Linear Progress Indicator
                const SizedBox(
                  width: 200, // Set a fixed width for the progress indicator
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white54,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_chat_pro/constants.dart';
// import 'package:flutter_chat_pro/providers/authentication_provider.dart';
// import 'package:flutter_chat_pro/utilities/assets_manager.dart';
// import 'package:lottie/lottie.dart';
// import 'package:provider/provider.dart';

// class LandingScreen extends StatefulWidget {
//   const LandingScreen({super.key});

//   @override
//   State<LandingScreen> createState() => _LandingScreenState();
// }

// class _LandingScreenState extends State<LandingScreen> {
//   @override
//   void initState() {
//     checkAthentication();
//     super.initState();
//   }

//   void checkAthentication() async {
//     final authProvider = context.read<AuthenticationProvider>();
//     bool isAuthenticated = await authProvider.checkAuthenticationState();

//     navigate(isAuthenticated: isAuthenticated);
//   }

//   navigate({required bool isAuthenticated}) {
//     if (isAuthenticated) {
//       Navigator.pushReplacementNamed(context, Constants.homeScreen);
//     } else {
//       Navigator.pushReplacementNamed(context, Constants.loginScreen);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           Image.asset(
//             'assets/images/chat.png',
//             fit: BoxFit.cover,
//           ),
//           Center(
//             child: SizedBox(
//               height: 400,
//               width: 200,
//               child: Column(
//                 children: [
//                   Lottie.asset(AssetsMenager.chatBubble),
//                   const LinearProgressIndicator(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
