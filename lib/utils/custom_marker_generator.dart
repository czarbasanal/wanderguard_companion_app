import 'dart:async';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;

Future<BitmapDescriptor> createCustomMarker(String imageUrl) async {
  final Uint8List imageData = await _loadImage(imageUrl);

  final ui.Codec codec = await ui.instantiateImageCodec(imageData,
      targetHeight: 100, targetWidth: 100);
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  final ui.Image image = frameInfo.image;

  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint paint = Paint()..isAntiAlias = true;
  const double size = 100.0;

  canvas.drawCircle(
      const Offset(size / 2, size / 2), size / 2, paint..color = Colors.white);
  canvas.clipPath(Path()..addOval(const Rect.fromLTWH(0, 0, size, size)));
  canvas.drawImage(image, const Offset(0, 0), paint);

  final ui.Image markerImage =
      await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
  final ByteData? byteData =
      await markerImage.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
}

Future<Uint8List> _loadImage(String imageUrl) async {
  final Completer<Uint8List> completer = Completer();
  final ImageStream stream =
      CachedNetworkImageProvider(imageUrl).resolve(const ImageConfiguration());
  final listener = ImageStreamListener((ImageInfo info, bool _) async {
    final ByteData? byteData =
        await info.image.toByteData(format: ui.ImageByteFormat.png);
    completer.complete(byteData!.buffer.asUint8List());
  });

  stream.addListener(listener);
  return completer.future;
}
