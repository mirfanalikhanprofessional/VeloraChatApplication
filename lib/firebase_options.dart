// File generated manually from FlutterFire / Firebase console config.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCkCogPm79blT5zgZrri-XuTqe2Dn9tpYI',
    appId: '1:193068088377:web:f4455b82da8a442f49e1e8',
    messagingSenderId: '193068088377',
    projectId: 'chatapplication-f7e6d',
    authDomain: 'chatapplication-f7e6d.firebaseapp.com',
    storageBucket: 'chatapplication-f7e6d.firebasestorage.app',
    measurementId: 'G-6C7YYYJHYG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDbAVqGZbZEX1h12NGHdt9KHYoj29eBBFA',
    appId: '1:193068088377:android:05d24d0917c4f07b49e1e8',
    messagingSenderId: '193068088377',
    projectId: 'chatapplication-f7e6d',
    storageBucket: 'chatapplication-f7e6d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAb4l2sX5Z8FGV_LHYlgpxGarj0mQKUjvM',
    appId: '1:193068088377:ios:c483b1f8a5b5c57d49e1e8',
    messagingSenderId: '193068088377',
    projectId: 'chatapplication-f7e6d',
    storageBucket: 'chatapplication-f7e6d.firebasestorage.app',
    iosBundleId: 'com.testchat.testChatApplication',
  );
}
