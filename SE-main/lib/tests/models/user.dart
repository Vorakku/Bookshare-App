import 'package:flutter/material.dart';

class User {
  User({
    required this.id,
    required this.username,
    required this.email,
    this.description,
    this.profileImage,

    //Newly added code
    this.token,
  });

  final String id;
  String username;
  final String email;
  final String? description;
  final String? profileImage;

  //Newly added code
  final String? token;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '', // Ensure id is not null
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profile_image'] ?? '',
      description: json['description'] ?? '',

      //Newly added code
      token: json['token'] ?? '',
      // Provide a default value if null
      // username: json['name'] ?? '', // Provide a default value if null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profile_image': profileImage,
      'description': description, 
      'token': token,
    };
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email, description: $description, profileImage: $profileImage}';
  }

  void updateUsername(String newUsername) {
  username = newUsername;
  }

}
