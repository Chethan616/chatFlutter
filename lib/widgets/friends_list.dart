import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/search_provider.dart';
import 'package:flutter_chat_pro/streams/data_repository.dart';
import 'package:flutter_chat_pro/widgets/friend_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class FriendsList extends StatelessWidget {
  const FriendsList({
    super.key,
    required this.viewType,
    this.groupId = '',
    this.groupMembersUIDs = const [],
    this.limit = 20,
    this.isLive = true,
  });

  final FriendViewType viewType;
  final String groupId;
  final List<String> groupMembersUIDs;
  final int limit;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
                  Colors.deepPurple.shade100,
                  Colors.indigo.shade100,
                  Colors.blueGrey.shade100,
                ],
        ),
      ),
      child: Consumer2<AuthenticationProvider, SearchProvider>(
        builder: (context, authProvider, searchProvider, child) {
          final uid = authProvider.userModel!.uid;
          final searchQuery = searchProvider.searchQuery;

          return FutureBuilder<Query>(
            future: DataRepository.getFriendsQuery(
              uid: uid,
              groupID: groupId,
              viewType: viewType,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Lottie.asset(
                    'assets/lottie/loading.json',
                    width: 150,
                  ),
                );
              }

              if (snapshot.hasError) {
                return _buildErrorState('Something went wrong 😢');
              }

              if (!snapshot.hasData) {
                return _buildEmptyState('No friends found');
              }

              return Scrollbar(
                child: FirestorePagination(
                  limit: limit,
                  isLive: isLive,
                  query: snapshot.data!,
                  itemBuilder: (context, documentSnapshot, index) {
                    final document = documentSnapshot[index];
                    final friend = UserModel.fromMap(
                        document.data() as Map<String, dynamic>);

                    // 🔹 Filter based on viewType
                    if (viewType == FriendViewType.friendRequests) {
                      // Only show users who have sent friend requests
                      if (!authProvider.userModel!.friendRequestsUIDs
                          .contains(friend.uid)) {
                        return const SizedBox
                            .shrink(); // Skip if not in requests
                      }
                    }

                    // Search filter
                    if (!friend.name
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase())) {
                      if (index == documentSnapshot.length - 1) {
                        final hasMatches = documentSnapshot.any((doc) {
                          final user = UserModel.fromMap(
                              doc.data() as Map<String, dynamic>);
                          return user.name
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase());
                        });

                        if (!hasMatches) {
                          return _buildEmptySearchState();
                        }
                      }
                      return const SizedBox.shrink();
                    }

                    // Group membership check
                    if (groupMembersUIDs.contains(friend.uid)) {
                      if (index == documentSnapshot.length - 1 &&
                          documentSnapshot.every(
                              (doc) => groupMembersUIDs.contains(doc.id))) {
                        return _buildInfoMessage(
                            'All friends are already in the group');
                      }
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: FriendWidget(
                          friend: friend,
                          viewType: viewType,
                          groupId: groupId,
                        ),
                      ),
                    );
                  },
                  initialLoader: Center(
                    child: Lottie.asset(
                      'assets/lottie/loading.json',
                      width: 150,
                    ),
                  ),
                  onEmpty: _buildEmptyState('No friends found'),
                  bottomLoader: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/error.json',
            width: 200,
          ),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/empty.json',
            width: 250,
          ),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        children: [
          Lottie.asset(
            'assets/lottie/search.json',
            width: 200,
          ),
          Text(
            'No matches found',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoMessage(String message) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 10),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
