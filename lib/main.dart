import 'package:flutter/material.dart';
import 'yelp_service.dart';
import 'location_service.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

void main() {
  runApp(const MaterialApp(home: RestaurantSwipeScreen(), debugShowCheckedModeBanner: false));
}

// --- SCREEN: Handles data and state ---
class RestaurantSwipeScreen extends StatefulWidget {
  const RestaurantSwipeScreen({super.key});

  @override
  State<RestaurantSwipeScreen> createState() => _RestaurantSwipeScreenState();
}

class _RestaurantSwipeScreenState extends State<RestaurantSwipeScreen> {
  bool isLoading = true;
  int _currentOffset = 0;
  List<Restaurant> activeRestaurants = [];

  // My services for data and GPS
  final YelpService _yelpService = YelpService();
  final LocationService _locationService = LocationService();
  final CardSwiperController _swiperController = CardSwiperController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Initial fetch: Get the user's location, then pull the first batch of results
  Future<void> _loadInitialData() async {
    final pos = await _locationService.getCurrentLocation();
    if (pos != null) {
      final results = await _yelpService.getRestaurants(pos.latitude, pos.longitude);
      setState(() { activeRestaurants = results; isLoading = false; });
    }
  }

  // Infinite scroll logic: Fetch more when we run low on cards
  Future<void> _fetchMoreRestaurants() async {
    _currentOffset += 20;
    final pos = await _locationService.getCurrentLocation();
    if (pos != null) {
      final newResults = await _yelpService.getRestaurants(pos.latitude, pos.longitude, offset: _currentOffset);
      setState(() { activeRestaurants.addAll(newResults); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Deck'), backgroundColor: Colors.redAccent),
      body: SafeArea(
        // Using OrientationBuilder so the app adapts to rotating the phone
        child: OrientationBuilder(
          builder: (context, orientation) {
            bool isPortrait = orientation == Orientation.portrait;
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: SizedBox(
                      // Landscape gets more space so it's not super narrow
                      width: isPortrait ? 400 : 650,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
                          : CardSwiper(
                              controller: _swiperController,
                              cardsCount: activeRestaurants.length,
                              onSwipe: (_, index, __) {
                                // Trigger more data when we get near the end of the stack (3 cards left)
                                if (index != null && index >= activeRestaurants.length - 3) _fetchMoreRestaurants();
                                return true;
                              },
                              // Using my separate RestaurantCard widget to keep this file clean
                              cardBuilder: (ctx, index, _, __) => RestaurantCard(
                                restaurant: activeRestaurants[index],
                                isPortrait: isPortrait,
                              ),
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(onPressed: _swiperController.undo, icon: const Icon(Icons.arrow_back), label: const Text("Previous")),
                      ElevatedButton.icon(onPressed: () => _swiperController.swipe(CardSwiperDirection.left), icon: const Icon(Icons.arrow_forward), label: const Text("Next")),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// --- COMPONENT: Handles display logic only ---
// Extracted this into a separate widget so I can easily swap layouts for landscape mode
class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final bool isPortrait;

  const RestaurantCard({super.key, required this.restaurant, required this.isPortrait});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        // If it's wide (landscape), use a Row. If tall (portrait), use a Column.
        child: isPortrait 
          ? Column(children: [Expanded(child: _buildImage()), _buildInfo()])
          : Row(children: [Expanded(child: _buildImage()), Expanded(child: _buildInfo())]),
      ),
    );
  }
  // Reusable helpers so I don't repeat code
  Widget _buildImage() => Image.network(restaurant.imageUrl, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 80));

  Widget _buildInfo() => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(restaurant.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text("${'⭐' * restaurant.rating.round()} (${restaurant.rating})", style: const TextStyle(fontSize: 18, color: Colors.orange)),
      ],
    ),
  );
}