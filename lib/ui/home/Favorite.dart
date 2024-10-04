import 'package:flutter/material.dart';

import '../../data/model/song.dart';
import '../now_playing/playing.dart';

class Favorite extends StatelessWidget {
  const Favorite({super.key, required this.playingSong, required this.songs});

  final Song playingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return FavoritePage(
      songs: songs,
      playingSong: playingSong,
    );
  }
}

class FavoritePage extends StatefulWidget {
  const FavoritePage(
      {super.key, required this.playingSong, required this.songs});

  final Song? playingSong;
  final List<Song> songs;

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Songs'),
      ),
      body: widget.songs.isEmpty
          ? const Center(child: Text('No favorite songs available'))
          : ListView.builder(
              itemCount: widget.songs.length,
              itemBuilder: (context, index) {
                final song = widget.songs[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(song.image),
                  ),
                  title: Text(song.title),
                  subtitle: Text(song.artist),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return NowPlayingPage(
                        songs: widget.songs,
                        playingSong: song,
                      );
                    }));
                  },
                );
              },
            ),
    );
  }
}
