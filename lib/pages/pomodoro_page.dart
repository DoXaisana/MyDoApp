import 'package:flutter/material.dart';

class PomodoroPage extends StatefulWidget {
  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  final Color lightBlue = const Color(0xFFD9ECFA);
  final Color mediumBlue = const Color(0xFF5A7292);

  int pomodoroMinutes = 25;
  int shortBreakMinutes = 5;
  int longBreakMinutes = 15;
  int seconds = 25 * 60;
  bool isRunning = false;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_onTick);
  }

  void _onTick(Duration elapsed) {
    if (isRunning && seconds > 0) {
      setState(() {
        seconds--;
      });
    } else if (seconds == 0) {
      _ticker.stop();
      setState(() {
        isRunning = false;
      });
    }
  }

  String get timerString {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startPause() {
    setState(() {
      isRunning = !isRunning;
      if (isRunning) {
        _ticker.start();
      } else {
        _ticker.stop();
      }
    });
  }

  void _reset() {
    setState(() {
      seconds = pomodoroMinutes * 60;
      isRunning = false;
      _ticker.stop();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mediumBlue,
      appBar: AppBar(
        backgroundColor: lightBlue,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'Pomodoro Focus',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/home', (route) => false);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            tooltip: 'Settings',
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                backgroundColor: Colors.white,
                builder: (context) {
                  int tempPomodoro = pomodoroMinutes;
                  int tempShort = shortBreakMinutes;
                  int tempLong = longBreakMinutes;
                  return StatefulBuilder(
                    builder: (context, setModalState) {
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                margin: EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            Text(
                              'Pomodoro Duration (minutes)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Slider(
                                    value: tempPomodoro.toDouble(),
                                    min: 10,
                                    max: 60,
                                    divisions: 10,
                                    label: tempPomodoro.toString(),
                                    onChanged: (v) => setModalState(
                                      () => tempPomodoro = v.round(),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('${tempPomodoro}m'),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Short Break (minutes)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Slider(
                                    value: tempShort.toDouble(),
                                    min: 3,
                                    max: 15,
                                    divisions: 12,
                                    label: tempShort.toString(),
                                    onChanged: (v) => setModalState(
                                      () => tempShort = v.round(),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('${tempShort}m'),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Long Break (minutes)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Slider(
                                    value: tempLong.toDouble(),
                                    min: 10,
                                    max: 30,
                                    divisions: 10,
                                    label: tempLong.toString(),
                                    onChanged: (v) => setModalState(
                                      () => tempLong = v.round(),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('${tempLong}m'),
                              ],
                            ),
                            SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  textStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    pomodoroMinutes = tempPomodoro;
                                    shortBreakMinutes = tempShort;
                                    longBreakMinutes = tempLong;
                                    seconds = pomodoroMinutes * 60;
                                    isRunning = false;
                                    _ticker.stop();
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: Text('Save'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timerString,
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: mediumBlue,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(isRunning ? 'Pause' : 'Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _startPause,
                  ),
                  SizedBox(width: 24),
                  ElevatedButton.icon(
                    icon: Icon(Icons.refresh),
                    label: Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _reset,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Ticker {
  final void Function(Duration) onTick;
  Duration _elapsed = Duration.zero;
  bool _active = false;
  late final Stopwatch _stopwatch;

  Ticker(this.onTick) {
    _stopwatch = Stopwatch();
  }

  void start() {
    if (_active) return;
    _active = true;
    _stopwatch.start();
    _tick();
  }

  void stop() {
    _active = false;
    _stopwatch.stop();
  }

  void dispose() {
    _active = false;
    _stopwatch.stop();
  }

  Future<void> _tick() async {
    while (_active) {
      await Future.delayed(Duration(seconds: 1));
      if (_active) {
        _elapsed = _stopwatch.elapsed;
        onTick(_elapsed);
      }
    }
  }
}
