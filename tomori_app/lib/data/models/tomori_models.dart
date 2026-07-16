class Customer {
  const Customer({
    required this.name,
    required this.time,
    required this.address,
    required this.imagePath,
    required this.nextVisit,
  });

  final String name;
  final String time;
  final String address;
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
