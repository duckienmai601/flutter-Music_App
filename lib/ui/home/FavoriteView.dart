import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/Theme/theme.dart';

import '../../data/Firebase_auth/Firebase_auth_services.dart';
import '../../data/model/song.dart';

class FavoriteViewModel extends ChangeNotifier {
  List<Song> _favoriteSongs = [];

  List<Song> get favoriteSongs => _favoriteSongs;

  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if(_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }

  void addFavorite(Song song) {
    if (!_favoriteSongs.contains(song)) {
      _favoriteSongs.add(song);
      notifyListeners();
    }
  }

  void removeFavorite(Song song) {
    if (_favoriteSongs.contains(song)) {
      _favoriteSongs.remove(song);
      notifyListeners();
    }
  }

  bool isFavorite(Song song) {
    return _favoriteSongs.contains(song);
  }
}