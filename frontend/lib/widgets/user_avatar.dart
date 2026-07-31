import 'package:flutter/material.dart';
import '../constants/api_constants.dart';

class UserAvatar extends StatelessWidget {
  final String? profilePicture;
  final double radius;

  const UserAvatar({
    super.key,
    required this.profilePicture,
    this.radius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;

    if (profilePicture == null || profilePicture!.isEmpty) {
      imageProvider = NetworkImage('${ApiConstants.baseUrl}/static/avatars/2.jpg');
    } else if (profilePicture!.startsWith('http')) {
      imageProvider = NetworkImage(profilePicture!);
    } else if (profilePicture!.startsWith('assets/avatars/')) {
      imageProvider = NetworkImage('${ApiConstants.baseUrl}/static/avatars/${profilePicture!.split('/').last}');
    } else if (profilePicture!.endsWith('.jpg') || profilePicture!.endsWith('.png')) {
      // Handles cases like "2.jpg"
      imageProvider = NetworkImage('${ApiConstants.baseUrl}/static/avatars/$profilePicture');
    } else {
      // In case it's a relative path from backend, like "/media/..."
      imageProvider = NetworkImage('${ApiConstants.baseUrl}$profilePicture');
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      backgroundImage: imageProvider,
    );
  }
}
