import 'package:cloud_firestore/cloud_firestore.dart';

class News {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String? imageUrl;

  News({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.imageUrl,
  });

  factory News.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return News(
      id: snapshot.id,
      title: data['title'],
      content: data['content'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
    };
  }
}