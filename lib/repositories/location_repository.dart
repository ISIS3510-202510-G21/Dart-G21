import 'package:dart_g21/data/dao/location_dao.dart';
import 'package:dart_g21/models/location.dart';

class LocationRepository {

  final LocationDAO _locationDao = LocationDAO();

  // Exponer Observer desde DAO
  Stream<List<Location>> getLocationsStream() {
    return _locationDao.getLocationsStream();
  }

  Future<Location?> getLocationById(String locationId) async {
    return await _locationDao.getLocationById(locationId);
  }

  Future<void> addLocation(Location location) async {
    await _locationDao.insertLocation(location);
  }

  Future<void> updateLocation(Location location) async {
    await _locationDao.updateLocation(location);
  }

  Future<void> deleteLocation(String locationId) async {
    await _locationDao.deleteLocation(locationId);
  }

  Stream<Location?> getLocationByAddress(String address) {
  return _locationDao.getLocationByAddress(address); 
}

Future<List<String>> getLocationIdsByUniversity(bool isUniversity) async {
  return await _locationDao.getLocationIdsByUniversity(isUniversity);
}

}