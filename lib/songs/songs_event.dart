import 'package:music_player/songs/home_screen.dart';

abstract class SongsEvent {}

class SearchSongs extends SongsEvent {
  final String searchQuery;
  final SongSearch songSearch;

  SearchSongs({required this.searchQuery, required this.songSearch});
}

class LoadAllSongs extends SongsEvent {
  LoadAllSongs();
}

class SyncFav extends SongsEvent {
  SyncFav();
}

class AddSongToFav extends SongsEvent {
  final String songId;

  AddSongToFav({required this.songId});
}

class RemoveSongFromFav extends SongsEvent {
  final String songId;

  RemoveSongFromFav({required this.songId});
}
