import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_autocomplete/google_places_autocomplete.dart';
import 'package:mapman/utils/constants/strings.dart';
import 'package:mapman/utils/handlers/api_response.dart';

class PlaceController extends ChangeNotifier {
  /// The autocomplete service instance.
  late GooglePlacesAutocomplete _placesService;

  /// List to store predictions for display.
  List<Prediction> _predictions = [];

  List<Prediction> get predictions => _predictions;

  /// Tracks the loading state of predictions
  bool _isPredictionLoading = false;

  bool get isPredictionLoading => _isPredictionLoading;

  /// Details of the selected place.
  PlaceDetails? _placeDetails;

  PlaceDetails? get placeDetails => _placeDetails;

  /// Tracks the loading state of place details
  bool _isDetailsLoading = false;

  bool get isDetailsLoading => _isDetailsLoading;

  Prediction? _selectedPrediction;

  Prediction? get selectedPrediction => _selectedPrediction;

  set setSelectedPrediction(Prediction? value) {
    _selectedPrediction = value;
    notifyListeners();
  }

  Prediction? _confirmedPrediction;

  Prediction? get confirmedPrediction => _confirmedPrediction;

  set setConfirmedPrediction(Prediction? value) {
    _confirmedPrediction = value;
    notifyListeners();
  }

  PlaceController() {
    _placesService = GooglePlacesAutocomplete(
      apiKey: "AIzaSyDqlmtxOs2gBzD0_BpRcyTOtE3uk8jH1Ms",
      debounceTime: 300,
      countries: ['in'],
      language: 'en',
      predictionsListner: (predictions) {
        _predictions = predictions;
        notifyListeners();
      },
      loadingListner: (isLoading) {
        _isPredictionLoading = isLoading;
        notifyListeners();
      },
    );

    _placesService.initialize();
  }

  Future<void> getPredictions(String query) async {
    if (query.isEmpty) {
      clearPredictions();
      return;
    }
    _isPredictionLoading = true;
    notifyListeners();

    try {
      _placesService.getPredictions(query);
    } catch (e) {
      debugPrint("Prediction error: $e");
    } finally {
      _isPredictionLoading = false;
      notifyListeners();
    }
  }

  void clearPredictions() {
    _predictions.clear();
    notifyListeners();
  }

  void resetAddress() {
    _placeDetails = null;
    notifyListeners();
  }

  Future<void> fetchPlaceDetails(String placeId) async {
    _isDetailsLoading = true;
    notifyListeners();

    try {
      final details = await _placesService.getPredictionDetail(placeId);
      _placeDetails = details;
      notifyListeners();
    } catch (_) {
    } finally {
      _isDetailsLoading = false;
      notifyListeners();
    }
  }

  ApiResponse<LatLng> _currentLocationLatLng = ApiResponse.initial('');

  ApiResponse<LatLng> get currentLocationLatLng => _currentLocationLatLng;

  /// Function to fetch current location (LatLng)
  Future<ApiResponse<LatLng>> getCurrentLocation() async {
    _currentLocationLatLng = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _currentLocationLatLng = ApiResponse.error(
          "Location permission denied.",
        );
        notifyListeners();
      }
      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        _currentLocationLatLng = ApiResponse.error(
          "Location permission denied forever.",
        );
        notifyListeners();
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(position.latitude, position.longitude);
      _currentLocationLatLng = ApiResponse.completed(latLng);
      notifyListeners();
    } catch (e) {
      _currentLocationLatLng = ApiResponse.error("Error: ${e.toString()}");
      notifyListeners();
    }
    return _currentLocationLatLng;
  }
}
