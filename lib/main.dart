import 'package:flutter/material.dart';
import 'yelp_service.dart'; 

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

  @override
  void initState() {
    super.initState();
    _loadInitialData(); // Trigger the network call when app opens
  }

  Future<void> _loadInitialData() async {
    //  Helsinki coordinates temporarily to test
    final results = await _yelpService.getRestaurants(60.1699, 24.9384);
    
    setState(() {
      activeRestaurants = results;
      isLoading = false;
    });
  }

  void _handleNextCard() {
    if (currentCardIndex < activeRestaurants.length - 1) {
      setState(() {
        currentCardIndex++;
      });
    } else {
      print("End of list reached. Time to call Yelp pagination!");
    }
  }

  void _handlePreviousCard() {
    if (currentCardIndex > 0) {
      setState(() {
        currentCardIndex--;
      });
    }
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  width: double.infinity,
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
                        // If data is loading, show a spinner. If not, show the real text
                        isLoading 
                        ? const CircularProgressIndicator(color: Colors.redAccent)
                        : activeRestaurants.isEmpty 
                            ? const Text("No restaurants found!")
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.restaurant, size: 80, color: Colors.redAccent),
                                  const SizedBox(height: 20),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      activeRestaurants[currentCardIndex].name,
                                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "⭐⭐⭐⭐ (${activeRestaurants[currentCardIndex].rating})", 
                                    style: const TextStyle(fontSize: 18, color: Colors.orange)
                                  ),
                                ],
                              ),
                      ],
                    ),
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