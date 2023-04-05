// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:myproj/api/firebase_api.dart';
// import 'package:myproj/widget/button_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:path/path.dart';
// import 'package:video_player/video_player.dart';

// Future main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);

//   await Firebase.initializeApp();

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   static final String title = 'Subtitle Generator';

//   @override
//   Widget build(BuildContext context) => MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: title,
//         theme: ThemeData(primarySwatch: Colors.green),
//         home: MainPage(),
//       );
// }

// class MainPage extends StatefulWidget {
//   @override
//   _MainPageState createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
//   UploadTask? task;
//   File? file;
//   VideoPlayerController? _controller;
//   String RESULT = "";
//   String fileName = "";

//   @override
//   void dispose() {
//     super.dispose();
//     _controller?.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     fileName = file != null ? basename(file!.path) : 'No File Selected';

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(MyApp.title),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           padding: EdgeInsets.all(32),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ButtonWidget(
//                   text: 'Select File',
//                   icon: Icons.attach_file,
//                   onClicked: selectFile,
//                 ),
//                 SizedBox(height: 8),
//                 file != null
//                     ? AspectRatio(
//                         aspectRatio: _controller!.value.aspectRatio,
//                         child: VideoPlayer(_controller!),
//                       )
//                     : Container(),
//                 SizedBox(height: 8),
//                 Text(
//                   fileName,
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                 ),
//                 SizedBox(height: 48),
//                 ButtonWidget(
//                   text: 'Upload File',
//                   icon: Icons.cloud_upload_outlined,
//                   onClicked: uploadFile,
//                 ),
//                 SizedBox(height: 20),
//                 ButtonWidget(
//                   text: 'Subtitle',
//                   icon: Icons.subtitles,
//                   onClicked: predict,
//                 ),
//                 const SizedBox(
//                   height: 60,
//                   width: 150,
//                 ),
//                 Text(
//                   RESULT,
//                   style: const TextStyle(
//                       fontSize: 20, fontWeight: FontWeight.w500),
//                 ),
//                 task != null ? buildUploadStatus(task!) : Container(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future selectFile() async {
//     final result = await FilePicker.platform.pickFiles(allowMultiple: false);

//     if (result == null) return;
//     final path = result.files.single.path!;

//     setState(() {
//       file = File(path);
//       _controller = VideoPlayerController.file(file!);
//       _controller?.initialize();
//       _controller?.pause();
//       _controller?.play();
//       _controller?.setLooping(true);
//     });
//   }

//   Future uploadFile() async {
//     if (file == null) return;

//     final fileName = basename(file!.path);
//     final destination = 'files/$fileName';

//     task = FirebaseApi.uploadFile(destination, file!);
//     setState(() {});

//     if (task == null) return;

//     final snapshot = await task!.whenComplete(() {});
//     final urlDownload = await snapshot.ref.getDownloadURL();

//     print('Download-Link: $urlDownload');
//   }

//   Future predict() async {
//     showDialog(
//       context: this.context,
//       builder: (context) {
//         return const Center(child: CircularProgressIndicator());
//       },
//     );
//     http.Response res = await http.get(Uri.parse(
//         "https://ea5e-2405-201-c00e-6ab1-d83b-d6d4-4d73-bfe0.in.ngrok.io/?query=$fileName"));
//     var next = res.body;
//     var decoded = jsonDecode(next);
//     //return Text(decoded["output"]);
//     Navigator.of(this.context).pop();
//     setState(() {
//       RESULT = decoded["output"];
//     });
//   }

//   Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
//         stream: task.snapshotEvents,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             final snap = snapshot.data!;
//             final progress = snap.bytesTransferred / snap.totalBytes;
//             final percentage = (progress * 100).toStringAsFixed(2);

//             return Text(
//               '$percentage %',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             );
//           } else {
//             return Container();
//           }
//         },
//       );
// }

