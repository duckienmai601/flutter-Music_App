import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/model/song.dart';
import '../home/viewmodel.dart';
import '../now_playing/playing.dart';

class DiscoveryTab extends StatelessWidget {
  const DiscoveryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const DiscoveryTabPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DiscoveryTabPage extends StatefulWidget {
  const DiscoveryTabPage({super.key});

  @override
  State<DiscoveryTabPage> createState() => _DiscoveryTabPageState();
}

class _DiscoveryTabPageState extends State<DiscoveryTabPage> {
  List<Song> songs = [];
  List<Song> recentlyPlayed = []; // Danh sách bài hát đã nghe gần đây
  late MusicAppViewModel _viewModel;

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

  void _showSongsByArtist(String artist) {
    List<Song> artistSongs = songs.where((song) => song.artist == artist).toList();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: artistSongs.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Image.network(artistSongs[index].image),
              title: Text(artistSongs[index].title),
              subtitle: Text(artistSongs[index].artist),
              onTap: () => navigate(context, artistSongs[index]),
            );
          },
        );
      },
    );
  }

  void navigate(BuildContext context, Song song) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return NowPlaying(
        songs: songs,
        playingSong: song,
      );
    }));
    setState(() {
      recentlyPlayed.add(song);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.only(start: 16, end: 16),
        leading: Padding(
          padding: EdgeInsets.only(top: 2.0, left: 6.0),
          child: Center(
            child: Text(
              'Discovery',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80,),
              Padding(
                padding: const EdgeInsets.only(top: 40,left: 30,bottom: 20),
                child: RichText(
                  text: const TextSpan(
                    text: 'Recommend',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 35,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Roboto', // Bạn có thể thay đổi font này nếu muốn
                      decorationThickness: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 220, // Chiều cao của danh sách ngang
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () => navigate(context, songs[index]),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.network(
                                  songs[index].image,
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                songs[index].title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                songs[index].artist,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 80,),
              Padding(
                padding: const EdgeInsets.only(top: 40,left: 30,bottom: 20),
                child: RichText(
                  text: const TextSpan(
                    text: 'Albums',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 35,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Roboto', // Bạn có thể thay đổi font này nếu muốn
                      decorationThickness: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 220, // Chiều cao của danh sách ngang
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: songs.map((song) => song.artist).toSet().length,
                  itemBuilder: (context, index) {
                    String artist = songs.map((song) => song.artist).toSet().elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () => _showSongsByArtist(artist),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.network(
                                  songs.firstWhere((song) => song.artist == artist).image,
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                artist,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 80,),
              Padding(
                padding: const EdgeInsets.only(top: 40,left: 30,bottom: 20),
                child: RichText(
                  text: const TextSpan(
                    text: 'Recently Played',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 35,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Roboto', // Bạn có thể thay đổi font này nếu muốn
                      decorationThickness: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 220, // Chiều cao của danh sách ngang
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recentlyPlayed.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () => navigate(context, recentlyPlayed[index]),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.network(
                                  recentlyPlayed[index].image,
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                recentlyPlayed[index].title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                recentlyPlayed[index].artist,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
