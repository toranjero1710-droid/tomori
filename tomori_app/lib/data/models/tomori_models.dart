class Customer {
  const Customer({
    required this.name,
    required this.displayName,
    required this.time,
    required this.address,
    required this.plan,
    required this.phone,
    required this.lineId,
    required this.keyNumber,
    required this.emergencyContact,
    required this.emergencyPhone,
    required this.imagePath,
    required this.nextVisit,
  });

  final String name;
  final String displayName;
  final String time;
  final String address;
  final String plan;
  final String phone;
  final String lineId;
  final String keyNumber;
  final String emergencyContact;
  final String emergencyPhone;
  final String imagePath;
  final String nextVisit;
}

class PhotoGuide {
  const PhotoGuide(this.name, this.done, this.imagePath);

  final String name;
  final bool done;
  final String imagePath;
}

class SeasonAlbum {
  const SeasonAlbum(this.name, this.months, this.imagePath);

  final String name;
  final String months;
  final String imagePath;
}
