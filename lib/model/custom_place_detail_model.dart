class CustomPlaceDetails {
  final String? name;
  final String? nationalPhoneNumber;
  final String? internationalPhoneNumber;
  final String? formattedPhoneNumber;
  final String? formattedAddress;
  final String? streetAddress;
  final String? streetNumber;
  final String? city;
  final String? state;
  final String? region;
  final String? zipCode;
  final String? country;
  final CustomLocation? location;
  final String? googleMapsUri;
  final String? websiteUri;
  final String? website;
  final double? rating;
  final int? userRatingsTotal;
  final CustomGeometry? geometry;

  CustomPlaceDetails({
    this.name,
    this.nationalPhoneNumber,
    this.internationalPhoneNumber,
    this.formattedPhoneNumber,
    this.formattedAddress,
    this.streetAddress,
    this.streetNumber,
    this.city,
    this.state,
    this.region,
    this.zipCode,
    this.country,
    this.location,
    this.googleMapsUri,
    this.websiteUri,
    this.website,
    this.rating,
    this.userRatingsTotal,
    this.geometry,
  });

  factory CustomPlaceDetails.fromMap(Map<dynamic, dynamic> map) {
    String? extractAddressComponent(List<dynamic> components, String type) {
      for (var component in components) {
        if ((component['types'] as List).contains(type)) {
          return component['longText'];
        }
      }
      return null;
    }

    return CustomPlaceDetails(
      name: map['name'],
      nationalPhoneNumber: map['nationalPhoneNumber'],
      internationalPhoneNumber: map['internationalPhoneNumber'],
      formattedPhoneNumber: map['formattedPhoneNumber'],
      formattedAddress: map['formattedAddress'],
      streetAddress: extractAddressComponent(map['addressComponents'], 'route'),
      streetNumber: extractAddressComponent(
        map['addressComponents'],
        'street_number',
      ),
      city: extractAddressComponent(map['addressComponents'], 'locality'),
      state: extractAddressComponent(
        map['addressComponents'],
        'administrative_area_level_1',
      ),
      region: extractAddressComponent(
        map['addressComponents'],
        'administrative_area_level_2',
      ),
      zipCode: extractAddressComponent(map['addressComponents'], 'postal_code'),
      country: extractAddressComponent(map['addressComponents'], 'country'),
      location: map['location'] != null
          ? CustomLocation.fromMap(map['location'] as Map<String, dynamic>)
          : null,
      googleMapsUri: map['googleMapsUri'] != null
          ? map['googleMapsUri'] as String
          : null,
      websiteUri: map['websiteUri'] != null
          ? map['websiteUri'] as String
          : null,
      website: map['website'] as String?,
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : null,
      userRatingsTotal: map['userRatingsTotal'] as int?,
      geometry: map['geometry'] != null
          ? CustomGeometry.fromJson(map['geometry'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CustomLocation {
  final double lat;
  final double lng;

  CustomLocation({required this.lat, required this.lng});

  factory CustomLocation.fromMap(Map<String, dynamic> json) {
    return CustomLocation(
      lat: json['latitude'] ?? json['lat'] ?? 0.0,
      lng: json['longitude'] ?? json['lng'] ?? 0.0,
    );
  }
}

class CustomGeometry {
  final CustomLocation? location;

  CustomGeometry({this.location});

  factory CustomGeometry.fromJson(Map<String, dynamic> json) {
    return CustomGeometry(
      location: json['location'] != null
          ? CustomLocation.fromMap(json['location'] as Map<String, dynamic>)
          : null,
    );
  }
}