//main code

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myproj/api/firebase_api.dart';
import 'package:myproj/player.dart';
import 'package:myproj/widget/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:video_player/video_player.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final String title = 'Firebase Upload';

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        theme: ThemeData(primarySwatch: Colors.green),
        home: MainPage(),
      );
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  UploadTask? task;
  File? file;
  VideoPlayerController? _controller;
  String RESULT = "";
  String fileName = "";

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fileName = file != null ? basename(file!.path) : 'No File Selected';

    return Scaffold(
      appBar: AppBar(
        title: Text(MyApp.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ButtonWidget(
                  text: 'Select File',
                  icon: Icons.attach_file,
                  onClicked: selectFile,
                ),
                SizedBox(height: 8),
                file != null
                    ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      )
                    : Container(),
                SizedBox(height: 8),
                Text(
                  fileName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 48),
                ButtonWidget(
                  text: 'Upload File',
                  icon: Icons.cloud_upload_outlined,
                  onClicked: uploadFile,
                ),
                SizedBox(height: 20),
                ButtonWidget(
                  text: 'Subtitle',
                  icon: Icons.message_rounded,
                  onClicked: predict,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen()),
                    );
                  },
                  child: Text('Player'),
                ),
                const SizedBox(
                  height: 60,
                  width: 150,
                ),
                Text(
                  RESULT,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500),
                ),
                task != null ? buildUploadStatus(task!) : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.single.path!;

    setState(() {
      file = File(path);
      _controller = VideoPlayerController.file(file!);
      _controller?.initialize();
      _controller?.pause();
      _controller?.play();
      _controller?.setLooping(true);
    });
  }

  Future uploadFile() async {
    if (file == null) return;

    final fileName = basename(file!.path);
    final destination = 'files/$fileName';

    task = FirebaseApi.uploadFile(destination, file!);
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    print('Download-Link: $urlDownload');
  }

  Future predict() async {
    showDialog(
      context: this.context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
    http.Response res = await http.get(
        Uri.parse("https://aac0-183-82-111-80.in.ngrok.io/?query=$fileName"));
    var next = res.body;
    var decoded = jsonDecode(next);
    //return Text(decoded["output"]);
    Navigator.of(this.context).pop();
    setState(() {
      RESULT = decoded["output"];
    });
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);

            return Text(
              '$percentage %',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            );
          } else {
            return Container();
          }
        },
      );
}

//Anjali code

// import 'dart:convert';
// import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:video_player/video_player.dart';

// // import 'audio.dart';
// // import 'front_end.dart';
// Future main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);

//   await Firebase.initializeApp();

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   static final String title = 'Subtitle Generator';

//   @override
//   Widget build(BuildContext context) => MaterialApp(
//         debugShowCheckedModeBanner: false,
//         // title: title,
//         // theme: ThemeData(primarySwatch: Colors.green),
//         home: MyVideoPicker(),
//       );
// }

// class MyVideoPicker extends StatefulWidget {
//   @override
//   _MyVideoPickerState createState() => _MyVideoPickerState();
// }

// class _MyVideoPickerState extends State<MyVideoPicker> {
//   File? _videoFile;
//   VideoPlayerController? _videoPlayerController;
// //   VideoPlayerController? _controller;

//   bool _isVideoPlayerReady = false;
//   bool _isPlaying = false;
//   String fileName = "";
//   String RESULT = "";
//   Future<void> _uploadVideo() async {
//     if (_videoFile != null) {
//       try {
//         final ref = FirebaseStorage.instance
//             .ref()
//             .child('videos/${_videoFile!.path.split('/').last}');
//         await ref.putFile(_videoFile!);
//         final downloadUrl = await ref.getDownloadURL();
//         Text("Video uploaded successfully: $downloadUrl");
//       } catch (e) {
//         Text("Error uploading video: $e");
//       }
//     }
//   }

//   void _pickVideo() async {
//     final pickedFile =
//         await ImagePicker().pickVideo(source: ImageSource.gallery);
//     setState(() {
//       _videoFile = File(pickedFile!.path);
//       _videoPlayerController = VideoPlayerController.file(_videoFile!);
//     });
//     _initializeVideoPlayer();
//   }

