import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/model/song.dart';
import '../home/FavoriteView.dart';
import '../home/viewmodel.dart';
import '../now_playing/playing.dart';

class DiscoveryTab extends StatelessWidget {
  const DiscoveryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Provider.of<FavoriteViewModel>(context).themeData,
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
    final favoriteViewModel = Provider.of<FavoriteViewModel>(context, listen: false);
    final isDarkMode = favoriteViewModel.themeData.brightness == Brightness.dark;
    List<Song> artistSongs = songs.where((song) => song.artist == artist).toList();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: isDarkMode ? Colors.grey : Colors.white, // Adjust background color based on theme
          child: ListView.builder(
            itemCount: artistSongs.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Image.network(artistSongs[index].image),
                title: Text(
                  artistSongs[index].title,
                  style: TextStyle(color: Colors.black), // Text color based on theme
                ),
                subtitle: Text(
                  artistSongs[index].artist,
                  style: TextStyle(color: Colors.black), // Subtitle color based on theme
                ),
                onTap: () => navigate(context, artistSongs[index]),
              );
            },
          ),
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
    final favoriteViewModel = Provider.of<FavoriteViewModel>(context);
    final isDarkMode = favoriteViewModel.themeData.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.white38 : Colors.white,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 6.0),
          child: Text(
            'Discovery',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.black87, Colors.black54]
                : [Colors.white, Colors.grey[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 30, bottom: 20),
                child: Text(
                  'Recommend',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 35,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Roboto',
                    decorationThickness: 2,
                  ),
                ),
              ),
              // Recommend Section
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () => navigate(context, songs[index]),
                        child: Card(
                          color: isDarkMode ? Colors.grey[800] : Colors.white,
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
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                songs[index].artist,
                                style: TextStyle(
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[800],
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
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 30, bottom: 20),
                child: Text(
                  'Albums',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 35,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Roboto',
                    decorationThickness: 2,
                  ),
                ),
              ),
              // Albums Section
              SizedBox(
                height: 220,
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
                          color: isDarkMode ? Colors.grey[800] : Colors.white,
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
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.white : Colors.black,
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
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 30, bottom: 20),
                child: Text(
                  'Recently Played',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 35,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Roboto',
                    decorationThickness: 2,
                  ),
                ),
              ),
              // Recently Played Section
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recentlyPlayed.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () => navigate(context, recentlyPlayed[index]),
                        child: Card(
                          color: isDarkMode ? Colors.grey[800] : Colors.white,
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
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                recentlyPlayed[index].artist,
                                style: TextStyle(
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
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
