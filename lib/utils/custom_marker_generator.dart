import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

Future<BitmapDescriptor> createCustomMarker(String imageUrl) async {
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

  final ui.Image markerImage =
      await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
  final ByteData? byteData =
      await markerImage.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
}
