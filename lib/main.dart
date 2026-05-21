import 'package:flutter/material.dart';

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
  // Simple track-index pointer to simulate mock state arrays manually
  int currentCardIndex = 0;
  final List<String> dummyRestaurants = [
    "Pizzeria Luce", 
    "Burger Joint", 
    "Sushi Express", 
    "Taco House"
  ];

  void _handleNextCard() {
    if (currentCardIndex < dummyRestaurants.length - 1) {
      setState(() {
        currentCardIndex++;
      });
    } else {
      // Endless stack check logic triggers here automatically
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
            // Card Stack Container Area
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
                        // Display the text representation of our current active business node
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.restaurant, size: 80, color: Colors.redAccent),
                            const SizedBox(height: 20),
                            Text(
                              dummyRestaurants[currentCardIndex],
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            const Text("⭐⭐⭐⭐ (4.5)", style: TextStyle(fontSize: 18, color: Colors.orange)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Interaction Action Bar Actions (Previous vs Next triggers)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _handlePreviousCard,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Previous"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _handleNextCard,
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