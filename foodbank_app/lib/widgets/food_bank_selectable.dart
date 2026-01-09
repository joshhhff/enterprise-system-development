import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodBankSelectable extends StatelessWidget {
  final String id;
  final String img;
  final String location;
  final String distance;
  final String name;
  final String description;
  final SharedPreferences? prefs;

  final double hygieneRating;
  final int numberOfHygieneRatings;

  const FoodBankSelectable({
    super.key,
    required this.prefs,
    required this.id,
    required this.img,
    required this.location,
    required this.distance,
    required this.name,
    required this.description,
    required this.hygieneRating,
    required this.numberOfHygieneRatings,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(img),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                location,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 12),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                name,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
