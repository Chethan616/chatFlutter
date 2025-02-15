import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/my_dialogs.dart';
import 'package:flutter_chat_pro/widgets/my_app_bar.dart';
import 'package:flutter_chat_pro/widgets/info_details_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:open_settings/open_settings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDarkMode = false;

  void getThemeMode() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    setState(() {
      isDarkMode = savedThemeMode == AdaptiveThemeMode.dark;
    });
  }

  @override
  void initState() {
    getThemeMode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! String) {
      return _buildErrorScreen(textColor);
    }

    final uid = args as String;
    final authProvider = context.watch<AuthenticationProvider>();
    final bool isMyProfile = uid == authProvider.uid;

    return authProvider.isLoading
        ? _buildLoadingScreen(isDark, textColor)
        : Scaffold(
            appBar: MyAppBar(
              title: Text(
                'Profile',
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [Colors.blue.shade900, Colors.blue.shade800]
                      : [Colors.white, Colors.blue.shade100],
                ),
              ),
              child: StreamBuilder<DocumentSnapshot>(
                stream: authProvider.userStream(userID: uid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return _buildErrorWidget(textColor);
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingIndicator();
                  }

                  final userModel = UserModel.fromMap(
                      snapshot.data!.data() as Map<String, dynamic>);

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InfoDetailsCard(userModel: userModel),
                          const SizedBox(height: 25),
                          if (isMyProfile) ...[
                            _buildSettingsHeader(textColor),
                            const SizedBox(height: 20),
                            _buildSettingsCard([
                              _buildSettingsTile(
                                title: 'Account',
                                icon: Icons.person,
                                color: Colors.deepPurple,
                              ),
                              _buildSettingsTile(
                                title: 'My Media',
                                icon: Icons.photo_library,
                                color: Colors.green,
                              ),
                              _buildSettingsTile(
                                title: 'Notifications',
                                icon: Icons.notifications,
                                color: Colors.red,
                                onTap: () =>
                                    OpenSettings.openAppNotificationSetting(),
                              ),
                            ]),
                            const SizedBox(height: 20),
                            _buildSettingsCard([
                              _buildSettingsTile(
                                title: 'Help Center',
                                icon: Icons.help_center,
                                color: Colors.amber,
                              ),
                              _buildSettingsTile(
                                title: 'Share App',
                                icon: Icons.share,
                                color: Colors.blue,
                              ),
                            ]),
                            const SizedBox(height: 20),
                            _buildThemeSwitchTile(isDark),
                            const SizedBox(height: 20),
                            _buildLogoutCard(),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
  }

  Widget _buildErrorScreen(Color textColor) {
    return Scaffold(
      body: Center(
        child: Text(
          'Profile not found',
          style: TextStyle(color: textColor, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(bool isDark, Color textColor) {
    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.blue.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Theme.of(context).primaryColor),
            const SizedBox(height: 20),
            Text('Saving Image, Please wait...',
                style: TextStyle(color: textColor, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 50),
          const SizedBox(height: 20),
          Text('Failed to load profile',
              style: TextStyle(color: textColor, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildSettingsHeader(Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Text('Settings',
          style: GoogleFonts.poppins(
              fontSize: 22, fontWeight: FontWeight.w600, color: textColor)),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required IconData icon,
    required Color color,
    Function()? onTap,
  }) {
    return Material(
      color: Colors.transparent, // Ensures ripple effect works
      child: ListTile(
        leading: Icon(icon, color: color, size: 26),
        title: Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing:
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade600),
        onTap: onTap,
      ),
    );
  }

  Widget _buildThemeSwitchTile(bool isDark) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Material(
        color: Colors.transparent, // Ensures ripple effect works
        child: SwitchListTile(
          title: Text('App Theme'),
          secondary:
              Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
          value: isDarkMode,
          onChanged: (value) {
            setState(() => isDarkMode = value);
            value
                ? AdaptiveTheme.of(context).setDark()
                : AdaptiveTheme.of(context).setLight();
          },
        ),
      ),
    );
  }

  Widget _buildLogoutCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Material(
        color: Colors.transparent, // Ensures ripple effect works
        child: ListTile(
          leading: Icon(Icons.logout_rounded, color: Colors.red, size: 26),
          title: Text('Logout'),
          onTap: () => MyDialogs.showMyAnimatedDialog(
            context: context,
            title: 'Logout',
            content: 'Are you sure you want to logout?',
            textAction: 'Logout',
            onActionTap: (value, updatedText) async {
              if (value) {
                await context.read<AuthenticationProvider>().logout();
                Navigator.pushNamedAndRemoveUntil(
                    context, Constants.loginScreen, (route) => false);
              }
            },
          ),
        ),
      ),
    );
  }
}
