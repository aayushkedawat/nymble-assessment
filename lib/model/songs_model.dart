class Song {
  String? id;
  String? songName;
  String? thumbnailImagePath;
  String? description;
  String? author;
  String? credits;
  String? mp3Link;
  bool? isFav;

  Song({
    this.id,
    this.songName,
    this.thumbnailImagePath,
    this.description,
    this.author,
    this.credits,
    this.mp3Link,
    this.isFav,
  });
  Song.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    songName = json["songName"];
    thumbnailImagePath = json["thumbnailImagePath"];
    description = json["description"];
    author = json["author"];
    credits = json["credits"];
    mp3Link = json["mp3Link"];
    isFav = json["isFav"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> toJsonString = {};
    toJsonString['id'] = id;
    toJsonString['songName'] = songName;
    toJsonString['thumbnailImagePath'] = thumbnailImagePath;
    toJsonString['description'] = description;
    toJsonString['author'] = author;
    toJsonString['credits'] = credits;
    toJsonString['mp3Link'] = mp3Link;
    toJsonString['isFav'] = isFav;

    return toJsonString;
  }
}
