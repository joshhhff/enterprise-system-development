import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
	final int currentIndex;
	final ValueChanged<int>? onTap;

	/// Optional customizations
	final double iconSize;
	final double topPadding;
	final Color? borderColor;

	const BottomNavBar({
		super.key,
		this.currentIndex = 0,
		this.onTap,
		this.iconSize = 30.0,
		this.topPadding = 8.0,
		this.borderColor,
	});

	@override
	Widget build(BuildContext context) {
		final Color selectedColor = Colors.black;
		final Color unselectedColor = Colors.grey;

		return Container(
			decoration: BoxDecoration(
				color: Colors.white,
				border: Border(
					top: BorderSide(
						color: borderColor ?? Colors.grey.shade400,
						width: 1.0, // slight top border
					),
				),
			),
			child: BottomNavigationBar(
				backgroundColor: Colors.transparent,
				elevation: 0,
				currentIndex: currentIndex,
				onTap: onTap,
				showSelectedLabels: false,
				showUnselectedLabels: false,
				selectedItemColor: selectedColor,
				unselectedItemColor: unselectedColor,
				items: [
					BottomNavigationBarItem(
						icon: Padding(
							padding: EdgeInsets.only(top: topPadding),
							child: Icon(Icons.home_outlined, size: iconSize),
						),
						activeIcon: Padding(
							padding: EdgeInsets.only(top: topPadding),
							child: Icon(Icons.home, size: iconSize),
						),
						label: '',
					),
					BottomNavigationBarItem(
						icon: Padding(
							padding: EdgeInsets.only(top: topPadding),
							child: Icon(Icons.search, size: iconSize),
						),
						activeIcon: Padding(
							padding: EdgeInsets.only(top: topPadding),
							child: Icon(Icons.search, size: iconSize), // same icon, color will indicate active state
						),
						label: '',
					),
					BottomNavigationBarItem(
						icon: Padding(
							padding: EdgeInsets.only(top: topPadding),
							child: Icon(Icons.settings_outlined, size: iconSize),
						),
						activeIcon: Padding(
							padding: EdgeInsets.only(top: topPadding),
							child: Icon(Icons.settings, size: iconSize),
						),
						label: '',
					),
				],
			),
		);
	}
}