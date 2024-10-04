import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/ui/discovery/Discovery.dart';
import 'package:music_app/ui/home/viewmodel.dart';
import 'package:music_app/ui/settings/settings.dart';
import 'package:diacritic/diacritic.dart';
import 'package:provider/provider.dart';
import '../../data/model/song.dart';
import '../newmusic/music.dart';
import '../now_playing/playing.dart';
import 'Favorite.dart';
import 'FavoriteView.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Âm Nhạc',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const MusicHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<Widget> _tabs = [
    const HomeTab(),
    const DiscoveryTab(),
    const MusicTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.album), label: 'Discovery'),
            BottomNavigationBarItem(
                icon: Icon(Icons.music_note), label: 'New Music'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Setting'),
          ],
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          activeColor: Colors.black,
          inactiveColor: Colors.grey,
        ),
        tabBuilder: (BuildContext context, int index) {
          return _tabs[index];
        },
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  final List<Song> favoriteSongs = [];
  late MusicAppViewModel _viewModel;
  late User? currentUser = FirebaseAuth.instance.currentUser;


  @override
  void initState() {
    _viewModel = MusicAppViewModel();
    _viewModel.loadSong();
    observeData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
        leading: const Padding(
          padding: EdgeInsets.only(top: 2.0, left: 6.0),
          child: Text(
            'Home',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.white38,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                showSearch(
                  context: context,
                  delegate: SongSearchDelegate(
                      songs: [], parent: _HomeTabPageState()),
                );
              },
              child: const Icon(
                CupertinoIcons.search,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 16), // Khoảng cách giữa hai biểu tượng
            IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: navigateToFavorites,
            ),
          ],
        ),
      ),
      child: getBody(),
    );
  }

  @override
  void dispose() {
    _viewModel.songStream.close();
    super.dispose();
  }

  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if (showLoading) {
      return getProcessBar();
    } else {
      return getListView();
    }
  }

  Widget getProcessBar() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  ListView getListView() {
    return ListView.separated(
      itemBuilder: (context, position) {
        if (position == 0) {
          return Padding(
            padding: const EdgeInsets.only(top: 40, left: 30),
            child: RichText(
              text: const TextSpan(
                text: 'All Music',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 35,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Roboto',
                  // You can change this font if you want
                  decorationThickness: 2,
                ),
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 2.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              child: ListTile(
                title: getRow(position - 1), // Adjust index for songs list
                contentPadding: const EdgeInsets.all(2.0),
              ),
            ),
          );
        }
      },
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.grey,
          thickness: 1,
          indent: 24,
          endIndent: 24,
        );
      },
      itemCount: songs.length + 1, // Adjust item count for the title
      shrinkWrap: true,
    );
  }

  Widget getRow(int index) {
    return Center(
      child: _SongItemSection(parent: this, song: songs[index]),
    );
  }

  void observeData() {
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }

  void showBottomSheet(Song song) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              // Added SingleChildScrollView
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        song.image, // Replace with your image URL
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      song.title,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      song.artist,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: const Icon(Icons.keyboard_arrow_down,
                        color: Colors.black),
                  ),
                  const Divider(color: Colors.grey),
                  _buildBottomSheetItem(
                      Icons.play_arrow, 'Play', () => _handlePlay(song)),
                  _buildBottomSheetItem(Icons.favorite, 'Add to favorite list',
                      () => handleAddToFavorites(song)),
                  _buildBottomSheetItem(Icons.playlist_add, 'Add to playlist',
                      _handleAddToPlaylist),
                  _buildBottomSheetItem(
                      Icons.album, 'View album', _handleViewAlbum),
                  _buildBottomSheetItem(
                      Icons.person, 'View artist', _handleViewArtist),
                  _buildBottomSheetItem(Icons.block, 'Block', _handleBlock),
                  _buildBottomSheetItem(
                      Icons.error, 'Report error', _handleReportError),
                  _buildBottomSheetItem(
                      Icons.info, 'View song information', _handleViewSongInfo),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetItem(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        text,
        style: const TextStyle(color: Colors.black),
      ),
      onTap: () {
        onTap();
      },
    );
  }

  void _handlePlay(Song song) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return NowPlaying(
        songs: songs,
        playingSong: song,
      );
    }));
  }

  void handleAddToFavorites(Song song) {
    final favoritesProvider = Provider.of<FavoriteViewModel>(context, listen: false);

    if (!favoritesProvider.isFavorite(song)) {
      favoritesProvider.addFavorite(song);
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Added to Favorites'),
            content: Text('${song.title} has been added to your favorite list.'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void navigateToFavorites() {
    currentUser = FirebaseAuth.instance.currentUser;
    if(currentUser == null) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Login Required'),
            content: Text('You need to log in to view your favorite songs.'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Consumer<FavoriteViewModel>(
          builder: (context, favoritesProvider, child) {
            return FavoritePage(
              songs: favoritesProvider.favoriteSongs,
              playingSong: favoritesProvider.favoriteSongs.isNotEmpty
                  ? favoritesProvider.favoriteSongs[0]
                  : null,
            );
          },
        );
      }));
    }
  }

  void _handleAddToPlaylist() {
    // Implement your add to playlist logic here
    print('Add to playlist button tapped');
  }

  void _handleViewAlbum() {
    // Implement your view album logic here
    print('View album button tapped');
  }

  void _handleViewArtist() {
    // Implement your view artist logic here
    print('View artist button tapped');
  }

  void _handleBlock() {
    // Implement your block logic here
    print('Block button tapped');
  }

  void _handleReportError() {
    // Implement your report error logic here
    print('Report error button tapped');
  }

  void _handleViewSongInfo() {
    // Implement your view song information logic here
    print('View song information button tapped');
  }

  void navigate(Song song) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return NowPlaying(
        songs: songs,
        playingSong: song,
      );
    }));
  }
}

