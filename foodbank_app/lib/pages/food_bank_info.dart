import 'package:flutter/material.dart';
import 'package:foodbank_app/widgets/bottom_nav_bar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class FoodBankDetailsPage extends StatefulWidget {
	final String title;
	final double rating;
	final int numberOfRatings;
	final String description;

	const FoodBankDetailsPage(
			{super.key,
			required this.title,
			required this.rating,
			required this.numberOfRatings,
			required this.description});

	@override
	State<FoodBankDetailsPage> createState() => _FoodBankDetailsPageState();
}

class _FoodBankDetailsPageState extends State<FoodBankDetailsPage> {
	LatLng? _currentLocation;
	final MapController _mapController = MapController();
	bool _isMapOpen = false;
	bool _isBookmarked = false; // Track bookmark state

	// New: track overall loading state and header image url
	bool _isLoading = true;
	final String _headerImageUrl =
			'https://images.unsplash.com/photo-1600585154340-be6161a56a0c';

	@override
	void initState() {
		super.initState();
		_loadResources();
	}

	// Load resources (header image + location). Keep UI blocked until done.
	Future<void> _loadResources() async {
		try {
			await precacheImage(NetworkImage(_headerImageUrl), context);
		} catch (_) {
			// ignore image precache errors and continue to location retrieval
		}

		// Always attempt to get location (permission UI handled inside)
		await _getCurrentLocation();

		if (!mounted) return;
		setState(() {
			_isLoading = false;
		});
	}

