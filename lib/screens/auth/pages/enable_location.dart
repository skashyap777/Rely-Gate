import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:rudra/config/utils/app_functions.dart';
import 'package:rudra/config/utils/assets.dart';
import 'package:rudra/screens/auth/provider/auth_provide.dart';
import 'package:provider/provider.dart';

class EnableLocation extends StatefulWidget {
  const EnableLocation({super.key});

  @override
  State<EnableLocation> createState() => _EnableLocationState();
}

class _EnableLocationState extends State<EnableLocation> {
  final TextEditingController _pincodeController = TextEditingController();
  bool loading = false;
  Position? position;

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  Future<void> getCurrentLocation() async {
    setState(() {
      loading = true;
    });
    position = await AppFunctions.requestLocationPermission();
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, store, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child:
                  loading
                      ? Center(child: CircularProgressIndicator())
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(Assets.location, height: 150),
                          const SizedBox(height: 32),

                          const Text(
                            'Check Your Area',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          const Text(
                            "Let's confirm your location is within PWD Assam's jurisdiction",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 32),

                          OutlinedButton.icon(
                            onPressed: () async {
                              if (position != null) {
                                final res = await store.checkLocation(
                                  position!.latitude,
                                  position!.longitude,
                                );
                                if (res) {
                                  context.go("/login");
                                } else {
                                  AppFunctions.showCustomSnackBar(
                                    context,
                                    "${store.checkLocationData?.message}",
                                    backgroundColor: Colors.red,
                                  );
                                }
                              } else {
                                // Try to get location again
                                await getCurrentLocation();
                                if (position != null) {
                                  final res = await store.checkLocation(
                                    position!.latitude,
                                    position!.longitude,
                                  );
                                  if (res) {
                                    context.go("/login");
                                  } else {
                                    AppFunctions.showCustomSnackBar(
                                      context,
                                      "${store.checkLocationData?.message}",
                                      backgroundColor: Colors.red,
                                    );
                                  }
                                } else {
                                  // Show dialog with options instead of redirecting to settings
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text(
                                            'Location Permission Required',
                                          ),
                                          content: const Text(
                                            'This app needs location access to verify your area. You can either grant permission or skip this step.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                context.go("/login");
                                              },
                                              child: const Text('Skip'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                Navigator.pop(context);
                                                await getCurrentLocation();
                                              },
                                              child: const Text('Try Again'),
                                            ),
                                          ],
                                        ),
                                  );
                                }
                              }
                            },
                            icon:
                                store.loading
                                    ? null
                                    : const Icon(
                                      Icons.my_location,
                                      color: Colors.green,
                                    ),
                            label:
                                store.loading
                                    ? SizedBox(
                                      height: 10,
                                      width: 10,
                                      child: CircularProgressIndicator(
                                        color: Colors.green,
                                      ),
                                    )
                                    : const Text(
                                      'Use my current location',
                                      style: TextStyle(color: Colors.green),
                                    ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.green),
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
            ),
          ),
        );
      },
    );
  }
}
