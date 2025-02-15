import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:flutter_chat_pro/widgets/my_app_bar.dart';
import 'package:flutter_chat_pro/widgets/display_user_image.dart';
import 'package:provider/provider.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final AuthenticationProvider authentication =
        context.watch<AuthenticationProvider>();

    return Scaffold(
      appBar: MyAppBar(
        title: const Text('User Information'),
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.blue.shade900, // Dark blue
                    Colors.blue.shade800, // Darker blue
                  ]
                : [
                    Colors.white, // White
                    Colors.blue.shade100, // Light blue
                  ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                // User Image
                DisplayUserImage(
                  finalFileImage: authentication.finalFileImage,
                  radius: 60,
                  onPressed: () {
                    authentication.showBottomSheet(
                        context: context, onSuccess: () {});
                  },
                ),
                const SizedBox(height: 30),

                // Name Input Field
                TextField(
                  controller: _nameController,
                  maxLength: 20,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    labelText: 'Enter your name',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authentication.isLoading
                        ? null
                        : () {
                            if (_nameController.text.isEmpty ||
                                _nameController.text.length < 3) {
                              GlobalMethods.showSnackBar(
                                context,
                                'Please enter your name',
                              );
                              return;
                            }
                            saveUserDataToFireStore();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 5,
                    ),
                    child: authentication.isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Save user data to Firestore
  void saveUserDataToFireStore() async {
    final authProvider = context.read<AuthenticationProvider>();

    UserModel userModel = UserModel(
      uid: authProvider.uid!,
      name: _nameController.text.trim(),
      phoneNumber: authProvider.phoneNumber!,
      image: '',
      token: '',
      aboutMe: 'Hey there, I\'m using Flutter Chat Pro',
      lastSeen: '',
      createdAt: '',
      isOnline: true,
      friendsUIDs: [],
      friendRequestsUIDs: [],
      sentFriendRequestsUIDs: [],
    );

    authProvider.saveUserDataToFireStore(
      userModel: userModel,
      onSuccess: () async {
        // Save user data to shared preferences
        await authProvider.saveUserDataToSharedPreferences();
        navigateToHomeScreen();
      },
      onFail: () async {
        GlobalMethods.showSnackBar(context, 'Failed to save user data');
      },
    );
  }

  // Navigate to Home Screen
  void navigateToHomeScreen() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      Constants.homeScreen,
      (route) => false,
    );
  }
}
