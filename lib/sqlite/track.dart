class Track {
  int? id;
  int date;
  int distance;
  double averageSpeed;
  int time;
  int userId;

  Track({
    this.id,
    required this.date,
    required this.distance,
    required this.averageSpeed,
    required this.time,
    required this.userId
  });

  factory Track.fromMap(Map<String, dynamic> json) => Track(
    id: json["id"],
    date: json["date"],
    distance: json["distance"],
    averageSpeed: json["average_speed"],
    time: json["time"],
    userId: json["user_id"]
  );

  Map<String, dynamic> toMap() => {
    "date": date,
    "distance": distance,
    "average_speed": averageSpeed,
    "time": time
  };
}
