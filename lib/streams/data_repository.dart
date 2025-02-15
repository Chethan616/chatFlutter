import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/models/group_model.dart';

class DataRepository {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get chatsList qury
  static Query getChatsListQuery({
    required String userId,
    GroupModel? groupModel,
  }) {
    Query query;
    if (groupModel != null) {
      query = _firestore
          .collection(Constants.groups)
          .where(Constants.membersUIDs, arrayContains: userId)
          .where(Constants.isPrivate, isEqualTo: groupModel.isPrivate)
          .orderBy(Constants.timeSent, descending: true);
      return query;
    } else {
      query = _firestore
          .collection(Constants.users)
          .doc(userId)
          .collection(Constants.chats)
          .orderBy(Constants.timeSent, descending: true);
      return query;
    }
  }

  // Get all users query
  static Query getUsersQuery({required String userID}) {
    return _firestore.collection(Constants.users);
  }

  // Get friends query based on FriendViewType
  static Future<Query> getFriendsQuery({
    required String uid,
    required FriendViewType viewType,
    String groupID = '',
  }) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (viewType == FriendViewType.friendRequests) {
      // Fetch users who have sent friend requests
      final friendRequestsUIDs =
          userDoc.get('friendRequestsUIDs') as List<dynamic>;
      if (friendRequestsUIDs.isEmpty) {
        // Return an empty query if no requests exist
        return FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: '');
      }
      return FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendRequestsUIDs);
    } else if (viewType == FriendViewType.friends) {
      // Fetch friends
      final friendsUIDs = userDoc.get('friendsUIDs') as List<dynamic>;
      return FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendsUIDs);
    } else {
      // Fetch all users (for other cases)
      return FirebaseFirestore.instance.collection('users');
    }
  }

  // Helper method to get group awaiting approval members
  static Future<List<String>> getGroupAwaitingUIDs(
      {required String groupID}) async {
    DocumentSnapshot groupDoc =
        await _firestore.collection(Constants.groups).doc(groupID).get();
    if (groupDoc.exists) {
      List<dynamic> awaitingUIDs =
          groupDoc.get(Constants.awaitingApprovalUIDs) ?? [];
      return awaitingUIDs.cast<String>();
    }

    return [];
  }

  // Helper method to get user's friend requests
  static Future<List<String>> getUsersFriendRequestsUIDs(
      {required String uid}) async {
    DocumentSnapshot userDoc =
        await _firestore.collection(Constants.users).doc(uid).get();
    if (userDoc.exists) {
      List<dynamic> friendRequestsUIDs =
          userDoc.get(Constants.friendRequestsUIDs) ?? [];
      return friendRequestsUIDs.cast<String>();
    }
    return [];
  }

  // Helper method to get user's friends
  static Future<List<String>> getUsersFriendsUIDs({required String uid}) async {
    DocumentSnapshot userDoc =
        await _firestore.collection(Constants.users).doc(uid).get();
    if (userDoc.exists) {
      List<dynamic> friendsUIDs = userDoc.get(Constants.friendsUIDs) ?? [];
      return friendsUIDs.cast<String>();
    }

    return [];
  }

  // Get messages query
  static Query getMessagesQuery({
    required String userId,
    required String contactUID,
    required bool isGroup,
  }) {
    Query query;
    if (isGroup) {
      query = _firestore
          .collection(Constants.groups)
          .doc(contactUID)
          .collection(Constants.messages)
          .orderBy(Constants.timeSent, descending: true);
      return query;
    } else {
      query = _firestore
          .collection(Constants.users)
          .doc(userId)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .orderBy(Constants.timeSent, descending: true);
      return query;
    }
  }
}
