import 'dart:math';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart' as audioplayers;
import 'package:just_audio/just_audio.dart';
import 'package:music_app/ui/now_playing/playing.dart';
import '../../data/model/song.dart';
import 'audio_player_manager.dart';

class MiniPlayingSong extends StatefulWidget {
  final List<Song> songs;
  final Song playingSong;

  const MiniPlayingSong(
      {Key? key, required this.songs, required this.playingSong})
      : super(key: key);

  @override
  _MiniPlayingSongState createState() => _MiniPlayingSongState();
}

class _MiniPlayingSongState extends State<MiniPlayingSong>
    with SingleTickerProviderStateMixin {
  late AnimationController _image;
  late AudioPlayerManager _audioPlayerManager;
  late int _selectedItemIndex;
  late Song _currentSong;
  late double _currentAnimationPosition;
  bool _isShuffle = false;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _currentSong = widget.playingSong;
    _currentAnimationPosition = 0.0;
    _image = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    )..repeat();
    _audioPlayerManager = AudioPlayerManager(songUrl: _currentSong.source);
    _audioPlayerManager.init();
    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);
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
            function: _setPrevSong,
            icon: Icons.skip_previous,
            color: Colors.black,
            size: 36,
          ),
          _playButton(),
          MediaButtonControl(
            function: _setNextSong,
            icon: Icons.skip_next,
            color: Colors.black,
            size: 36,
          ),
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
      },
    );
  }

  StreamBuilder<audioplayers.PlayerState> _playButton() {
    return StreamBuilder<audioplayers.PlayerState>(
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
            size: 48,
          );
        } else if (processingState != ProcessingState.completed) {
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.pause();
              _image.stop();
              _currentAnimationPosition = _image.value;
            },
            icon: Icons.pause,
            color: Colors.black,
            size: 48,
          );
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
            size: 48,
          );
        }
      },
    );
  }

  void _setNextSong() {
    if (_isShuffle) {
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    } else if (_selectedItemIndex < widget.songs.length - 1) {
      _selectedItemIndex++;
    } else if (_selectedItemIndex == widget.songs.length - 1) {
      _selectedItemIndex = 0;
    }

    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    setState(() {
      _currentSong = nextSong;
    });
  }

  void _setPrevSong() {
    if (_isShuffle) {
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    } else if (_selectedItemIndex > 0) {
      _selectedItemIndex--;
    } else if (_selectedItemIndex == 0) {
      _selectedItemIndex = widget.songs.length - 1;
    }

    final previousSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(previousSong.source);
    setState(() {
      _currentSong = previousSong;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: 150,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white, // Background for the mini player
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(context, CupertinoPageRoute(builder: (context) {
              return NowPlaying(
                songs: widget.songs,
                playingSong: _currentSong,
              );
            }));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  // Album art
                  CircleAvatar(
                    backgroundImage: NetworkImage(_currentSong.image),
                    radius: 30, // Slightly larger for better visibility
                  ),
                  SizedBox(width: 12), // Increased spacing

                  // Song title and artist
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentSong.title ?? 'Unknown Title',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16, // Increased font size for title
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4), // Spacing between title and artist
                        Text(
                          _currentSong.artist ?? 'Unknown Artist',
                          style: TextStyle(
                            fontSize: 14, // Increased font size for artist
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12), // Increased spacing

                  // Previous button
                  IconButton(
                    icon: Icon(Icons.skip_previous),
                    iconSize: 36,
                    color: Colors.black,
                    onPressed: _setPrevSong,
                  ),

                  // Play/Pause button
                  _playButton(), // Replacing _togglePlayPause() with _playButton()

                  // Next button
                  IconButton(
                    icon: Icon(Icons.skip_next),
                    iconSize: 36,
                    color: Colors.black,
                    onPressed: _setNextSong,
                  ),
                ],
              ),

              SizedBox(height: 10), // Increased spacing for the progress bar

              // Progress bar
              _progressBar(), // Progress bar widget
            ],
          ),
        ),
      ),
    );
  }



}

