import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_watchlist_app/models/movie.dart';
import 'package:movie_watchlist_app/services/firestore_service.dart';

class ReviewScreen extends StatefulWidget {
  final Movie movie;

  ReviewScreen({required this.movie});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  String comment = '';
  double rating = 0.0;
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _deleteReview(String reviewId) async {
    await _firestoreService.deleteReview(reviewId);
    setState(() {});
  }

  Future<void> _editReview(String reviewId, String newComment, double newRating) async {
    await _firestoreService.updateReview(reviewId, newComment, newRating);
    setState(() {});
  }

  void _showEditDialog(Review review) {
    final _editFormKey = GlobalKey<FormState>();
    String newComment = review.comment;
    double newRating = review.rating;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Review'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Form(
                key: _editFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: newComment,
                      maxLines: 3,
                      onChanged: (value) => newComment = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your review';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Write your review...',
                        labelText: 'Review',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 20),
                    Slider(
                      value: newRating,
                      min: 0,
                      max: 10,
                      divisions: 10,
                      label: newRating.toString(),
                      onChanged: (value) {
                        setState(() => newRating = value);
                      },
                    ),
                    Text('Rating: $newRating/10', style: TextStyle(color: Colors.black)),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_editFormKey.currentState!.validate()) {
                  await _editReview(review.id, newComment, newRating);
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Review ${widget.movie.title}')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLines: 3,
                onChanged: (value) => comment = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your review';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Write your review...',
                  labelText: 'Review',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Slider(
                value: rating,
                min: 0,
                max: 10,
                divisions: 10,
                label: rating.toString(),
                onChanged: (value) {
                  setState(() => rating = value);
                },
              ),
              Text('Rating: $rating/10', style: TextStyle(color: Colors.white)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final review = Review(
                      id: _firestoreService.generateReviewId(),
                      userId: user!.uid,
                      userName: user!.displayName ?? 'Anonymous',
                      movieId: widget.movie.id,
                      comment: comment,
                      rating: rating,
                      createdAt: DateTime.now(),
                    );
                    await _firestoreService.addReview(review);
                    Navigator.pop(context);
                  }
                },
                child: Text('Submit Review'),
              ),
              SizedBox(height: 20),
              Text(
                'Other Reviews',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Expanded(
                child: StreamBuilder<List<Review>>(
                  stream: _firestoreService.getReviews(widget.movie.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No reviews yet');
                    }
                    return ListView(
                      children: snapshot.data!.map((review) {
                        return ListTile(
                          title: Text(
                            'Rating: ${review.rating}/10',
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.comment,
                                style: TextStyle(color: Colors.white70),
                              ),
                              Text(
                                'By: ${review.userName}',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ],
                          ),
                          trailing: user!.uid == review.userId
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.white),
                                      onPressed: () {
                                        _showEditDialog(review);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        _deleteReview(review.id);
                                      },
                                    ),
                                  ],
                                )
                              : null,
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
