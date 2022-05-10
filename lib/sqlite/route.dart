class Rout {
  int? id;
  double latitude;
  double longitude;
  int trackId;

  Rout({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.trackId
  });

  factory Rout.fromMap(Map<String, dynamic> json) => Rout(
      id: json["id"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      trackId: json["track_id"]
  );

  Map<String, dynamic> toMap() => {
    "latitude": latitude,
    "longitude": longitude,
    "track_id": trackId
  };
}
