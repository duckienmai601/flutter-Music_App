import 'package:cloud_firestore/cloud_firestore.dart';

class Song {
  Song(
      {required this.id,
      required this.title,
      required this.album,
      required this.artist,
      required this.source,
      required this.image,
      required this.duration,
      this.isFavorite = false});

  factory Song.fromJson(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'],
      album: map['album'],
      artist: map['artist'],
      source: map['source'],
      image: map['image'],
      duration: map['duration'],
    );
  }

  String id;
  String title;
  String album;
  String artist;
  String source;
  String image;
  int duration;
  bool isFavorite;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Song{id: $id, title: $title, album: $album, artist: $artist, source: $source, image: $image, duration: $duration}';
  }

  static Song fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Song(
      id: snapshot['id'],
      title: snapshot['title'],
      artist: snapshot['artist'],
      image: snapshot['image'],
      album: snapshot['album'],
      source: snapshot['source'],
      duration: snapshot['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'image': image,
      'album': album,
      'source': source,
      'duration':duration,
    };
  }
}
