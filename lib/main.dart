import 'package:flutter/material.dart';
import 'yelp_service.dart'; 
import 'location_service.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import 'package:device_preview/device_preview.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const RestaurantSwipeScreen(),
    );
  }
}

class RestaurantSwipeScreen extends StatefulWidget {
  const RestaurantSwipeScreen({super.key});

  @override
  State<RestaurantSwipeScreen> createState() => _RestaurantSwipeScreenState();
}

class _RestaurantSwipeScreenState extends State<RestaurantSwipeScreen> {
  // Keeping track of our data
  int currentCardIndex = 0;
  bool isLoading = true; 
  int _currentOffset = 0; // Needed for pagination
  List<Restaurant> activeRestaurants = []; 
  
  // Services
  final YelpService _yelpService = YelpService();
  final LocationService _locationService = LocationService();
  final CardSwiperController _swiperController = CardSwiperController();

  @override
  void initState() {
    super.initState();
    _loadInitialData(); 
  }

  // Load the first batch of restaurants near the user
  Future<void> _loadInitialData() async {
    final position = await _locationService.getCurrentLocation();

    if (position != null) {
      // Just printing these for debugging, remove before release
      print("Got location: ${position.latitude}, ${position.longitude}");
      
      final results = await _yelpService.getRestaurants(
        position.latitude, 
        position.longitude
      );
      
      setState(() {
        activeRestaurants = results;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        print("Couldn't get user location, check permissions?");
      });
    }
  }

  // Getnear the end of the list
  Future<void> _fetchMoreRestaurants() async {
    _currentOffset += 20; 

    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      final newResults = await _yelpService.getRestaurants(
        position.latitude, 
        position.longitude,
        offset: _currentOffset
      );
      
      setState(() {
        activeRestaurants.addAll(newResults);
      });
    }
  }

  // Swiper controls
  void _handleNextCard() => _swiperController.swipe(CardSwiperDirection.left);
  void _handlePreviousCard() => _swiperController.undo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Deck'),
        backgroundColor: Colors.redAccent,
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            // Check if we are in portrait mode
            bool isPortrait = orientation == Orientation.portrait;

            return Column(
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      // Landscape gets more width to avoid a narrow, awkward card
                      width: isPortrait ? 400 : 650, 
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
                          : activeRestaurants.isEmpty
                              ? const Center(child: Text("No restaurants found!"))
                              : CardSwiper(
                                  controller: _swiperController,
                                  cardsCount: activeRestaurants.length,
                                  numberOfCardsDisplayed: 2,
                                  backCardOffset: const Offset(0, 0),
                                  padding: const EdgeInsets.all(24.0),
                                  onSwipe: (previousIndex, currentIndex, direction) {
                                    if (currentIndex != null && currentIndex >= activeRestaurants.length - 3) {
                                      _fetchMoreRestaurants();
                                    }
                                    return true;
                                  },
                                  cardBuilder: (context, index, horizontalThresholdPercentage, verticalThresholdPercentage) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        // The layout changes based on isPortrait
                                        child: isPortrait
                                            ? _buildPortraitCard(index)
                                            : _buildLandscapeCard(index),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ),
                ),
                // Navigation controls
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : _handlePreviousCard,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text("Previous"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[400], foregroundColor: Colors.white),
                      ),
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : _handleNextCard,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text("Next"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPortraitCard(int index) {
    return Column(
      children: [
        Expanded(child: _buildImage(index)),
        _buildInfo(index),
      ],
    );
  }

  Widget _buildLandscapeCard(int index) {
    return Row(
      children: [
        Expanded(child: _buildImage(index)),
        Expanded(child: _buildInfo(index)),
      ],
    );
  }

  Widget _buildImage(int index) {
    return Image.network(
      activeRestaurants[index].imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
    );
  }

  Widget _buildInfo(int index) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(activeRestaurants[index].name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text("${'⭐' * activeRestaurants[index].rating.round()} (${activeRestaurants[index].rating})", style: const TextStyle(fontSize: 18, color: Colors.orange)),
        ],
      ),
    );
  }
}