import 'dart:async';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';

typedef void OnError(Exception exception);

const kUrl = "http://stream.kalx.berkeley.edu:8000/kalx-256.mp3";
const kUrl2 = "http://stream.kalx.berkeley.edu:8000/kalx-256.mp3";

const BUTTON_COLOR = Colors.tealAccent;

void main() {
  runApp(new MaterialApp(home: new Scaffold(body: new AudioApp())));
}

enum PlayerState { stopped, playing, paused }

class AudioApp extends StatefulWidget {
  @override
  _AudioAppState createState() => new _AudioAppState();
}

class _AudioAppState extends State<AudioApp> {

  AudioPlayer audioPlayer;

  String localFilePath;

  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  bool isMuted = false;

  StreamSubscription _audioPlayerStateSubscription;

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }

  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();

    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
        if (s == AudioPlayerState.STOPPED) {
        onComplete();
        setState(() {});
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.stopped;
      });
    });
  }

  Future play() async {
    await audioPlayer.play(kUrl);
    setState(() {
      playerState = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
    });
  }

  Future mute(bool muted) async {
    await audioPlayer.mute(muted);
    setState(() {
      isMuted = muted;
    });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('KALX TRUE TRUE'),
          backgroundColor: Colors.black,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
//                _select(choices[0]);      //https://flutter.dev/docs/catalog/samples/basic-app-bar
              },
            ),
            IconButton(
              icon: Icon(Icons.attach_money),
              onPressed: () {
//                _select(choices[1]);
              },
            ),
//            PopupMenuButton<Choice>(
//              onSelected: _select,
//              itemBuilder: (BuildContext context) {
//                return choices.skip(2).map((Choice choice) {
//                  return PopupMenuItem<Choice>(
//                    value: choice,
//                    child: Text(choice.title),
//                  );
//                }).toList();
//              },
//            ),
          ],
        ),
          body: DecoratedBox(
              position: DecorationPosition.background,
              decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                    image: AssetImage('assets/images/kalxkimmiekat.png'),
                    fit: BoxFit.fill),
              ),
              child: Card( //new Material(
                  elevation: 0,
                  color: Colors.transparent,
                    child: new Center(
                      child: new Column(
  //                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                        mainAxisSize: MainAxisSize.min,
  //                        crossAxisAlignment: CrossAxisAlignment.center,
  //                        mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            new Card(child: _buildPlayer()),
                          ]),
                    ),
              )
          )
      ),
    );
  }

  Widget _buildPlayer() => new Card(
      child: new Column( children: [
        new Row(mainAxisSize: MainAxisSize.min, children: [
          new IconButton(
              onPressed: isPlaying ? null : () => play(),
              iconSize: 64.0,
              icon: new Icon(Icons.play_arrow),
              color: BUTTON_COLOR),
          new IconButton(
              onPressed: isPlaying ? () => pause() : null,
              iconSize: 64.0,
              icon: new Icon(Icons.pause),
              color: BUTTON_COLOR),
          new IconButton(
              onPressed: isPlaying || isPaused ? () => stop() : null,
              iconSize: 64.0,
              icon: new Icon(Icons.stop),
              color: BUTTON_COLOR),
          new IconButton(                               //make this one button
              onPressed: () => mute(true),
              icon: new Icon(Icons.headset_off),
              color: BUTTON_COLOR),
          new IconButton(
              onPressed: () => mute(false),
              icon: new Icon(Icons.headset),
              color: BUTTON_COLOR),
        ]),
      ]));
}
