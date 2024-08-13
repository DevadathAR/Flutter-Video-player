import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_video_player/screens/video_bar.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controllerVideo;
  final Duration _skipDuration = const Duration(seconds: 5);
  bool _isMuted = false;
  bool _isDarkMode = false; // State variable for dark mode

  @override
  void initState() {
    super.initState();
    _controllerVideo = VideoPlayerController.asset("assets/intro.mp4");
    _controllerVideo.setLooping(false);
    _controllerVideo.initialize().then((_) => setState(() {}));
    _controllerVideo.play();
  }

  @override
  void dispose() {
    _controllerVideo.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path!);

      setState(() {
        _controllerVideo = VideoPlayerController.file(file)
          ..setLooping(false)
          ..initialize().then((_) => setState(() {}))
          ..play();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No video selected')),
      );
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controllerVideo.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _toggleTheme(bool isDarkMode) {
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      debugShowCheckedModeBanner: false, // Disable the debug banner
      home: Scaffold(
        appBar: AppBar(
          title: const Text("My video player"),
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
                      _controllerVideo.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: _controllerVideo.value.aspectRatio,
                              child: VideoPlayer(_controllerVideo),
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
                                  icon: Icon(_controllerVideo.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow),
                                  onPressed: () {
                                    setState(() {
                                      if (_controllerVideo.value.isPlaying) {
                                        _controllerVideo.pause();
                                      } else {
                                        _controllerVideo.play();
                                      }
                                    });
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
              color: Color.fromARGB(255, 255, 255, 255),
              size: 50,
            ),
            onPressed: _pickVideo,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              height: 50,
              width: 50,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white),
            child: Icon(Icons.person),),
          )
        ],
      ),
    );
  }

  SizedBox Tools(Size size) {
    return SizedBox(
      width: size.width * 0.70,
      child: Column(
        children: [
          VideoProgressBar(controller: _controllerVideo),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: () {},
                iconSize: 35,
              ),
              IconButton(
                icon: const Icon(Icons.replay_10),
                onPressed: () {
                  final position = _controllerVideo.value.position;
                  final newPosition = position - _skipDuration;
                  _controllerVideo.seekTo(newPosition < Duration.zero
                      ? Duration.zero
                      : newPosition);
                },
                iconSize: 25,
              ),
              IconButton(
                icon: const Icon(Icons.forward_10),
                onPressed: () {
                  final position = _controllerVideo.value.position;
                  final duration = _controllerVideo.value.duration;
                  final newPosition = position + _skipDuration;
                  _controllerVideo
                      .seekTo(newPosition > duration ? duration : newPosition);
                },
                iconSize: 25,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () {
                  // Implement next video logic here
                },
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
