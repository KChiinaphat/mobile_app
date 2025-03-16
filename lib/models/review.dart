class Review {
  final String userId;
  final int movieId;
  final String comment;
  final double rating;
  final DateTime createdAt;

  Review({
    required this.userId,
    required this.movieId,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      userId: json['userId'],
      movieId: json['movieId'],
      comment: json['comment'],
      rating: (json['rating'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'movieId': movieId,
      'comment': comment,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}