class _SongItemSection extends StatelessWidget {
  const _SongItemSection({required this.parent, required this.song});

  final _HomeTabPageState parent;
  final Song song;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.only(
            left: 24,
            right: 8,
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/asd.jpg',
              image: song.image,
              width: 48,
              height: 48,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/asd.jpg',
                  width: 48,
                  height: 48,
                );
              },
            ),
          ),
          title: Text(
            song.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            song.artist,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          trailing: IconButton(
            onPressed: () {
              parent.showBottomSheet(song);
            },
            icon: const Icon(Icons.more_horiz),
            color: Colors.grey[700],
          ),
          onTap: () {
            parent.navigate(song);
          },
        ),
      ),
    );
  }
}

class SongSearchDelegate extends SearchDelegate {
  final List<Song> songs;
  late MusicAppViewModel _viewModel;
  final _HomeTabPageState parent;

  SongSearchDelegate({required this.parent, required this.songs}) {
    _viewModel = MusicAppViewModel();
    _viewModel.loadSong();
    observeData();
  }

  void observeData() {
    _viewModel.songStream.stream.listen((songList) {
      songs.addAll(songList);
    });
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
  Widget buildSuggestions(BuildContext context) {
    List<Song> matchQuery = songs.where((item) {
      final normalizedQuery = removeDiacritics(query.toLowerCase());
      final normalizedTitle = removeDiacritics(item.title.toLowerCase());
      final normalizedArtist = removeDiacritics(item.artist.toLowerCase());

      return normalizedTitle.contains(normalizedQuery) ||
          normalizedArtist.contains(normalizedQuery);
    }).toList();

    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(
                matchQuery[index].title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                matchQuery[index].artist,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  matchQuery[index].image,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              onTap: () {
                navigate(context, matchQuery[index]);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Song> matchQuery = songs.where((item) {
      final lowerCaseQuery = query.toLowerCase();
      final titleMatch =
          RegExp(lowerCaseQuery).hasMatch(item.title.toLowerCase());
      final artistMatch =
          RegExp(lowerCaseQuery).hasMatch(item.artist.toLowerCase());

      return titleMatch || artistMatch;
    }).toList();

    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(
                matchQuery[index].title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                matchQuery[index].artist,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  matchQuery[index].image,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              onTap: () {
                navigate(context, matchQuery[index]);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context); // Refresh the suggestions
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }
}
