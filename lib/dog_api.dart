class DogImage {
  String? imageUrl;
  String? status;

  DogImage({this.imageUrl, this.status});

  DogImage.fromJson(Map<String, dynamic> json) {
    imageUrl = json['message'];
    status = json['status'];
  }
}
