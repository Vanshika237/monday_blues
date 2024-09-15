import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() {
  runApp(const MyApp());
}

const blue = Color(0xFF0071BC);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Monday Blues',
      theme: ThemeData(fontFamily: "NovaSquare"),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  double limit = 0;
  bool hasReachedLimit = false;
  bool hasWon = false;
  bool hasStarted = false;
  double size = 200;

  late AnimationController _controller;
  late Animation<Size> _animation;
  Timer? timer;

  late ConfettiController confettiController;

  final String url = "https://vanshika237.github.io/";

  int tapCount = 0;

  @override
  void initState() {
    confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _animation = Tween<Size>(end: Size(size, size)).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInCirc));
  }

  reset() {
    if (timer != null && timer?.isActive == true) {
      timer?.cancel();
    }
    size = 200;
    tapCount = 0;
    hasReachedLimit = false;
    hasWon = false;
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      size += 5;
      if (size >= limit) {
        timer.cancel();
        hasStarted = false;
        hasReachedLimit = true;
        if (mounted) {
          setState(() {});
        }
      } else {
        _controller.repeat();
      }
    });
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    limit = min(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: ConfettiWidget(
              confettiController: confettiController,
              emissionFrequency: 0.5,
              maxBlastForce: 100,
              numberOfParticles: 20,
              blastDirectionality: BlastDirectionality.explosive,
              blastDirection: 0,
              colors: const [blue],
              minimumSize: const Size(5, 5),
              maximumSize: const Size(10, 10),
            ),
          ),
          Center(
            child: InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                tapCount++;
                size -= 10;
                if (size <= 20) {
                  timer?.cancel();
                  size = 0;
                  hasStarted = false;
                  hasWon = true;
                  confettiController.play();
                  if (mounted) {
                    setState(() {});
                  }
                } else if (size >= limit) {
                  timer?.cancel();
                  hasStarted = false;
                  hasReachedLimit = true;
                  if (mounted) {
                    setState(() {});
                  }
                } else {
                  _controller.repeat();
                }
              },
              child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Container(
                      height: size,
                      width: size,
                      decoration: BoxDecoration(boxShadow: const [
                        BoxShadow(
                            color: Colors.white24,
                            blurRadius: 5,
                            spreadRadius: 2)
                      ], color: blue, borderRadius: BorderRadius.circular(500)),
                    );
                  }),
            ),
          ),
          if (!hasStarted && !hasWon)
            InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                hasStarted = true;
                reset();
              },
              child: Center(
                child: Text(
                  hasReachedLimit ? "PLAY AGAIN" : 'START',
                  style: const TextStyle(color: Colors.white, fontSize: 28),
                ),
              ),
            ),
          if (hasWon || hasReachedLimit)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "You tapped $tapCount times",
                      style: const TextStyle(color: Colors.white, fontSize: 28),
                    ),
                    if (hasWon) const SizedBox(height: 16),
                    if (hasWon)
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          hasStarted = true;
                          reset();
                        },
                        child: const Text(
                          "PLAY AGAIN",
                          style: TextStyle(color: Colors.white, fontSize: 28),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                hasReachedLimit
                    ? "Maybe it's time to take a break?"
                    : hasWon
                        ? "Woohoo! Monday's got nothing on you!"
                        : "Beat the Monday Blues before they beat you!${hasStarted ? "\n(Keep tapping to combat the blues)" : ""}",
                style: const TextStyle(color: Colors.white, fontSize: 36),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
                padding: const EdgeInsets.all(16),
                splashRadius: 16,
                tooltip: "Say Hi!",
                onPressed: () async {
                  try {
                    if (await canLaunchUrlString(url)) {
                      await launchUrlString(url,
                          mode: LaunchMode.platformDefault);
                    } else {
                      throw "Could not launch $url";
                    }
                    // ignore: empty_catches
                  } catch (e) {}
                },
                icon: Icon(Icons.waving_hand_outlined,
                    color: Colors.white.withOpacity(0.5))),
          ),
        ],
      ),
    );
  }
}
