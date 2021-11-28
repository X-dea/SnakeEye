import 'dart:typed_data';

// Use bilinear interpolation to upscale image.
Float32List interpolate(
  Float32List src, {
  int width = 32,
  int height = 24,
  int targetWidth = 64,
  int targetHeight = 48,
}) {
  assert(src.length == width * height);
  final dst = Float32List(targetWidth * targetHeight);
  final scaleX = (targetWidth - 1) / (width - 1);
  final scaleY = (targetHeight - 1) / (height - 1);

  for (var y = 0; y < targetHeight; ++y) {
    for (var x = 0; x < targetWidth; ++x) {
      // Map into src coordinate.
      final sX = x / scaleX;
      final sY = y / scaleY;

      final sXCeil = sX.ceil();
      final sYCeil = sY.ceil();
      final sXFloor = sX.floor();
      final sYFloor = sY.floor();
      final sXDiff = sXCeil - sXFloor;
      final sYDiff = sYCeil - sYFloor;

      // ul(sXFloor, sYFloor)                                ur(sXCeil, sYFloor)
      //                                v(sX,sY)
      // bl(sXFloor, sYCeil)                                 br(sXCeil, sYCeil)
      final ul = src[sYFloor * width + sXFloor];
      final ur = src[sYFloor * width + sXCeil];
      final bl = src[sYCeil * width + sXFloor];
      final br = src[sYCeil * width + sXCeil];

      double v;
      if (sXDiff != 0 && sYDiff != 0) {
        v = ul * (sX - sXFloor) * (sY - sYFloor) +
            ur * (sXCeil - sX) * (sY - sYFloor) +
            bl * (sX - sXFloor) * (sYCeil - sY) +
            br * (sXCeil - sX) * (sYCeil - sY);
      } else if (sXDiff == 0 && sYDiff == 0) {
        v = ul;
      } else if (sXDiff == 0) {
        v = ul * (sY - sYFloor) + bl * (sYCeil - sY);
      } else {
        // sYDiff == 0
        v = ul * (sX - sXFloor) + ur * (sXCeil - sX);
      }

      dst[y * targetWidth + x] = v;
    }
  }
  return dst;
}
