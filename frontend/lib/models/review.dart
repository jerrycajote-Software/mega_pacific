class Review {
  final int id;
  final int rating;
  final String? comment;
  final DateTime? createdAt;
  final String userName;

  Review({
    required this.id,
    required this.rating,
    this.comment,
    this.createdAt,
    required this.userName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      userName: json['user_name'] ?? 'Anonymous',
    );
  }
}
