import 'package:dart_g21/models/location.dart';
import 'package:dart_g21/repositories/location_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../repositories/localStorage_repository.dart';

class LocationController {
  final LocationRepository _locationRepository = LocationRepository();
  final LocalStorageRepository _localStorageRepository = LocalStorageRepository();

  Stream<List<Location>> getLocationsStream() {
    return _locationRepository.getLocationsStream();
  }

  Future<Location?> getLocationById(String locationId) async {
    return await _locationRepository.getLocationById(locationId);
  }

  Future<void> addLocation(Location location) async {
    await _locationRepository.addLocation(location);
  }

  Future<void> updateLocation(Location location) async {
    await _locationRepository.updateLocation(location);
  }

  Future<void> deleteLocation(String locationId) async {
    await _locationRepository.deleteLocation(locationId);
  }

  Stream<Location?> getLocationByAddress(String address) {
    return _locationRepository.getLocationByAddress(address);
  }

  Future<String?> addLocationAndReturnId(Location location) async {
    await addLocation(location);
    Location? createdLocation = await getLocationByAddressAndCity(location.address, location.city);
    return createdLocation?.id; 
  }

  Future<Location?> getLocationByAddressAndCity(String address, String city) async {
    Stream<List<Location>> locationsStream = getLocationsStream();
    List<Location> locations = await locationsStream.first;
    try {
      return locations.firstWhere((loc) => loc.address == address && loc.city == city);
    } catch (e) {
      print("No se encontró la ubicación en Firestore: $e");
      return null;
    }
  }
  /// Obtener coordenadas a partir de una dirección
  Future<LatLng?> getCoordinatesFromLocationId(String locationId) async {
    try {
      Location? location = await getLocationById(locationId);
      if (location == null || location.address.isEmpty) {
        print("No se encontró la ubicación para location_id $locationId");
        return null;
      }

      List<geo.Location> locations = await geo.locationFromAddress(location.address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (error) {
      print("Error obteniendo coordenadas para location_id $locationId: $error");
    }
    return null;
  }

  Future<List<String>> getLocationIdsByUniversity(bool isUniversity) async {
    return await _locationRepository.getLocationIdsByUniversity(isUniversity);
  }

  Future<List<Location>> getCachedLocations() async {
    return _localStorageRepository.getLocations();
  }

  Future<void> saveLocationsToCache(List<Location> locations) async {
    await _localStorageRepository.saveLocations(locations);
  }

  Future<Location?> getLocationByIdOffline(String locationId) async {
    try {
      List<Location> cachedLocations = await _localStorageRepository.getLocations();
      for (final location in cachedLocations) {
        if (location.id == locationId) {
          return location;
        }
      }
      return null; 
    } catch (e) {
      print('Error obteniendo ubicación offline: $e');
      return null;
}}
}