import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/assets_manager.dart';
import 'package:flutter_chat_pro/widgets/app_bar_back_button.dart';
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

    //get user data from arguments
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
              // logout button
              IconButton(
                  onPressed: () {
                    // context.read<AuthenticationProvider>().logout();
                  },
                  icon: const Icon(Icons.logout),
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
                      child: Lottie.asset(AssetsManager.loading)),
                ),
                const CircularProgressIndicator(),
              ],
            );
          }

          final userModel =
              UserModel.fromMap(snapshot.data!.data()! as Map<String, dynamic>);

          return ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(userModel.image),
            ),
            title: Text(userModel.name),
            subtitle: Text(userModel.aboutMe),
          );
        },
      ),
    );
  }
}
