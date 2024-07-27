import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:wanderguard_companion_app/utils/geopoint_converter.dart';
import 'package:wanderguard_companion_app/utils/size_config.dart';
import '../services/information_service.dart';
import '../widgets/dialogs/waiting_dialog.dart';
import '../controllers/companion_data_controller.dart';
import '../services/firestore_service.dart';
import '../models/companion.model.dart';
import '../models/patient.model.dart';

class HomeScreen extends StatefulWidget {
  static const route = '/home';
  static const name = 'Home';

  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 2,
  );
  bool _loadingLocation = true;
  late GoogleMapController _controller;
  final Set<Marker> _markers = {};
  bool _loadingMarker = false;
  final DraggableScrollableController _scrollableController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _determinePosition().then((position) {
      setState(() {
        _initialPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        );
        _loadingLocation = false;
      });
      _updateCurrentLocation(position);
    }).catchError((e) {
      setState(() {
        _loadingLocation = false;
      });
      Info.showSnackbarMessage(context, message: e.toString(), label: "Error");
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _updateCurrentLocation(Position position) async {
    try {
      Companion? companion =
          CompanionDataController.instance.companionModelNotifier.value;
      if (companion != null) {
        companion.updateCurrentLocation(
            GeoPoint(position.latitude, position.longitude));
        await FirestoreService.instance.addOrUpdateCompanion(companion);
      }
    } catch (e) {
      Info.showSnackbarMessage(context,
          message: "Failed to update location: $e", label: "Error");
    }
  }

  Future<BitmapDescriptor> _createCustomMarker(String imageUrl) async {
    final http.Response response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to load image');
    }

    final Uint8List imageData = response.bodyBytes;
    final ui.Codec codec = await ui.instantiateImageCodec(imageData,
        targetHeight: 100, targetWidth: 100);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..isAntiAlias = true;
    final double size = 100.0;

    canvas.drawCircle(
        Offset(size / 2, size / 2), size / 2, paint..color = Colors.white);
    canvas.clipPath(Path()..addOval(Rect.fromLTWH(0, 0, size, size)));
    canvas.drawImage(image, Offset(0, 0), paint);

    final ui.Image markerImage = await pictureRecorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final ByteData? byteData =
        await markerImage.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  void _addMarker(LatLng position, String markerId, String imageUrl) {
    _createCustomMarker(imageUrl).then((markerIcon) {
      final marker = Marker(
        markerId: MarkerId(markerId),
        position: position,
        icon: markerIcon,
      );

      setState(() {
        _markers.add(marker);
        _controller.animateCamera(CameraUpdate.newLatLng(position));
        _loadingMarker = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.tertiaryColor,
      body: Stack(
        children: [
          _loadingLocation
              ? WaitingDialog(
                  prompt: "Loading...",
                  color: CustomColors.primaryColor,
                )
              : GoogleMap(
                  initialCameraPosition: _initialPosition,
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                  },
                ),
          DraggableScrollableSheet(
            controller: _scrollableController,
            initialChildSize: 0.06,
            minChildSize: 0.06,
            maxChildSize: 0.7,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: CustomColors.secondaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 4,
                      blurRadius: 4,
                      offset: const Offset(0, 3),
                    )
                  ],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: SizeConfig.screenWidth * 0.2,
                          height: 3,
                          decoration: BoxDecoration(
                              color: CustomColors.primaryColor,
                              borderRadius: BorderRadius.circular(50)),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Patient List",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                                onPressed: null,
                                child: Text('Locate All',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: CustomColors.primaryColor)))
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildPatientList(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (_loadingMarker)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: Center(
                child: WaitingDialog(
                  prompt: "Locating Patient...",
                  color: CustomColors.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPatientList() {
    return StreamBuilder<List<Patient>>(
      stream: FirestoreService.instance.getPatientsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: WaitingDialog(
            color: CustomColors.primaryColor,
          ));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final patients = snapshot.data;

        if (patients == null || patients.isEmpty) {
          return const Center(child: Text('No registered patients yet.'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final patient = patients[index];
            return FutureBuilder<String>(
              future:
                  GeoPointConverter.geoPointToAddress(patient.lastLocTracked),
              builder: (context, lastLocSnapshot) {
                final location = lastLocSnapshot.data ?? 'Fetching location...';

                return Card(
                  color: CustomColors.tertiaryColor,
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            patient.photoUrl,
                            width: 85,
                            height: 85,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${patient.firstName} ${patient.lastName}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                patient.contactNo,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Last Location:',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              Text(location,
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MaterialButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    minWidth: SizeConfig.screenWidth * 0.1,
                                    height: SizeConfig.screenHeight * 0.048,
                                    color: CustomColors.primaryColor,
                                    onPressed: () {
                                      setState(() {
                                        _loadingMarker = true;
                                      });
                                      _scrollableController
                                          .animateTo(0.06,
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              curve: Curves.easeInOut)
                                          .then((_) {
                                        _addMarker(
                                          LatLng(
                                            patient.lastLocTracked.latitude,
                                            patient.lastLocTracked.longitude,
                                          ),
                                          patient.patientAcctId,
                                          patient.photoUrl,
                                        );
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          CupertinoIcons.placemark_fill,
                                          color: CustomColors.secondaryColor,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Locate',
                                          style: TextStyle(
                                              fontSize: 15,
                                              color:
                                                  CustomColors.secondaryColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          CustomColors.primaryColor,
                                      side: BorderSide(
                                          color: CustomColors
                                              .primaryColor), // Border color
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      minimumSize: Size(
                                          SizeConfig.screenWidth * 0.05,
                                          SizeConfig.screenHeight *
                                              0.048), // Text color
                                    ),
                                    onPressed: () {
                                      // Implement call patient here
                                    },
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          CupertinoIcons.phone_fill,
                                          size: 24,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Call',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
