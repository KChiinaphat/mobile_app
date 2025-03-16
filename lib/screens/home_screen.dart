import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_watchlist_app/services/auth_firebase.dart';
import 'package:movie_watchlist_app/services/tmdb_service.dart';
import 'package:movie_watchlist_app/services/firestore_service.dart';
import 'package:movie_watchlist_app/screens/movie_detail_screen.dart';
import 'package:movie_watchlist_app/models/movie.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final TMDBService _tmdbService = TMDBService();
  final FirestoreService _firestoreService = FirestoreService();
  List<Movie> searchResults = [];
  List<Movie> recommendedMovies = [];
  String searchQuery = '';
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRecommendedMovies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadRecommendedMovies() async {
    setState(() => _isLoading = true);
    try {
      recommendedMovies = await _tmdbService.getRecommendedMovies();
    } catch (e) {
      print('Error loading recommended movies: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() => searchResults = []);
      return;
    }
    setState(() => _isLoading = true);
    try {
      searchResults = await _tmdbService.searchMovies(query);
    } catch (e) {
      print('Error searching movies: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              user?.photoURL ?? 'https://via.placeholder.com/150',
            ),
            backgroundColor: Colors.grey[800],
          ),
        ),
        title: Text(
          'Movie Watchlist',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 8.0,
                color: Colors.black54,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white70),
            onPressed: () async {
              await _authService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          SizedBox(width: 8),
        ],
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
        child: SafeArea(
          child: Column(
            children: [
              // Search Bar with animation
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) {
                    searchQuery = value;
                    _searchMovies(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'ค้นหาหนัง',
                    hintStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF00AEEF)),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.white54),
                            onPressed: () {
                              setState(() {
                                searchQuery = '';
                                searchResults = [];
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              
              // Tab controller
              if (searchResults.isEmpty)
                TabBar(
                  controller: _tabController,
                  indicatorColor: Color(0xFF00AEEF),
                  indicatorWeight: 3,
                  labelColor: Color(0xFF00AEEF),
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(text: 'หนังแนะนำ'),
                    Tab(text: 'รายการดูภายหลัง'),
                  ],
                ),

              // Main content
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00AEEF)),
                        ),
                      )
                    : searchResults.isNotEmpty
                        ? _buildSearchResults()
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildRecommendedMovies(),
                              _buildWatchlist(user),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'หน้าแรก',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'โปรไฟล์',
            ),
          ],
          currentIndex: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/home');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/profile');
                break;
            }
          },
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Search Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 12,
              ),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                return _buildGridMovieCard(searchResults[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedMovies() {
    if (recommendedMovies.isEmpty) {
      return Center(child: Text('No recommended movies available'));
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 12,
        ),
        itemCount: recommendedMovies.length,
        itemBuilder: (context, index) {
          return _buildGridMovieCard(recommendedMovies[index]);
        },
      ),
    );
  }

  Widget _buildWatchlist(User? user) {
    return StreamBuilder<List<Movie>>(
      stream: _firestoreService.getWatchlist(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00AEEF)),
          ));
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_alt, size: 70, color: Colors.white30),
                SizedBox(height: 16),
                Text(
                  'ไม่มีรายการดูภายหลัง',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _tabController.animateTo(0),
                  child: Text('ดูหนังแนะนำ'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return _buildGridMovieCard(snapshot.data![index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildGridMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movie: movie),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w342${movie.posterPath}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                    Container(
                      color: Colors.grey[800],
                      child: Icon(Icons.movie, size: 40, color: Colors.white30),
                    ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,  
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                        SizedBox(width: 2),
                        Text(
                          movie.voteAverage.toString(),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}