	Future<void> _getCurrentLocation() async {
		bool serviceEnabled;
		LocationPermission permission;

		serviceEnabled = await Geolocator.isLocationServiceEnabled();
		if (!serviceEnabled) {
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(content: Text('Please enable location services')),
				);
			}
			return;
		}

		permission = await Geolocator.checkPermission();
		if (permission == LocationPermission.denied) {
			permission = await Geolocator.requestPermission();
			if (permission == LocationPermission.denied) {
				if (mounted) {
					ScaffoldMessenger.of(context).showSnackBar(
						const SnackBar(content: Text('Location permission denied')),
					);
				}
				return;
			}
		}

		if (permission == LocationPermission.deniedForever) {
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(
						content: Text('Location permission permanently denied'),
					),
				);
			}
			return;
		}

		final position = await Geolocator.getCurrentPosition(
			locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
		);

		if (!mounted) return;
		setState(() {
			_currentLocation = LatLng(position.latitude, position.longitude);
		});

		// move map if controller is ready
		try {
			_mapController.move(_currentLocation!, 15);
		} catch (_) {
			// map controller might not be attached yet; ignore
		}
	}

	void _togglePanel() {
		setState(() {
			_isMapOpen = !_isMapOpen;
		});
	}

	void _toggleBookmark() {
		setState(() {
			_isBookmarked = !_isBookmarked;
		});
		
		// Show feedback snackbar
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text(_isBookmarked ? 'Added to bookmarks' : 'Removed from bookmarks'),
				duration: const Duration(seconds: 1),
			),
		);
	}

	void _showShareBottomSheet() {
		showModalBottomSheet(
			context: context,
			backgroundColor: Colors.white,
			shape: const RoundedRectangleBorder(
				borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
			),
			builder: (context) {
				return Container(
					padding: const EdgeInsets.symmetric(vertical: 20),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							// Handle bar
							Container(
								width: 40,
								height: 4,
								decoration: BoxDecoration(
									color: Colors.grey.shade300,
									borderRadius: BorderRadius.circular(2),
								),
							),
							const SizedBox(height: 20),
							
							// Title
							const Text(
								'Share Food Bank',
								style: TextStyle(
									fontSize: 18,
									fontWeight: FontWeight.bold,
								),
							),
							const SizedBox(height: 20),
							
							// Share options
							ListTile(
								leading: const Icon(Icons.message, color: Colors.blue),
								title: const Text('Message'),
								onTap: () {
									Navigator.pop(context);
									ScaffoldMessenger.of(context).showSnackBar(
										const SnackBar(content: Text('Opening messages...')),
									);
								},
							),
							ListTile(
								leading: const Icon(Icons.email, color: Colors.red),
								title: const Text('Email'),
								onTap: () {
									Navigator.pop(context);
									ScaffoldMessenger.of(context).showSnackBar(
										const SnackBar(content: Text('Opening email...')),
									);
								},
							),
							ListTile(
								leading: const Icon(Icons.copy, color: Colors.grey),
								title: const Text('Copy Link'),
								onTap: () {
									Navigator.pop(context);
									ScaffoldMessenger.of(context).showSnackBar(
										const SnackBar(content: Text('Link copied to clipboard')),
									);
								},
							),
							ListTile(
								leading: const Icon(Icons.more_horiz, color: Colors.grey),
								title: const Text('More'),
								onTap: () {
									Navigator.pop(context);
									ScaffoldMessenger.of(context).showSnackBar(
										const SnackBar(content: Text('Opening more options...')),
									);
								},
							),
							const SizedBox(height: 10),
						],
					),
				);
			},
		);
	}

	void _showReviewDialog() {
		int selectedRating = 0;
		final TextEditingController reviewController = TextEditingController();

		showDialog(
			context: context,
			builder: (context) {
				return StatefulBuilder(
					builder: (context, setState) {
						return AlertDialog(
							backgroundColor: Colors.white,
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.circular(20),
							),
							title: const Text(
								'Submit Review',
								style: TextStyle(fontWeight: FontWeight.bold),
							),
							content: SingleChildScrollView(
								child: Column(
									mainAxisSize: MainAxisSize.min,
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										// Rating stars
										const Text(
											'Rating',
											style: TextStyle(
												fontSize: 16,
												fontWeight: FontWeight.w600,
											),
										),
										const SizedBox(height: 12),
										Row(
											mainAxisAlignment: MainAxisAlignment.center,
											children: List.generate(5, (index) {
												return IconButton(
													padding: EdgeInsets.zero,
													constraints: const BoxConstraints(),
													icon: Icon(
														index < selectedRating
																? Icons.star
																: Icons.star_border,
														color: Colors.amber,
														size: 40,
													),
													onPressed: () {
														setState(() {
															selectedRating = index + 1;
														});
													},
												);
											}),
										),
										const SizedBox(height: 20),
										
										// Review description
										const Text(
											'Review',
											style: TextStyle(
												fontSize: 16,
												fontWeight: FontWeight.w600,
											),
										),
										const SizedBox(height: 12),
										TextField(
											controller: reviewController,
											maxLines: 5,
											decoration: InputDecoration(
												hintText: 'Share your experience...',
												border: OutlineInputBorder(
													borderRadius: BorderRadius.circular(12),
													borderSide: BorderSide(color: Colors.grey.shade300),
												),
												focusedBorder: OutlineInputBorder(
													borderRadius: BorderRadius.circular(12),
													borderSide: const BorderSide(color: Colors.black),
												),
											),
										),
									],
								),
							),
							actions: [
								TextButton(
									onPressed: () => Navigator.pop(context),
									child: const Text(
										'Cancel',
										style: TextStyle(color: Colors.grey),
									),
								),
								ElevatedButton(
									onPressed: () {
										if (selectedRating == 0) {
											ScaffoldMessenger.of(context).showSnackBar(
												const SnackBar(content: Text('Please select a rating')),
											);
											return;
										}
										
										Navigator.pop(context);
										ScaffoldMessenger.of(context).showSnackBar(
											SnackBar(
												content: Text(
													'Review submitted: $selectedRating stars - ${reviewController.text}',
												),
											),
										);
									},
									style: ElevatedButton.styleFrom(
										backgroundColor: Colors.black,
										foregroundColor: Colors.white,
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(12),
										),
									),
									child: const Text('Submit'),
								),
							],
						);
					},
				);
			},
		);
	}

	@override
	Widget build(BuildContext context) {
		final screenHeight = MediaQuery.of(context).size.height;
		final double panelOpenHeight = (screenHeight * 0.35).clamp(200.0, 400.0);
		const double panelClosedHeight = 72.0;

		return Scaffold(
			backgroundColor: Colors.white,
			appBar: AppBar(
				backgroundColor: Colors.white,
				title: const Text('Food Bank Details'),
				leading: IconButton(
					icon: const Icon(Icons.arrow_back),
					onPressed: () => Navigator.pop(context),
				),
			),
			body: Stack(
				children: [
					// Main content
					SingleChildScrollView(
						padding: const EdgeInsets.only(bottom: 200),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								// Header Image
								ClipRRect(
									borderRadius: const BorderRadius.only(
										bottomLeft: Radius.circular(16),
										bottomRight: Radius.circular(16),
									),
									child: Image.network(
										_headerImageUrl,
										height: 200,
										width: double.infinity,
										fit: BoxFit.cover,
									),
								),

								// Title and Info
								Padding(
									padding:
											const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(
												widget.title,
												style: const TextStyle(
													fontSize: 22,
													fontWeight: FontWeight.bold,
												),
											),
											const SizedBox(height: 8),
											Row(
												children: [
													const Icon(Icons.star, color: Colors.amber, size: 20),
													const SizedBox(width: 4),
													Text(
														'${widget.rating} (${widget.numberOfRatings} reviews)',
														style: const TextStyle(color: Colors.grey),
													),
													const SizedBox(width: 16),
													const Icon(Icons.location_on,
															size: 20, color: Colors.grey),
													const SizedBox(width: 4),
													const Text(
														'1.2 miles',
														style: TextStyle(color: Colors.grey),
													),
												],
											),
											const SizedBox(height: 8),
											const Text(
												'Location Address',
												style: TextStyle(color: Colors.grey),
											),
										],
									),
								),

								// Action Buttons
								Padding(
									padding: const EdgeInsets.symmetric(horizontal: 16.0),
									child: Row(
										children: [
											IconButton(
												onPressed: _showShareBottomSheet,
												icon: const Icon(Icons.share_outlined),
											),
											IconButton(
												onPressed: _toggleBookmark,
												icon: Icon(
													_isBookmarked ? Icons.bookmark : Icons.bookmark_border,
													color: _isBookmarked ? Colors.amber : null,
												),
											),
											const Spacer(),
											ElevatedButton.icon(
												onPressed: _showReviewDialog,
												icon: const Icon(Icons.star),
												label: const Text('Submit Review'),
												style: ElevatedButton.styleFrom(
													backgroundColor: Colors.black,
													foregroundColor: Colors.white,
													padding: const EdgeInsets.symmetric(
															horizontal: 20, vertical: 12),
													shape: RoundedRectangleBorder(
														borderRadius: BorderRadius.circular(12),
													),
												),
											),
										],
									),
								),
								const SizedBox(height: 16),

								// Description
								Padding(
									padding: const EdgeInsets.symmetric(horizontal: 16.0),
									child: Text(
										widget.description,
										style: const TextStyle(fontSize: 16, height: 1.5),
									),
								),
								const SizedBox(height: 16),
							],
						),
					),

					// Sliding Map Panel - positioned from bottom using Align
					Align(
						alignment: Alignment.bottomCenter,
						child: Padding(
							padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
							child: AnimatedContainer(
								duration: const Duration(milliseconds: 300),
								curve: Curves.easeInOut,
								height: _isMapOpen ? panelOpenHeight : panelClosedHeight,
								child: GestureDetector(
									onVerticalDragUpdate: (details) {
										if (details.delta.dy < -8 && !_isMapOpen) {
											setState(() => _isMapOpen = true);
										} else if (details.delta.dy > 8 && _isMapOpen) {
											setState(() => _isMapOpen = false);
										}
									},
									child: Material(
										elevation: 10,
										borderRadius: BorderRadius.circular(16),
										clipBehavior: Clip.hardEdge,
										color: Colors.grey.shade100,
										child: Column(
											children: [
												// Clean handle header with arrow
												InkWell(
													onTap: _togglePanel,
													child: Container(
														height: panelClosedHeight,
														color: Colors.grey.shade100,
														child: Column(
															mainAxisAlignment: MainAxisAlignment.center,
															children: [
																// Grab handle
																Container(
																	width: 40,
																	height: 5,
																	decoration: BoxDecoration(
																		color: Colors.grey.shade300,
																		borderRadius: BorderRadius.circular(12),
																	),
																),
															],
														),
													),
												),

												// Map area
												Expanded(
													child: _currentLocation == null
															? const Center(child: CircularProgressIndicator())
															: FlutterMap(
																	mapController: _mapController,
																	options: MapOptions(
																		initialCenter: _currentLocation!,
																		initialZoom: 15,
																		interactionOptions: const InteractionOptions(
																				flags: InteractiveFlag.all),
																	),
																	children: [
																		TileLayer(
																			urlTemplate:
																					'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
																			subdomains: const ['a', 'b', 'c'],
																			userAgentPackageName:
																					'com.example.foodbank_app',
																		),
																		MarkerLayer(
																			markers: [
																				Marker(
																					width: 48,
																					height: 48,
																					point: _currentLocation!,
																					child: const Icon(
																						Icons.my_location,
																						color: Colors.blue,
																						size: 36,
																					),
																				),
																			],
																		),
																	],
																),
												),
											],
										),
									),
								),
							),
						),
					),

					// Global loading overlay that appears until image + location attempts finish
					if (_isLoading)
						Positioned.fill(
							child: Container(
								color: Colors.white,
								child: const Center(child: CircularProgressIndicator()),
							),
						),
				],
			),
			bottomNavigationBar: const BottomNavBar(
				currentIndex: 1,
			),
		);
	}
}