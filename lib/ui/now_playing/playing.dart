import 'dart:math';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/model/song.dart';
import '../home/FavoriteView.dart';
import 'audio_player_manager.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.songs, required this.playingSong});

  final Song playingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(
      songs: songs,
      playingSong: playingSong,
    );
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage(
      {super.key, required this.songs, required this.playingSong});

  final Song playingSong;
  final List<Song> songs;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _image;
  late AudioPlayerManager _audioPlayerManager;
  late int _selectedItemIndex;
  late Song _song;
  late double _currentAnimationPosition;
  bool _isShuffle = false;
  late LoopMode _loopMode;


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
                      Icons.download, 'Download', _handleDownload),
                  _buildBottomSheetItem(Icons.favorite, 'Add to favorite list',
                          () => handleAddToFavorites(song)),
                  _buildBottomSheetItem(Icons.playlist_add, 'Add to playlist',
                      _handleAddToPlaylist),
                  _buildBottomSheetItem(
                      Icons.queue_music, 'Play next', _handlePlayNext),
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

  void _handleDownload() {
    // Implement your add to favorites logic here
    print('Add to favorite list button tapped');
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

  void _handleAddToPlaylist() {
    // Implement your add to playlist logic here
    print('Add to playlist button tapped');
  }

  void _handlePlayNext() {
    // Implement your play next logic here
    print('Play next button tapped');
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

  @override
  void initState() {
    super.initState();
    _song = widget.playingSong;
    _currentAnimationPosition = 0.0;
    _image = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );
    _audioPlayerManager = AudioPlayerManager(songUrl: _song.source);
    _audioPlayerManager.init();
    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);
    _loopMode = LoopMode.off;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64;
    final radius = (screenWidth - delta) / 2;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Now Playing',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        trailing: IconButton(
          onPressed: () {
            showBottomSheet(_song);
          },
          icon: const Icon(Icons.more_horiz, color: Colors.black),
        ),
        backgroundColor: Colors.white38,
      ),
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            // Added SingleChildScrollView
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                Text(
                  _song.album,
                  style: const TextStyle(fontSize: 15, color: Colors.black),
                ),
                const SizedBox(height: 16),
                const Text('-----', style: TextStyle(color: Colors.black)),
                const SizedBox(height: 48),
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 1.0).animate(_image),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/asd.jpg',
                      image: _song.image,
                      width: screenWidth - delta,
                      height: screenWidth - delta,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/asd.jpg',
                          width: screenWidth - delta,
                          height: screenWidth - delta,
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 64, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: sharePress,
                        icon: const Icon(Icons.share_outlined),
                        color: Colors.black,
                      ),
                      Column(
                        children: [
                          Text(
                            _song.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _song.artist,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          final favoritesProvider = Provider.of<FavoriteViewModel>(context, listen: false);
                          setState(() {
                            _song.isFavorite = !_song.isFavorite;
                            if (_song.isFavorite) {
                              favoritesProvider.addFavorite(_song);
                            } else {
                              favoritesProvider.removeFavorite(_song);
                            }
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _song.isFavorite
                                    ? 'The Song has been added to Favorite'
                                    : 'The Song has been removed from Favorite',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: Icon(
                          _song.isFavorite ? Icons.favorite : Icons.favorite_outline,
                          color: _song.isFavorite ? Colors.pink : Colors.black,
                        ),
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: _progressBar(),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: _mediaButtons(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayerManager.dispose();
    _image.dispose();
    super.dispose();
  }

  Widget _mediaButtons() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(
              function: _setSuffle,
              icon: Icons.shuffle,
              color: _getSuffle(),
              size: 24),
          MediaButtonControl(
              function: _setPrevSong,
              icon: Icons.skip_previous,
              color: Colors.black,
              size: 36),
          _playButton(),
          MediaButtonControl(
              function: _setNextSong,
              icon: Icons.skip_next,
              color: Colors.black,
              size: 36),
          MediaButtonControl(
              function: _setRepeatOption,
              icon: _repeatingIcon(),
              color: _getRepeatingIcon(),
              size: 24),
        ],
      ),
    );
  }

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
        stream: _audioPlayerManager.durationState,
        builder: (context, snapshot) {
          final durationState = snapshot.data;
          final progress = durationState?.progress ?? Duration.zero;
          final buffered = durationState?.buffered ?? Duration.zero;
          final total = durationState?.total ?? Duration.zero;
          return ProgressBar(
            progress: progress,
            total: total,
            buffered: buffered,
            onSeek: _audioPlayerManager.player.seek,
            barHeight: 5.0,
            barCapShape: BarCapShape.round,
            baseBarColor: Colors.grey.withOpacity(0.3),
            progressBarColor: Colors.black,
            bufferedBarColor: Colors.grey.withOpacity(0.3),
            thumbColor: Colors.grey,
            thumbRadius: 10.0,
          );
        });
  }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
        stream: _audioPlayerManager.player.playerStateStream,
        builder: (context, snapshot) {
          final playState = snapshot.data;
          final processingState = playState?.processingState;
          final playing = playState?.playing;
          if (processingState == ProcessingState.loading ||
              processingState == ProcessingState.buffering) {
            return Container(
              margin: const EdgeInsets.all(8),
              width: 48,
              height: 48,
              child: const CircularProgressIndicator(),
            );
          } else if (playing != true) {
            return MediaButtonControl(
                function: () {
                  _audioPlayerManager.player.play();
                  _image.forward(from: _currentAnimationPosition);
                  _image.repeat();
                },
                icon: Icons.play_arrow,
                color: Colors.black,
                size: 48);
          } else if (processingState != ProcessingState.completed) {
            return MediaButtonControl(
                function: () {
                  _audioPlayerManager.player.pause();
                  _image.stop();
                  _currentAnimationPosition = _image.value;
                },
                icon: Icons.pause,
                color: Colors.black,
                size: 48);
          } else {
            if (processingState == ProcessingState.completed) {
              _image.stop();
              _currentAnimationPosition = 0.0;
            }
            return MediaButtonControl(
                function: () {
                  _image.forward(from: _currentAnimationPosition);
                  _image.repeat();
                  _audioPlayerManager.player.seek(Duration.zero);
                },
                icon: Icons.replay,
                color: Colors.black,
                size: 48);
          }
        });
  }

  void _setSuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
    });
  }

  Color? _getSuffle() {
    return _isShuffle ? Colors.black : Colors.grey;
  }

  void _setNextSong() {
    if (_isShuffle) {
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    } else if (_selectedItemIndex < widget.songs.length - 1) {
      ++_selectedItemIndex;
    } else if (_loopMode == LoopMode.all &&
        _selectedItemIndex == widget.songs.length - 1) {
      _selectedItemIndex = 0;
    }
    if (_selectedItemIndex >= widget.songs.length) {
      _selectedItemIndex = _selectedItemIndex % widget.songs.length;
    }
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    setState(() {
      _song = nextSong;
    });
  }

  void _setPrevSong() {
    if (_isShuffle) {
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    } else if (_selectedItemIndex > 0) {
      --_selectedItemIndex;
    } else if (_loopMode == LoopMode.all && _selectedItemIndex == 0) {
      _selectedItemIndex = widget.songs.length - 1;
    }
    if (_selectedItemIndex < 0) {
      _selectedItemIndex = (-1 * _selectedItemIndex) % widget.songs.length;
    }
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    setState(() {
      _song = nextSong;
    });
  }

  void _setRepeatOption() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.all;
    } else {
      _loopMode = LoopMode.off;
    }
    setState(() {
      _audioPlayerManager.player.setLoopMode(_loopMode);
    });
  }

  IconData _repeatingIcon() {
    return switch (_loopMode) {
      LoopMode.all => Icons.repeat_on,
      _ => Icons.repeat,
    };
  }

  Color? _getRepeatingIcon() {
    return _loopMode == LoopMode.off ? Colors.grey : Colors.black;
  }

  void sharePress() {
    Share.share('Share now!');
  }
}

class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl({
    super.key,
    required this.function,
    required this.icon,
    required this.color,
    required this.size,
  });

  final void Function()? function;
  final IconData icon;
  final double? size;
  final Color? color;

  @override
  State<StatefulWidget> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }


}
