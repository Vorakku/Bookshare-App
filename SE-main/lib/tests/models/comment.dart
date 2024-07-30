import 'package:bookshare/tests/models/user.dart';

class Comment {
  final String id;
  final String userId;
  final String bookId;
  final String comment;
  final DateTime createdAt;
  final User user;

  Comment({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.comment,
    required this.createdAt,
    required this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      bookId: json['book_id'].toString(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'book_id': bookId,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'user': user.toJson(),
    };
  }
}
