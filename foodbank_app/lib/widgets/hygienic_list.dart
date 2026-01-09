import 'package:flutter/material.dart';
import 'package:foodbank_app/widgets/food_bank_selectable.dart';

class HygienicList extends StatelessWidget {
  final List<FoodBankSelectable> foodBanks;

  const HygienicList({super.key, required this.foodBanks});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top-Rated Food Banks for Hygiene',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),

              // list content
              ListView.separated(
                shrinkWrap: true, // important when inside a Column
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 8),
                itemCount: foodBanks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, i) {
                  final foodBank = foodBanks[i];
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: SizedBox(
                      width: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(Icons.star_border),
                          SizedBox(width: 6),
                          Text(foodBank.hygieneRating.toString()),
                        ],
                      ),
                    ),
                    title: Text(foodBank.name),
                    subtitle: Text(foodBank.location),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
