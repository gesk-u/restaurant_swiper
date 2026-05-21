import 'package:flutter/material.dart';
import 'yelp_service.dart'; 
import 'location_service.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

void main() {
  runApp(const MyApp());
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
  int currentCardIndex = 0;
  bool isLoading = true; 
  List<Restaurant> activeRestaurants = []; 
  final YelpService _yelpService = YelpService();
  final LocationService _locationService = LocationService();
  final CardSwiperController _swiperController = CardSwiperController();

  @override
  void initState() {
    super.initState();
    _loadInitialData(); // Trigger the network call when app opens
  }

  Future<void> _loadInitialData() async {
    // 1. Ask the phone for the current GPS coordinates
    final position = await _locationService.getCurrentLocation();

    // 2. If the user allowed tracking, use their real coordinates!
    if (position != null) {
      print(" REAL GPS COORDINATES: Latitude: ${position.latitude}, Longitude: ${position.longitude}");
      final results = await _yelpService.getRestaurants(
        position.latitude, 
        position.longitude
      );
      
      setState(() {
        activeRestaurants = results;
        isLoading = false;
      });
    } else {
      // 3. If they denied it, stop loading and maybe show an error
      setState(() {
        isLoading = false;
        print("Could not get location. User denied permission.");
      });
    }
  }

  void _handleNextCard() {
      // Throws the card off the screen to the left
      _swiperController.swipe(CardSwiperDirection.left);
    }

    void _handlePreviousCard() {
      // Animates the previously dismissed card back onto the screen from the left!
      _swiperController.undo();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Deck'),
        backgroundColor: Colors.redAccent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Center( 
                child: SizedBox(
                  width: 400, 
                  child: isLoading 
                    ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
                    : activeRestaurants.isEmpty 
                        ? const Center(child: Text("No restaurants found!"))
                        : CardSwiper(
                            controller: _swiperController,
                            cardsCount: activeRestaurants.length,
                            numberOfCardsDisplayed: 2, // Shows the next card peeking out behind!
                            backCardOffset: const Offset(0, 40),
                            padding: const EdgeInsets.all(24.0),
                            cardBuilder: (context, index, horizontalThresholdPercentage, verticalThresholdPercentage) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.network(
                                                activeRestaurants[index].imageUrl,
                                                // The height: 250 line is GONE!
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => 
                                                    const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                            child: Text(
                                              activeRestaurants[index].name,
                                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "${'⭐' * activeRestaurants[index].rating.round()} (${activeRestaurants[index].rating})", 
                                            style: const TextStyle(fontSize: 18, color: Colors.orange)
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : _handlePreviousCard,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Previous"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : _handleNextCard,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("Next"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}