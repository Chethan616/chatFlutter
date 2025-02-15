// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_chat_pro/enums/enums.dart';
// import 'package:flutter_chat_pro/widgets/my_app_bar.dart';
// import 'package:flutter_chat_pro/widgets/friends_list.dart';

// class FriendRequestScreen extends StatefulWidget {
//   const FriendRequestScreen({super.key, this.groupId = ''});

//   final String groupId;

//   @override
//   State<FriendRequestScreen> createState() => _FriendRequestScreenState();
// }

// class _FriendRequestScreenState extends State<FriendRequestScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: MyAppBar(
//         title: const Text('Requests'),
//         onPressed: () => Navigator.pop(context),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             // cupertinosearchbar
//             CupertinoSearchTextField(
//               placeholder: 'Search',
//               style: const TextStyle(color: Colors.white),
//               onChanged: (value) {
//                 print(value);
//               },
//             ),

//             Expanded(
//                 child: FriendsList(
//               viewType: FriendViewType.friendRequests,
//               groupId: widget.groupId,
//             )),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/widgets/my_app_bar.dart';
import 'package:flutter_chat_pro/widgets/friends_list.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key, this.groupId = ''});

  final String groupId;

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: MyAppBar(
        title: const Text('Requests'),
        onPressed: () => Navigator.pop(context),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    Colors.deepPurple.shade900,
                    Colors.indigo.shade900,
                    Colors.blueGrey.shade900,
                  ]
                : [
                    Colors.deepPurple.shade50,
                    Colors.indigo.shade50,
                    Colors.blueGrey.shade50,
                  ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Bar
              CupertinoSearchTextField(
                placeholder: 'Search requests...',
                placeholderStyle: GoogleFonts.poppins(
                  color:
                      isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                  ),
                ),
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  color:
                      isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                suffixIcon: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color:
                      isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                onChanged: (value) {
                  // Handle search query changes
                  print(value);
                },
              ),

              const SizedBox(height: 16),

              // Friends List
              Expanded(
                child: FriendsList(
                  viewType: FriendViewType.friendRequests,
                  groupId: widget.groupId,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