//   void _initializeVideoPlayer() {
//     _videoPlayerController!.addListener(() {
//       if (_videoPlayerController!.value.isInitialized) {
//         setState(() {
//           _isVideoPlayerReady = true;
//         });
//       }
//     });
//     _videoPlayerController!.setLooping(true);
//     _videoPlayerController!.initialize().then((_) {
//       setState(() {});
//     });
//   }

//   void _playPause() {
//     setState(() {
//       if (_isPlaying) {
//         _videoPlayerController!.pause();
//         _isPlaying = false;
//       } else {
//         _videoPlayerController!.play();
//         _isPlaying = true;
//       }
//     });
//   }

//   void _setPlaybackSpeed(double speed) {
//     _videoPlayerController!.setPlaybackSpeed(speed);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _videoPlayerController!.dispose();
//   }

//   Future<void> uploadVideo() async {
//     if (_videoFile != null) {
//       try {
//         final ref = FirebaseStorage.instance
//             .ref()
//             .child('videos/${_videoFile!.path.split('/').last}');
//         await ref.putFile(_videoFile!);
//         final downloadUrl = await ref.getDownloadURL();
//         Text("Video uploaded successfully: $downloadUrl");
//       } catch (e) {
//         Text("Error uploading video: $e");
//       }
//     }
//   }

//   Future predict() async {
//     showDialog(
//       context: this.context,
//       builder: (context) {
//         return const Center(child: CircularProgressIndicator());
//       },
//     );
//     http.Response res = await http.get(Uri.parse(
//         "https://1883-2405-201-c00e-6ab1-95c8-4453-11ea-1da0.in.ngrok.io/?query=$fileName"));
//     var next = res.body;
//     var decoded = jsonDecode(next);
//     //return Text(decoded["output"]);
//     Navigator.of(this.context).pop();
//     setState(() {
//       RESULT = decoded["output"];
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Video Picker Demo'),
//         ),
//         body: SingleChildScrollView(
//           child: Center(
//             child: _videoFile == null
//                 ? Text('No video selected.')
//                 : _isVideoPlayerReady
//                     ? Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           AspectRatio(
//                             aspectRatio:
//                                 _videoPlayerController!.value.aspectRatio,
//                             child: VideoPlayer(_videoPlayerController!),
//                           ),
//                           SizedBox(height: 20),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               IconButton(
//                                 onPressed: _playPause,
//                                 icon: Icon(_isPlaying
//                                     ? Icons.pause
//                                     : Icons.play_arrow),
//                               ),
//                               IconButton(
//                                 onPressed: () => _setPlaybackSpeed(0.5),
//                                 icon: Text('0.5x'),
//                               ),
//                               IconButton(
//                                 onPressed: () => _setPlaybackSpeed(1),
//                                 icon: Text('1x'),
//                               ),
//                               IconButton(
//                                 onPressed: () => _setPlaybackSpeed(2),
//                                 icon: Text('2x'),
//                               ),
//                             ],
//                           ),
//                         ],
//                       )
//                     : CircularProgressIndicator(),
//           ),
//         ),
//         floatingActionButton: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             SizedBox(width: 6),
//             FloatingActionButton(
//               onPressed: _pickVideo,
//               tooltip: 'Pick Video',
//               child: Icon(Icons.add),
//             ),
//             SizedBox(width: 6),
//             // FloatingActionButton(
//             //   onPressed: () {
//             //     Navigator.push(
//             //       context,
//             //       MaterialPageRoute(
//             //           builder: (context) => VideoToAudioConverter()),
//             //     );
//             //   },
//             //   tooltip: 'Extract audio',
//             //   child: Icon(Icons.explicit_rounded),
//             // ),
//             SizedBox(width: 6),
//             FloatingActionButton(
//               onPressed: _uploadVideo,
//               tooltip: 'Upload Video',
//               child: Icon(Icons.cloud_upload),
//             ),
//             SizedBox(width: 6),
//             FloatingActionButton(
//               onPressed: predict,
//               child: Icon(Icons.add_a_photo_outlined),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
