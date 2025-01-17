import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/assets_manager.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:flutter_chat_pro/widgets/app_bar_back_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;

    // Get user data from arguments
    final uid = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text('Profile'),
        actions: [
          currentUser.uid == uid
              ?
              // log out button
              IconButton(
                  onPressed: () async {
                    // navigate to settings screen
                    Navigator.pushNamed(
                      context,
                      Constants.settingsScreen,
                      arguments: uid,
                    );
                  },
                  icon: const Icon(Icons.settings),
                )
              : const SizedBox(),
        ],
      ),
      body: StreamBuilder(
        stream: context.read<AuthenticationProvider>().userStream(userId: uid),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              children: [
                Center(
                  child: Container(
                    height: 400,
                    width: 200,
                    child: Lottie.asset(AssetsManager.loading),
                  ),
                ),
                const CircularProgressIndicator(),
              ],
            );
          }

          final userModel =
              UserModel.fromMap(snapshot.data!.data()! as Map<String, dynamic>);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              children: [
                Center(
                  child: userImageWidget(
                    imageUrl: userModel.image,
                    radius: 60,
                    onTap: () {
                      // Navigate to user profile with uid as arguments
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  userModel.name,
                  style: GoogleFonts.openSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  userModel.phoneNumber, // Display phone number
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                buildFriendRequestsButton(
                  currentUser: currentUser,
                  userModel: userModel,
                ),
                const SizedBox(height: 10),
                buildFriendsButton(
                  currentUser: currentUser,
                  userModel: userModel,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 40,
                      width: 40,
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('About Me',
                        style: GoogleFonts.openSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(width: 10),
                    const SizedBox(
                      height: 40,
                      width: 40,
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  userModel.aboutMe,
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Friend Requests Button
  Widget buildFriendRequestsButton({
    required UserModel currentUser,
    required UserModel userModel,
  }) {
    if (currentUser.uid == userModel.uid &&
        userModel.friendRequestsUIDs.isNotEmpty) {
      return buildElevatedButton(
        onPressed: () {
          // Navigate to friend requests screen
          Navigator.pushNamed(
            context,
            Constants.friendRequestsScreen,
          );
        },
        label: 'View Friend Requests',
        width: MediaQuery.of(context).size.width * 0.7,
        backgroundColor: Theme.of(context).cardColor,
        textColor: Theme.of(context).primaryColor,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  // Friends Button
  Widget buildFriendsButton({
    required UserModel currentUser,
    required UserModel userModel,
  }) {
    if (currentUser.uid == userModel.uid && userModel.friendsUIDs.isNotEmpty) {
      return buildElevatedButton(
          onPressed: () {
            // Navigate to friends screen
            Navigator.pushNamed(
              context,
              Constants.friendsScreen,
            );
          },
          label: 'View Friends',
          width: MediaQuery.of(context).size.width * 0.7,
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).primaryColor);
    } else {
      if (currentUser.uid != userModel.uid) {
        // show cancel friend request button if the user sent us friend request
        // else show send friend request button

        if (userModel.friendRequestsUIDs.contains(currentUser.uid)) {
          // Show send friend request button
          return buildElevatedButton(
            onPressed: () async {
              await context
                  .read<AuthenticationProvider>()
                  .cancelFriendRequest(friendId: userModel.uid)
                  .whenComplete(() {
                showSnackBar(context, 'friend request cancelled');
              });
            },
            label: 'Cancel Friend Request',
            width: MediaQuery.of(context).size.width * 0.7,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).primaryColor,
          );
        } else if (userModel.sentFriendRequestsUIDs.contains(currentUser.uid)) {
          // Show send friend request button
          return buildElevatedButton(
              onPressed: () async {
                await context
                    .read<AuthenticationProvider>()
                    .acceptFriendRequest(friendId: userModel.uid)
                    .whenComplete(() {
                  showSnackBar(
                      context, 'You are now Friends with ${userModel.name}');
                });
              },
              label: 'Accept Friend Request',
              width: MediaQuery.of(context).size.width * 0.7,
              backgroundColor: Theme.of(context).cardColor,
              textColor: Theme.of(context).primaryColor);
        } else if (userModel.friendsUIDs.contains(currentUser.uid)) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildElevatedButton(
                onPressed: () async {
                  // show unfriend dialog to confirm ask the user if they want to unfriend
                  // create ȧ dialog to confirm logout
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text(
                        'Unfriend',
                        textAlign: TextAlign.center,
                      ),
                      content: Text(
                        'Are you sure you want to Unfriend ${userModel.name}?',
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            // remove friend
                            await context
                                .read<AuthenticationProvider>()
                                .removeFriend(friendId: userModel.uid)
                                .whenComplete(() {
                              showSnackBar(context,
                                  'You are no longer friends with ${userModel.name}');
                            });
                          },
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
                  );
                },
                label: 'Unfriend',
                width: MediaQuery.of(context).size.width * 0.4,
                backgroundColor:
                    Theme.of(context).buttonTheme.colorScheme!.primary,
                textColor: Colors.white,
              ),
              buildElevatedButton(
                onPressed: () async {
                  // navigate to chat screen
                  // navigate to chat screen with the following arguments
                  // 1. friend uid 2. friend name 3. friend image 4. group with an empty string
                  Navigator.pushNamed(context, Constants.chatScreen,
                      arguments: {
                        Constants.contactUID: userModel.uid,
                        Constants.contactName: userModel.name,
                        Constants.contactImage: userModel.image,
                        Constants.groupId: '',
                      });
                },
                label: 'Chat',
                width: MediaQuery.of(context).size.width * 0.4,
                backgroundColor: Theme.of(context).cardColor,
                textColor: Theme.of(context).primaryColor,
              ),
            ],
          );
        } else {
          // Show send friend request button
          return buildElevatedButton(
            onPressed: () async {
              await context
                  .read<AuthenticationProvider>()
                  .sendFriendRequest(friendId: userModel.uid)
                  .whenComplete(() {
                showSnackBar(context, 'friend request sent');
              });
            },
            label: 'Send Friend Request',
            width: MediaQuery.of(context).size.width * 0.7,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).primaryColor,
          );
        }
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  // Common button builder
  Widget buildElevatedButton({
    required VoidCallback onPressed,
    required String label,
    required double width,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 5,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
