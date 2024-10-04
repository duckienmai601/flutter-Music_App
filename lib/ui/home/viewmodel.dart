import 'dart:async';

import 'package:music_app/data/repository/Repository.dart';

import '../../data/model/song.dart';

class MusicAppViewModel {
  StreamController<List<Song>> songStream = StreamController();

  void loadSong() {
    final repository = DefaultRepository();
    repository.localData().then((value) => songStream.add(value!));
  }

}