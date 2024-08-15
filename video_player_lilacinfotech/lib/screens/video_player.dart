import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player_lilacinfotech/auth/signup.dart';
import 'package:video_player_lilacinfotech/screens/video_bar.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _controllerVideo;
  final Duration _skipDuration = const Duration(seconds: 5);
  bool _isMuted = false;
  bool _isDarkMode = false;

  List<String> _videoList = [];
  int _currentVideoIndex = 0;
  String? _userImagePath;
  User? _user;

  @override
  void initState() {
    super.initState();
    _fetchVideoList().then((_) {
      if (_videoList.isNotEmpty) {
        _playVideo(_videoList[_currentVideoIndex]);
      }
    });
    _user = FirebaseAuth.instance.currentUser; 
  }

  @override
  void dispose() {
    _controllerVideo?.dispose();
    super.dispose();
  }

  Future<void> _fetchVideoList() async {
    final directory = await getApplicationDocumentsDirectory();
    final videoDir = Directory('${directory.path}/videos');

    if (await videoDir.exists()) {
      final videoFiles = videoDir
          .listSync()
          .where((file) =>
              file.path.endsWith('.mp4') || file.path.endsWith('.mov'))
          .toList();

      setState(() {
        _videoList = videoFiles.map((file) => file.path).toList();
      });
    } else {
      await videoDir.create(recursive: true);
    }
  }

  Future<void> _playVideo(String videoPath) async {
    if (_controllerVideo != null) {
      await _controllerVideo!.dispose();
    }

    _controllerVideo = VideoPlayerController.file(File(videoPath))
      ..setLooping(false)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controllerVideo!.play();
        }
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing video: $error')),
        );
      });
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path!);

      final directory = await getApplicationDocumentsDirectory();
      final videoDir = Directory('${directory.path}/videos');

      if (!(await videoDir.exists())) {
        await videoDir.create(recursive: true);
      }

      final newFile = File('${videoDir.path}/${file.uri.pathSegments.last}');
      await file.copy(newFile.path);

      setState(() {
        _videoList.add(newFile.path);
        _currentVideoIndex = _videoList.length - 1; 
        _playVideo(_videoList[_currentVideoIndex]);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No video selected')),
      );
    }
  }

  Future<void> _pickUserImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _userImagePath = result.files.single.path;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }

  void _toggleMute() {
    if (_controllerVideo != null) {
      setState(() {
        _isMuted = !_isMuted;
        _controllerVideo!.setVolume(_isMuted ? 0.0 : 1.0);
      });
    }
  }

  void _toggleTheme(bool isDarkMode) {
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  void _playNextVideo() {
    if (_videoList.isNotEmpty) {
      setState(() {
        _currentVideoIndex = (_currentVideoIndex + 1) % _videoList.length;
        _playVideo(_videoList[_currentVideoIndex]);
      });
    }
  }

  void _playPreviousVideo() {
    if (_videoList.isNotEmpty) {
      setState(() {
        _currentVideoIndex =
            (_currentVideoIndex - 1 + _videoList.length) % _videoList.length;
        _playVideo(_videoList[_currentVideoIndex]);
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PhoneAuth(), 
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("My Video Player"),
        ),
        body: Center(
          child: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _controllerVideo != null &&
                              _controllerVideo!.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: _controllerVideo!.value.aspectRatio,
                              child: VideoPlayer(_controllerVideo!),
                            )
                          : const CircularProgressIndicator(),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: size.width * 0.10,
                                child: IconButton(
                                  icon: Icon(_controllerVideo != null &&
                                          _controllerVideo!.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow),
                                  onPressed: () {
                                    if (_controllerVideo != null) {
                                      setState(() {
                                        if (_controllerVideo!.value.isPlaying) {
                                          _controllerVideo!.pause();
                                        } else {
                                          _controllerVideo!.play();
                                        }
                                      });
                                    }
                                  },
                                  iconSize: 50,
                                ),
                              ),
                              Tools(size)
                            ],
                          ),
                          const SizedBox(height: 0),
                          Center(
                            child: Container(
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                color: Color.fromARGB(255, 236, 236, 236),
                              ),
                              height: 100,
                              width: size.width * 0.3,
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    Icons.arrow_downward_sharp,
                                    color: Colors.green,
                                  ),
                                  Text(
                                    "Download",
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  MenuAndAcc(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

 SizedBox MenuAndAcc() {
  return SizedBox(
    height: 55,
    width: double.infinity,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
            size: 50,
          ),
          onPressed: _pickVideo,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: PopupMenuButton<String>(
            icon: _userImagePath != null
                ? CircleAvatar(
                    backgroundImage: FileImage(File(_userImagePath!)),
                  )
                : _user?.photoURL != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(_user!.photoURL!),
                      )
                    : CircleAvatar(child: Icon(Icons.person)),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_user?.phoneNumber ?? "Phone number not available"}'),
                    TextButton(
                      child: Text('Logout'),
                      onPressed: _logout,
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) {},
          ),
        ),
      ],
    ),
  );
}



  SizedBox Tools(Size size) {
    return SizedBox(
      width: size.width * 0.70,
      child: Column(
        children: [
          _controllerVideo != null
              ? VideoProgressBar(controller: _controllerVideo!)
              : const SizedBox.shrink(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: _playPreviousVideo,
                iconSize: 35,
              ),
              IconButton(
                icon: const Icon(Icons.replay_10),
                onPressed: () {
                  if (_controllerVideo != null) {
                    final position = _controllerVideo!.value.position;
                    final newPosition = position - _skipDuration;
                    _controllerVideo!.seekTo(newPosition < Duration.zero
                        ? Duration.zero
                        : newPosition);
                  }
                },
                iconSize: 25,
              ),
              IconButton(
                icon: const Icon(Icons.forward_10),
                onPressed: () {
                  if (_controllerVideo != null) {
                    final position = _controllerVideo!.value.position;
                    final duration = _controllerVideo!.value.duration;
                    final newPosition = position + _skipDuration;
                    _controllerVideo!.seekTo(
                        newPosition > duration ? duration : newPosition);
                  }
                },
                iconSize: 25,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: _playNextVideo,
                iconSize: 35,
              ),
              IconButton(
                icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
                onPressed: _toggleMute,
                iconSize: 35,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.settings),
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'light',
                    child: ListTile(
                      leading: Icon(Icons.wb_sunny),
                      title: Text('Light Mode'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'dark',
                    child: ListTile(
                      leading: Icon(Icons.nights_stay),
                      title: Text('Dark Mode'),
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'dark') {
                    _toggleTheme(true);
                  } else {
                    _toggleTheme(false);
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
