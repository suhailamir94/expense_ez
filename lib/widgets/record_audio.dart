import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';

class RecordAudio extends StatefulWidget {
  const RecordAudio({super.key});

  @override
  State<RecordAudio> createState() => _RecordAudioState();
}

class _RecordAudioState extends State<RecordAudio> {
  late AudioRecorder audioRecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  bool isPlaying = false;
  String audioPath = '';

  @override
  void initState() {
    audioPlayer = AudioPlayer();
    audioRecord = AudioRecorder();
    super.initState();
  }

  @override
  void dispose() {
    audioRecord.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<String> _getPath() async {
    var dir = await getApplicationDocumentsDirectory();
    if (io.Platform.isAndroid) {
      dir = (await getExternalStorageDirectory())!;
    }
    return p.join(
      dir.path,
      'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );
  }

  Future<void> startRecording() async {
    try {
      if (await audioRecord.hasPermission()) {
        await audioRecord.start(const RecordConfig(), path: await _getPath());
        setState(() {
          isRecording = true;
        });
      }
    } catch (e) {
      print('Error starting to reocrd: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      if (await audioRecord.hasPermission()) {
        String? path = await audioRecord.stop();
        print('audio file path is: $path');
        setState(() {
          isRecording = false;
          audioPath = path!;
        });
      }
    } catch (e) {
      print('Error stoping to reocrd: $e');
    }
  }

  Future<void> playRecording() async {
    try {
      if (!audioPlayer.playing) {
        await audioPlayer.setFilePath(audioPath);
        audioPlayer.play();
        setState(() {
          isPlaying = true;
        });
      } else {
        audioPlayer.stop();
      }
    } catch (e) {
      print('Error starting to play reocrding: $e');
    }
  }

  Future<void> stopPlaying() async {
    try {
      if (audioPlayer.playing) {
        audioPlayer.stop();
        setState(() {
          isPlaying = false;
        });
      }
    } catch (e) {
      print('Error stoping playing reocrding: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Audio Recorder'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isRecording
                  ? ElevatedButton(
                      onPressed: stopRecording,
                      child: const Text('Stop Record'))
                  : ElevatedButton(
                      onPressed: startRecording,
                      child: const Text('Start Record')),
              const SizedBox(
                height: 25,
              ),
              if (!isRecording && audioPath.isNotEmpty && !isPlaying)
                ElevatedButton(
                    onPressed: playRecording,
                    child: const Text('Play Recording')),
              if (isPlaying)
                ElevatedButton(
                    onPressed: stopPlaying, child: const Text('Stop Playing'))
            ],
          ),
        ),
      ),
    );
  }
}
