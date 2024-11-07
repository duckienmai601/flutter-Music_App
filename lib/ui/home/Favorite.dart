import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:music_app/ui/now_playing/mini_playing.dart';
import '../../data/Firebase_auth/createData.dart';
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
  const FavoritePage({super.key, required this.playingSong, required this.songs});

  final Song? playingSong;
  final List<Song> songs;

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final loadData = Data();


  Future<void> _deleteSong(String songId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final userCollection = FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .collection("songs");

      try {
        await userCollection.doc(songId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Song removed from favorites')),
        );
      } catch (e) {
        print("Error deleting song: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove song')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Songs'),
      ),
      body: StreamBuilder<List<Song>>(
        stream: loadData.readData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No favorite songs available'));
          }

          final songs = snapshot.data!;

          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(song.image),
                ),
                title: Text(song.title),
                subtitle: Text(song.artist),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteSong(song.id); // Gọi hàm xóa bài hát
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NowPlaying(
                        songs: widget.songs,
                        playingSong: song,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
