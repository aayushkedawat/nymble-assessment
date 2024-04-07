class Favourite {
  String? songId;
  String? userId;

  Favourite({
    this.songId,
    this.userId,
  });
  Favourite.fromJson(Map<String, dynamic> json) {
    songId = json["songId"];
    userId = json["userId"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> toJsonString = {};
    toJsonString['songId'] = songId;
    toJsonString['userId'] = userId;

    return toJsonString;
  }
}
