import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/config/strings.dart';
import 'package:music_player/config/utility.dart';
import 'package:music_player/model/songs_model.dart';
import 'package:music_player/songs/home_screen.dart';
import 'package:music_player/songs/songs_event.dart';
import '../config/prefs.dart';
import 'songs_state.dart';

class SongBloc extends Bloc<SongsEvent, SongState> {
  var db = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  DocumentSnapshot? ds;
  Prefs prefs = Prefs();
  String uid = '';
  List<String> _fav = [];
  List<Song> _songs = [];
  SongBloc() : super(LoadingState()) {
    on<SearchSongs>((event, emit) async {
      List<Song> searchedSongs =
          await searchSong(event.searchQuery, event.songSearch);
      emit(LoadedSongsState(
        songs: searchedSongs,
      ));
    });

    on<LoadAllSongs>(((event, emit) async {
      List<Song> songsList = await getData();
      emit(
        LoadedSongsState(
          songs: songsList,
        ),
      );
    }));

    on<SyncFav>((event, emit) async {
      await syncWithServer();
      List<Song> songsList = await getData();
      emit(LoadedSongsState(songs: songsList));
    });

    on<AddSongToFav>(((event, emit) async {
      await addToFav(event.songId);
      List<Song> songList = [];
      if (await Utility.isNetworkConnected()) {
        songList = await getData();
      } else {
        songList = [..._songs];
        songList.where((element) => element.id == event.songId).first.isFav =
            true;
      }
      emit(LoadedSongsState(songs: songList));
    }));

    on<RemoveSongFromFav>(((event, emit) async {
      await removeFromFav(event.songId);
      List<Song> songList = [];
      if (await Utility.isNetworkConnected()) {
        songList = await getData();
      } else {
        songList = [..._songs];
        songList.where((element) => element.id == event.songId).first.isFav =
            false;
      }
      emit(LoadedSongsState(songs: songList));
    }));
  }
  Future<List<Song>> getData() async {
    List<String> favouritesList = await getFavouritesList();
    List<Song> songs = await getAllSongsList();
    List<Song> songsWithFav =
        await songConfigAsFav(fav: favouritesList, songs: songs);
    _songs = [...songsWithFav];
    _fav = [...favouritesList];
    return songsWithFav;
  }

  Future<List<String>> getFavouritesList() async {
    List<String> fav = [];
    DocumentSnapshot<Map<String, dynamic>> value = await db
        .collection(Strings.favouriteCollectionName)
        .doc(_firebaseAuth.currentUser!.uid)
        .get();

    if (value.data() != null && (value.data()?.isNotEmpty ?? false)) {
      fav = [...value.data()?[Strings.favouriteCollectionName]];
    } else {
      fav = [];
    }
    _fav = [...fav];
    await prefs.setFavourites(fav);
    return fav;
  }

  // This method fetches the song list from db
  Future<List<Song>> getAllSongsList() async {
    List<Song> songs = _songs;
    int totalSongs = await getTotalSongsCount();
    QuerySnapshot<Map<String, dynamic>> value;
    if (songs.length >= totalSongs) {
      return songs;
    }
    if (ds != null) {
      value = await db
          .collection(Strings.songsCollectionName)
          .startAfterDocument(ds!)
          .limit(5)
          .get();
    } else {
      value = await db.collection(Strings.songsCollectionName).limit(5).get();
    }

    ds = value.docs.last;

    for (var element in value.docs) {
      if (!songs.contains(Song.fromJson(element.data()))) {
        songs.add(Song.fromJson(element.data()));
      }
    }
    return songs;
  }

  Future<int> getTotalSongsCount() async {
    var value = await db.collection(Strings.songsCollectionName).count().get();
    return value.count ?? 0;
  }

  Future<List<Song>> searchSong(String query, SongSearch songSearch) async {
    List<Song> songs = [];
    var strSearch = query;
    var strlength = strSearch.length;
    var strFrontCode = strSearch.substring(0, strlength - 1);
    var strEndCode = strSearch.substring(strlength - 1, strSearch.length);

    var startcode = strSearch;
    var endcode =
        strFrontCode + String.fromCharCode(strEndCode.codeUnitAt(0) + 1);
    String filterField = Strings.songNameField;
    if (songSearch == SongSearch.artistName) {
      filterField = Strings.authorNameField;
    }
    var value = await db
        .collection(Strings.songsCollectionName)
        .where(
          filterField,
          isGreaterThanOrEqualTo: startcode,
          isLessThan: endcode,
        )
        .get(
          const GetOptions(
            source: Source.server,
          ),
        );

    if (value.docs.isEmpty) {}
    for (var element in value.docs) {
      songs.add(Song.fromJson(element.data()));
    }
    return songs;
  }

  // This method checks whether the song is fav
  Future<List<Song>> songConfigAsFav(
      {required List<String> fav, required List<Song> songs}) async {
    for (var song in songs) {
      if (fav.contains(song.id)) {
        song.isFav = true;
      } else {
        song.isFav = false;
      }
    }
    return songs;
  }

  // This method adds the song to fav list
  Future<void> addToFav(String songId) async {
    try {
      _fav.add(songId);
      if (await Utility.isNetworkConnected()) {
        updateFavList(_fav);
      } else {
        updateAddFavListLocal(_fav);
      }
    } catch (ex) {
      rethrow;
    }
  }

  // This method removes the song from fav list
  Future<void> removeFromFav(String songId) async {
    try {
      _fav.remove(songId);
      if (await Utility.isNetworkConnected()) {
        updateFavList(_fav);
      } else {
        updateAddFavListLocal(_fav);
      }
    } catch (ex) {
      rethrow;
    }
  }

  Future<void> updateAddFavListLocal(List<String> fav) async {
    await prefs.setFavourites(fav);
  }

  Future<void> updateRemoveFavListLocal(List<String> fav) async {
    await prefs.setFavourites(fav);
  }

  // This method updates the fav list
  Future<void> updateFavList(List<String> favourites) async {
    try {
      await db
          .collection(Strings.favouriteCollectionName)
          .doc(_firebaseAuth.currentUser!.uid)
          .set({Strings.favouriteCollectionName: favourites});
    } catch (ex) {
      throw 'Error adding in fav';
    }
  }

  Future<void> syncWithServer() async {
    List<String> favListLocal = await prefs.getFavourites();
    Function eq = const ListEquality().equals;

    List<String> favListOnline = await getFavouritesList();

    if (!eq(favListLocal, favListOnline)) {
      await updateFavList(favListLocal);
      getData();
    }
  }
}
