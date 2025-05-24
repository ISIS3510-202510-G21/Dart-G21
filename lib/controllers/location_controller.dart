import 'package:dart_g21/data/database/app_database.dart';
import 'package:dart_g21/models/location.dart' as model;
import 'package:dart_g21/repositories/drift_repository.dart';
import 'package:dart_g21/repositories/location_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../repositories/localStorage_repository.dart';

class LocationController {
  final LocationRepository _locationRepository = LocationRepository();
  final LocalStorageRepository _localStorageRepository = LocalStorageRepository();
  final DriftRepository _driftRepository = DriftRepository(AppDatabase());


  Stream<List<model.Location>> getLocationsStream() {
    return _locationRepository.getLocationsStream();
  }

  Future<model.Location?> getLocationById(String locationId) async {
    return await _locationRepository.getLocationById(locationId);
  }

  Future<void> addLocation(model.Location location) async {
    await _locationRepository.addLocation(location);
  }

  Future<void> updateLocation(model.Location location) async {
    await _locationRepository.updateLocation(location);
  }

  Future<void> deleteLocation(String locationId) async {
    await _locationRepository.deleteLocation(locationId);
  }


  Stream<model.Location?> getLocationByAddress(String address) {
    return _locationRepository.getLocationByAddress(address);
  }

  Future<String?> addLocationAndReturnId(model.Location location) async {
    await addLocation(location);
    model.Location? createdLocation = await getLocationByAddressAndCity(location.address, location.city);
    return createdLocation?.id; 
  }

  Future<model.Location?> getLocationByAddressAndCity(String address, String city) async {
    Stream<List<model.Location>> locationsStream = getLocationsStream();
    List<model.Location> locations = await locationsStream.first;

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
      model.Location? location = await getLocationById(locationId);
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


  Future<List<model.Location>> getCachedLocations() async {
    return _localStorageRepository.getLocations();
  }

  Future<void> saveLocationsToCache(List<model.Location> locations) async {
    await _localStorageRepository.saveLocations(locations);
  }

  Future<model.Location?> getLocationByIdOffline(String locationId) async {
    try {
      List<model.Location> cachedLocations = await _localStorageRepository.getLocations();

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

  Future<void> saveLocationsToCacheDrift(List<model.Location> locations) async {
    await _driftRepository.saveLocationsDrift(locations);
  }

  Future<List<model.Location>> getCachedLocationsDrift() async {
    return await _driftRepository.getLocationsDrift();
  }

  Future<void> saveLocationDrift(model.Location location) async {
    await _driftRepository.saveLocationDrift(location);
  }

  Future<model.Location?> getLocationByIdOfflineDrift(String id) async {
    return await _driftRepository.getLocationByIdDrift(id);
  }



}