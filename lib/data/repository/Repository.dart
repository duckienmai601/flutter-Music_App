import 'package:music_app/data/source/source.dart';

import '../model/song.dart';

abstract interface class Repository {
  Future<List<Song>?> localData();
}

class DefaultRepository implements Repository {
  final _localDataSource = LocalDataSource();
  final _remoteDatasource = RemoteDataSource();
  @override
  Future<List<Song>?> localData() async {
    List<Song> songs = [];
    await _remoteDatasource.loadData().then((remoteSongs) {
      if(remoteSongs == null ) {
        _localDataSource.loadData().then((localSongs) {
          if(localSongs != null ){
            songs.addAll(localSongs);
    }
    });
    } else {
        songs.addAll(remoteSongs);
    }
    });
    return songs;
  }

}