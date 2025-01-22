import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/utilities/assets_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}

Widget userImageWidget({
  required String imageUrl,
  required double radius,
  required Function() onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: CircleAvatar(
      radius: radius,
      backgroundImage: imageUrl.isNotEmpty
          ? CachedNetworkImageProvider(imageUrl)
          : const AssetImage(AssetsManager.userImage) as ImageProvider,
    ),
  );
}

// pick image from gallery or camera
Future<File?> pickImage({
  required bool fromCamera,
  required Function(String) onFail,
}) async {
  File? fileImage;
  if (fromCamera) {
    // get picture from camera
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile == null) {
        onFail('No Image selected');
      } else {
        fileImage = File(pickedFile.path);
      }
    } catch (e) {
      onFail(e.toString());
    }
  } else {
    // get picture from gallery
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        onFail('No Image selected');
      } else {
        fileImage = File(pickedFile.path);
      }
    } catch (e) {
      onFail(e.toString());
    }
  }

  return fileImage;
}

// pick video from gallery
Future<File?> pickVideo({
  required Function(String) onFail,
}) async {
  File? fileVideo;
  try {
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile == null) {
      onFail('No Video selected');
    } else {
      fileVideo = File(pickedFile.path);
    }
  } catch (e) {
    onFail(e.toString());
  }

  return fileVideo;
}

Center buildDateTime(groupByValue) {
  return Center(
    child: SizedBox(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            formatDate(groupByValue.timeSent, [dd, ' ', M, ',', yyyy]),
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget messageToShow({required MessageEnum type, required String message}) {
  switch (type) {
    case MessageEnum.text:
      return Text(
        message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    case MessageEnum.image:
      return const Row(
        children: [
          Icon(Icons.image_outlined),
          SizedBox(width: 10),
          Text(
            'Image',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    case MessageEnum.video:
      return const Row(
        children: [
          Icon(Icons.video_library_outlined),
          SizedBox(width: 10),
          Text(
            'Video',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    case MessageEnum.audio:
      return const Row(
        children: [
          Icon(Icons.audiotrack_outlined),
          SizedBox(width: 10),
          Text(
            'Audio',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    default:
      return Text(
        message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
  }
}

// default list of emojis for reaction and plus sign at the end for more emoji
// like love, haha, wow, sad ,angry and plus sign
List<String> reactions = [
  '👍',
  '💗',
  '😂',
  '😲',
  '😔',
  '😡',
  '➕',
];

// list of contextMenu for reply, copy and delete
List<String> contextMenu = [
  'Reply',
  'Copy',
  'Delete',
];
