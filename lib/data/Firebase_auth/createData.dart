import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/song.dart';

class Data {

  void createData(Song userModel) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final userCollection = FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .collection("songs");

      String id = userCollection.doc().id;

      final newUser = Song(
          id: id,
          title: userModel.title,
          artist: userModel.artist,
          image: userModel.image,
          album: userModel.album,
          source: userModel.source,
          duration: userModel.duration)
          .toJson();

      userCollection.doc(id).set(newUser);
    }
  }

  Stream<List<Song>> readData() {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userCollection = FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser?.uid)
        .collection("songs");
    return userCollection.snapshots().map((querySnapShot) => querySnapShot.docs
        .map(
          (e) => Song.fromSnapShot(e),
    )
        .toList());
  }
}