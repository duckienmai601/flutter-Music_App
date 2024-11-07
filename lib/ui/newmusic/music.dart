import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/ui/home/Favorite.dart';
import 'package:music_app/ui/now_playing/mini_playing.dart';
import 'package:provider/provider.dart';

import '../../data/Firebase_auth/createData.dart';
import '../../data/model/song.dart';
import '../home/FavoriteView.dart';
import '../home/viewmodel.dart';
import '../now_playing/playing.dart';

class MusicTab extends StatelessWidget {
  const MusicTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Provider.of<FavoriteViewModel>(context).themeData,
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
  Song? _currentPlayingSong; // Variable to store the currently playing song

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



  @override
  Widget build(BuildContext context) {
    final favoriteViewModel = Provider.of<FavoriteViewModel>(context, listen: false);
    final isDarkMode =
        favoriteViewModel.themeData.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Song',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.white38 : Colors.white,
      ),
      body: Stack(
        children: [
          // Main content
          Container(
            color: isDarkMode ? Colors.black : Colors.white,
            child: ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(song.image),
                      ),
                      title: Text(
                        '${index + 1}. ${song.title}',
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
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
                            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () async {
                              // Kiểm tra xem bài hát đã có trong danh sách yêu thích chưa
                              Data getData = Data();
                              final favoriteSongs =
                                  await getData.readData().first;
                              bool alreadyInFavorites = favoriteSongs.any((s) =>
                                  s.title == song.title &&
                                  s.artist == song.artist);

                              final currentUser =
                                  FirebaseAuth.instance.currentUser;
                              final userCollection = FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(currentUser?.uid)
                                  .collection("songs");

                              setState(() {
                                if (alreadyInFavorites) {
                                  // Nếu bài hát đã có trong danh sách yêu thích, xóa nó
                                  userCollection.doc(song.id).delete();
                                  song.isFavorite = false;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'The Song has been removed from Favorites'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                } else {
                                  // Nếu bài hát chưa có, thêm nó vào danh sách yêu thích
                                  userCollection
                                      .doc(song.id)
                                      .set(song.toJson());
                                  song.isFavorite = true;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'The Song has been added to Favorites'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              });
                            },
                            icon: Icon(
                                   Icons.favorite_outline,
                              color:
                                  Colors.pink,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          _currentPlayingSong = song;
                        });
                        navigate(context, song);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void navigate(BuildContext context, Song song) {

    showBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.white,
          child: MiniPlayingSong(
            songs: songs,
            playingSong: _currentPlayingSong!,
          ),
        );
      },
    );
  }
}
