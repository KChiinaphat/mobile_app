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

  Future<void> _editReview(
    String reviewId,
    String newComment,
    double newRating,
  ) async {
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
          backgroundColor: Color(0xFF004d7a),
          title: Text('แก้ไขความคิดเห็น', style: TextStyle(color: Colors.white)),
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
                          return 'โปรดระบุความคิดเห็นของคุณ';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'เขียนความคิดเห็นของคุณ...',
                        labelText: 'ความคิดเห็น',
                        hintStyle: TextStyle(color: Colors.white60),
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
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
                    Text(
                      'คะแนน: $newRating/10',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ยกเลิก', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_editFormKey.currentState!.validate()) {
                  await _editReview(review.id, newComment, newRating);
                  Navigator.pop(context);
                }
              },
              child: Text('บันทึก', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00AEEF),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review ${widget.movie.title}'),
        backgroundColor: Color(0xFF004d7a), // เปลี่ยนเป็นสีน้ำเงิน
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF004d7a), // เปลี่ยนเป็นสีน้ำเงิน
              Color(0xFF0C0C0C),
            ],
          ),
        ),
        child: Padding(
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
                      return 'โปรดระบุความคิดเห็นของคุณ';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'เขียนความคิดเห็นของคุณ...',
                    hintStyle: TextStyle(color: Colors.white60),
                    labelText: 'ความคิดเห็น',
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide(color: Colors.white30, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide(color: Colors.white, width: 2.0),
                    ),
                    errorStyle: TextStyle(color: Colors.redAccent),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 16.0,
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
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
                Text(
                  'คะแนน: $rating/10',
                  style: TextStyle(color: Colors.white),
                ),
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
                    }
                  },
                  child: Text('ส่งความคิดเห็น'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00AEEF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 24.0,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'ความคิดเห็นอื่น ๆ',
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
                        return Text(
                          'No reviews yet',
                          style: TextStyle(color: Colors.white70),
                        );
                      }
                      return ListView(
                        children:
                            snapshot.data!.map((review) {
                              return Card(
                                color: Colors.white.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: ListTile(
                                  title: Text(
                                    'คะแนน: ${review.rating}/10',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review.comment,
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      Text(
                                        'โดย: ${review.userName}',
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                    ],
                                  ),
                                  trailing:
                                      user!.uid == review.userId
                                          ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () {
                                                  _showEditDialog(review);
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  _deleteReview(review.id);
                                                },
                                              ),
                                            ],
                                          )
                                          : null,
                                ),
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
      ),
    );
  }
}
