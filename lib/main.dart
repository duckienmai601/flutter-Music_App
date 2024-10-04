import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_app/data/repository/Repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:music_app/ui/home/FavoriteView.dart';
import 'package:music_app/ui/home/home.dart';
import 'package:provider/provider.dart';



// void main() async{
//   DefaultRepository repository = DefaultRepository();
//   var songs = await repository.localData();
//   if(songs != null) {
//     for(var song in songs) {
//       debugPrint(song.toString());
//     }
//   }
//
// }

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(options: const FirebaseOptions(
          apiKey: "AIzaSyDrJ7V_4xhU4hDSkfjG66zhvDbqaWn56WQ",
          authDomain: "flutter-firebase-59c70.firebaseapp.com",
          projectId: "flutter-firebase-59c70",
          storageBucket: "flutter-firebase-59c70.appspot.com",
          messagingSenderId: "251963218773",
          appId: "1:251963218773:web:7e6d68c295fd799e532ddc"));
    runApp(
        MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => FavoriteViewModel()),
            ],
            child: const MusicApp()
    ));
  }




