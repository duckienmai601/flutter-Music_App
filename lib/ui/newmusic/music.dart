import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/ui/home/Favorite.dart';
import 'package:provider/provider.dart';

import '../../data/model/song.dart';
import '../home/FavoriteView.dart';
import '../home/viewmodel.dart';
import '../now_playing/playing.dart';

class MusicTab extends StatelessWidget {
  const MusicTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const MusicTabPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicTabPage extends StatefulWidget {
  const MusicTabPage({super.key});

  @override
  State<MusicTabPage> createState() => _MusicTabPageState();
}

class _MusicTabPageState extends State<MusicTabPage> {
  List<Song> favoriteSongs = [];
  List<Song> songs = [];
  late MusicAppViewModel _viewModel;


  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    _viewModel = MusicAppViewModel();
    _viewModel.loadSong();
    observeData();
    super.initState();
  }

  void observeData() {
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }

  @override
  void dispose() {
    _viewModel.songStream.close();
    super.dispose();
  }

  void navigate(BuildContext context, Song song) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return NowPlaying(
        songs: songs,
        playingSong: song,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'New Song',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.white38,
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(song.image),
                  ),
                  title: Text(
                    '${index + 1}. ${song.title}',
                    style: const TextStyle(color: Colors.black),
                  ),
                  subtitle: Text(
                    song.artist,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatDuration(song.duration),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          final favoritesProvider = Provider.of<FavoriteViewModel>(context, listen: false);
                          setState(() {
                            song.isFavorite = !song.isFavorite;
                            if (song.isFavorite) {
                              favoritesProvider.addFavorite(song);
                            } else {
                              favoritesProvider.removeFavorite(song);
                            }
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                song.isFavorite
                                    ? 'The Song has been added to Favorite'
                                    : 'The Song has been removed from Favorite',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );

                        },
                        icon: Icon(
                          song.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          color: song.isFavorite ? Colors.pink : Colors.black,
                        ),
                        color: Colors.black,
                      )
                    ],
                  ),
                  onTap: () {
                    navigate(context, songs[index]);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
