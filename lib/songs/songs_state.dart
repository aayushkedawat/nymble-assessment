import 'package:music_player/model/songs_model.dart';

abstract class SongState {}

class InitialState extends SongState {
  List<Song> songs;
  InitialState({
    required this.songs,
  });
}

class LoadingState extends SongState {}

class LoadedSongsState extends SongState {
  List<Song> songs;
  LoadedSongsState({
    required this.songs,
  });
}
