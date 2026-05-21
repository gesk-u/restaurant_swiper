import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secrets.dart';

class Restaurant {
  final String name;
  final String imageUrl;
  final double rating;

  Restaurant({
    required this.name,
    required this.imageUrl,
    required this.rating,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['name'] ?? 'Unknown Restaurant',
      imageUrl: json['image_url'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }
}

class YelpService {
  static const String _baseUrl = 'https://api.yelp.com/v3/businesses/search';
  static const String _apiKey = yelpApiKey;

  Future<List<Restaurant>> getRestaurants(double latitude, double longitude, {int offset = 0}) async {
    final url = Uri.parse('$_baseUrl?latitude=$latitude&longitude=$longitude&limit=20&offset=$offset');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_apiKey'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List businesses = data['businesses'] ?? [];
        return businesses.map((json) => Restaurant.fromJson(json)).toList();
      } else {
        print('Yelp API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Network Error: $e');
      return [];
    }
  }
}