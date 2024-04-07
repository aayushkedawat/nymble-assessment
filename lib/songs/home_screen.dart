import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/config/prefs.dart';
import 'package:music_player/config/text_themes.dart';
import 'package:music_player/songs/detail_screen.dart';
import 'package:music_player/model/favourite_model.dart';
import 'package:music_player/model/songs_model.dart';
import 'package:music_player/songs/songs_bloc.dart';
import 'package:music_player/songs/songs_event.dart';
import 'package:music_player/songs/songs_state.dart';
import 'package:page_animation_transition/animations/fade_animation_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:shimmer/shimmer.dart';

import '../config/common_widgets.dart';
import '../config/place_holder.dart';
import '../config/strings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchEditingController =
      TextEditingController();
  List<Song> songs = [];
  List<Favourite> fav = [];
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      context.read<SongBloc>().add(LoadAllSongs());
    });
  }

  SongSearch songSearch = SongSearch.songName;

  var db = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => context.read<SongBloc>().add(SyncFav()),
          ),
          CommonWidget.themeIcon(),
          IconButton(
            onPressed: () async {
              Prefs().clear();
              _firebaseAuth.signOut();
            },
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
        title: Text(
          Strings.appTitle,
          style: TextThemes.tsCairo18Bold,
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  Strings.playSongMakeMood,
                  style: TextThemes.tsCairo18Bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    Strings.searchBy,
                    style: TextThemes.tsCairo16Regular,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  DropdownButton(
                    value: songSearch == SongSearch.songName ? 1 : 2,
                    items: [
                      DropdownMenuItem(
                        value: 1,
                        child: Text(
                          Strings.songName,
                          style: TextThemes.tsCairo16Regular,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text(
                          Strings.artistName,
                          style: TextThemes.tsCairo16Regular,
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == 1) {
                        songSearch = SongSearch.songName;
                      } else {
                        songSearch = SongSearch.artistName;
                      }
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              CommonWidget.textFieldWidget(
                label: Strings.search,
                isPassword: false,
                textEditingController: _searchEditingController,
                suffixIcon: Icons.search,
                onChanged: (query) {
                  if (query.isNotEmpty) {
                    context.read<SongBloc>().add(SearchSongs(
                        searchQuery: query, songSearch: songSearch));
                  } else {
                    context.read<SongBloc>().add(LoadAllSongs());
                  }
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                Strings.recommendedSongs,
                style: TextThemes.tsCairo22Bold,
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: BlocBuilder<SongBloc, SongState>(
                  builder: (context, state) {
                    if (state is LoadingState) {
                      return loadingShimmerItem();
                    } else if (state is LoadedSongsState) {
                      return NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is ScrollEndNotification) {
                            context.read<SongBloc>().add(LoadAllSongs());
                          }
                          return false;
                        },
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            return listItem(state.songs[index], index);
                          },
                          itemCount: state.songs.length,
                          shrinkWrap: true,
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget loadingShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            ContentPlaceholder(
              lineType: ContentLineType.twoLines,
            ),
            SizedBox(height: 8.0),
            ContentPlaceholder(
              lineType: ContentLineType.twoLines,
            ),
            SizedBox(height: 8.0),
            ContentPlaceholder(
              lineType: ContentLineType.twoLines,
            ),
            SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  Widget listItem(Song song, int index) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        PageAnimationTransition(
          page: DetailPage(song: song),
          pageAnimationType: FadeAnimationTransition(),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: index % 2 == 0
                  ? Colors.pink.shade200.withOpacity(0.8)
                  : Colors.purple.shade200.withOpacity(0.8),
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Hero(
                    tag: song.id!,
                    child: CachedNetworkImage(
                      imageUrl: song.thumbnailImagePath!,
                      height: 75,
                      width: 75,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.songName ?? '',
                        style: TextThemes.tsCairo18Bold,
                      ),
                      Text(
                        song.author ?? '',
                        style: TextThemes.tsCairo16Regular,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (song.isFav ?? false) {
                      context.read<SongBloc>().add(
                            RemoveSongFromFav(songId: song.id!),
                          );
                    } else {
                      context.read<SongBloc>().add(
                            AddSongToFav(songId: song.id!),
                          );
                    }
                  },
                  icon: Icon(
                    (song.isFav ?? false)
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum SongSearch {
  songName,
  artistName,
}
