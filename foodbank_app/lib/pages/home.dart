import 'package:flutter/material.dart';
import 'package:foodbank_app/pages/food_bank_page.dart';
import 'package:foodbank_app/widgets/food_bank_selectable.dart';
import 'package:foodbank_app/widgets/hygienic_list.dart';
import 'package:foodbank_app/pages/food_bank_info.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

SharedPreferences prefs = SharedPreferences.getInstance() as SharedPreferences;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

Future<Position> _getCurrentLocation() async {
  Position? position;
  position = await Geolocator.getLastKnownPosition();
  prefs = await SharedPreferences.getInstance();

  await for (final pos in Geolocator.getPositionStream(
    locationSettings: LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    ),
  )) {
    if (pos.accuracy < 20) {
      position = pos;
      break;
    }
  }
  return position!;
}

Future<List<Map<String, dynamic>>> fetchData() async {
  double latitude;
  double longitude;

  // defaults to buckinghamshire university
  if (kIsWeb) {
    latitude = 51.6278909;
    longitude = -0.7558618;
  } else {
    final position = await _getCurrentLocation();

    latitude = position.latitude;
    longitude = position.longitude;

    if (latitude == 37.4219983 && longitude == -122.084) {
      latitude = 51.6278909;
      longitude = -0.7558618;
    }
  }

  final response = await http.get(
    Uri.parse(
      'https://www.givefood.org.uk/api/2/foodbanks/search/?lat_lng=$latitude,$longitude',
    ),
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}

Future<List<FoodBankSelectable>> getFoodBanks() async {
  final List<FoodBankSelectable> foodBanks = [];
  final data = await fetchData();

  const images = [
    'lib/assets/img/meal_deal.png',
    'lib/assets/img/parsnips.jpg',
    'lib/assets/img/soup.jpg',
  ];

  for (var item in data) {
    final urls = item['urls'] as Map<String, dynamic>?;

    foodBanks.add(
      FoodBankSelectable(
        prefs: null,
        id: item['id'].toString(),
        img: images[Random().nextInt(images.length)],
        location: item['address'] ?? 'Unknown Location',
        distance: item['distance_mi'].toString(),
        name: item['name'] ?? 'Unnamed Food Bank',
        description: [
          item['phone'],
          item['email'],
          item['website'],
          urls?['homepage'],
        ].where((e) => e != null && e.toString().isNotEmpty).join('\n'),
        hygieneRating: double.parse(
          (Random().nextDouble() * 5).toStringAsFixed(1),
        ),
        numberOfHygieneRatings: Random().nextInt(1000),
      ),
    );
  }

  return foodBanks;
}

class _HomePageState extends State<HomePage> {
  List<FoodBankSelectable> _foodBanks = [];
  List<FoodBankSelectable> _foodBanksDistance = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFoodbanks();
  }

  Future<void> _loadFoodbanks() async {
    try {
      final data = await getFoodBanks();
      data.sort((a, b) => b.hygieneRating.compareTo(a.hygieneRating));
      setState(() {
        _foodBanks = data;
        _foodBanksDistance = List.from(data);
        _foodBanksDistance.sort(
          (a, b) =>
              double.parse(a.distance).compareTo(double.parse(b.distance)),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    final foodBanks = _foodBanks;
    foodBanks.sort((a, b) => b.hygieneRating.compareTo(a.hygieneRating));

    return FoodBankPage(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SearchBar(
                  hintText: "Search",
                  leading: const Icon(Icons.search),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset("lib/assets/img/pears.png"),
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Food Banks near me",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  height: 300,
                  child: CarouselView(
                    itemExtent: 200,
                    onTap: (int index) {
                      final fb = _foodBanksDistance[index];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => FoodBankDetailsPage(
                                prefs: prefs,
                                title: fb.name,
                                location: fb.location,
                                distance: fb.distance,
                                img: fb.img,
                                description: fb.description,
                                rating: fb.hygieneRating,
                                numberOfRatings: fb.numberOfHygieneRatings,
                              ),
                        ),
                      );
                    },
                    children: _foodBanksDistance,
                  ),
                ),
              ),
              HygienicList(foodBanks: foodBanks),
            ],
          ),
        ),
      ),
    );
  }
}
