import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addToWatchlist(String userId, Movie movie) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .doc(movie.id.toString())
        .set(movie.toJson());
  }

  Future<void> removeFromWatchlist(String userId, int movieId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .doc(movieId.toString())
        .delete();
  }

  Stream<List<Movie>> getWatchlist(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Movie.fromJson(doc.data())).toList(),
        );
  }

  Future<void> addReview(Review review) async {
    await _firestore.collection('reviews').doc(review.id).set(review.toJson());
  }

  Stream<List<Review>> getReviews(int movieId) {
    return _firestore
        .collection('reviews')
        .where('movieId', isEqualTo: movieId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Review.fromJson(doc.data())).toList(),
        );
  }

  Future<void> deleteReview(String reviewId) async {
    await _firestore.collection('reviews').doc(reviewId).delete();
  }

  Future<void> updateReview(
    String reviewId,
    String newComment,
    double newRating,
  ) async {
    await _firestore.collection('reviews').doc(reviewId).update({
      'comment': newComment,
      'rating': newRating,
    });
  }

  String generateReviewId() {
    return _firestore.collection('reviews').doc().id;
  }
}
