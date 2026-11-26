import 'package:geolocator/geolocator.dart';

class DeviceLocation {
  const DeviceLocation(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

class LocationServiceException implements Exception {
  const LocationServiceException(this.message);
  final String message;
  @override
  String toString() => message;
}

class LocationService {
  static const hogwartsReference = DeviceLocation(
    55.4156,
    -1.7059,
  ); // Alnwick Castle reference.
  Future<DeviceLocation> currentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationServiceException(
        'Ative o serviço de localização do dispositivo.',
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationServiceException(
        'A permissão de localização foi negada.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        'Habilite a localização nas configurações do app.',
      );
    }
    final position = await Geolocator.getCurrentPosition();
    return DeviceLocation(position.latitude, position.longitude);
  }

  double distanceFromHogwartsKm(DeviceLocation location) =>
      Geolocator.distanceBetween(
        location.latitude,
        location.longitude,
        hogwartsReference.latitude,
        hogwartsReference.longitude,
      ) /
      1000;
}
