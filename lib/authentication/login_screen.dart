import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/assets_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();

  // Initialize selectedCountry as null
  Country? selectedCountry;

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/chat.png',
            fit: BoxFit.cover,
          ),

          // Dark overlay for better contrast
          Container(
            color: Colors.black.withOpacity(0.4),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lottie Animation
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: Lottie.asset(AssetsManager.chatBubble),
                  ),

                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'FlareChat!?!?',
                    style: GoogleFonts.openSans(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Phone Number Input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _phoneNumberController,
                      maxLength: 10,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      onChanged: (value) {
                        // Call setState to rebuild the widget when the text changes
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        counterText: '',
                        hintText: 'Enter phone number',
                        hintStyle: GoogleFonts.openSans(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.only(left: 15, right: 10),
                          child: InkWell(
                            onTap: () {
                              showCountryPicker(
                                context: context,
                                showPhoneCode: true,
                                countryListTheme: CountryListThemeData(
                                  backgroundColor: Colors.white,
                                  textStyle: GoogleFonts.openSans(fontSize: 16),
                                ),
                                onSelect: (Country country) {
                                  setState(() {
                                    selectedCountry = country;
                                  });
                                },
                              );
                            },
                            child: Text(
                              selectedCountry != null
                                  ? '${selectedCountry!.flagEmoji} +${selectedCountry!.phoneCode}'
                                  : 'Select Country',
                              style: GoogleFonts.openSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ),
                        suffixIcon: _phoneNumberController.text.length > 9 &&
                                selectedCountry != null
                            ? authProvider.isLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.green,
                                    ),
                                  )
                                : IconButton(
                                    icon: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    onPressed: () {
                                      authProvider.signInWithPhoneNumber(
                                        phoneNumber:
                                            '+${selectedCountry!.phoneCode}${_phoneNumberController.text}',
                                        context: context,
                                      );
                                    },
                                  )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Instruction Text
                  Text(
                    'We will send you a verification code to confirm your number',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
