import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Player extends StatefulWidget {
  const Player({super.key});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  final player = AudioPlayer();
  bool playing = false;

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() async {
    try {
      final duration = await player.setUrl(
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3');
      print(duration);
    } on PlayerException catch (e) {
      print("Error code: ${e.code}");
      print("Error message: ${e.message}");
    } on PlayerInterruptedException catch (e) {
      print("Connection aborted: ${e.message}");
    } catch (e) {
      print('An error occured: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SlidingUpPanel(
        color: Colors.red,
        minHeight: 70,
        maxHeight: size.height,
        panel: Center(
          child: Container(),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Column(
            children: [
              const SizedBox(
                height: 120,
              ),
              Container(
                height: 290,
                child: Image.network(
                    "https://lh3.googleusercontent.com/BZBfTByEyZo6l74pbQLGQy-7-FTnYrt5UOpJdrUhdgjpbfMC8f60_ZPRkKiC2JE0RPUpp-cW-hYKOfp_4w=w544-h544-l90-rj"),
              ),
              Expanded(child: Container()),
              const Text(
                "Tere Liye",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                textAlign: TextAlign.center,
                "Lata Mangeshkar & Roop Kumar Rathod",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
              ),
              const SizedBox(
                height: 20,
              ),
              Slider(value: 0, onChanged: (val) {}),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_border)),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.skip_previous,
                        size: 30,
                      )),
                  CircleAvatar(
                      radius: 35,
                      child: IconButton(
                          onPressed: () async {
                            try {
                              playing
                                  ? await player.pause()
                                  : await player.play();
                              setState(() {
                                playing = !playing;
                              });
                            } catch (e) {
                              print(e);
                            }
                            print("here");
                          },
                          icon: Icon(
                            playing ? Icons.pause : Icons.play_arrow,
                          ))),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.skip_next,
                        size: 30,
                      )),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.shuffle,
                      )),
                ],
              ),
              const SizedBox(
                height: 90,
              )
            ],
          ),
        ),
      ),
    );
  }
}
