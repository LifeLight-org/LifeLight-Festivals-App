import 'dart:async';
import 'package:flutter/material.dart';

class Countdown extends StatefulWidget {
  final DateTime targetDate;
  final DateTime showCountdownAfterMessageDate;
  final String afterCountdownMessage;

  const Countdown({
    Key? key,
    required this.targetDate,
    required this.showCountdownAfterMessageDate,
    required this.afterCountdownMessage,
  }) : super(key: key);

  @override
  CountdownState createState() => CountdownState();
}

class CountdownState extends State<Countdown> {
  late Timer _timer;
  Duration _duration = const Duration();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    const Duration oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (timer) {
      setState(() {
        final now = DateTime.now();
        _duration = widget.targetDate.difference(now);
        if (_duration.isNegative) {
          _timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    // Display nothing while loading
    if (_duration == const Duration()) {
      return SizedBox(height: 65.00);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _duration.isNegative &&
                now.isAfter(widget.showCountdownAfterMessageDate)
            ? Text(
                widget.afterCountdownMessage,
                style: TextStyle(
                  fontSize: isTablet ? 36 : 24, // Larger font size on iPad
                  fontWeight: FontWeight.bold,
                ),
              )
            : Text(
                'Days To Go:',
                style: TextStyle(
                  fontSize: isTablet ? 36 : 24, // Larger font size on iPad
                  fontWeight: FontWeight.bold,
                ),
              ),
        const SizedBox(height: 8),
        _duration.isNegative &&
                now.isAfter(widget.showCountdownAfterMessageDate)
            ? const SizedBox.shrink()
            : Text(
                '${_duration.inDays} days ${_duration.inHours.remainder(24)} hours ${_duration.inMinutes.remainder(60)} minutes ${_duration.inSeconds.remainder(60)} seconds',
                style: TextStyle(
                  fontSize: isTablet ? 24 : 16, // Larger font size on iPad
                  fontWeight: FontWeight.bold,
                ),
              ),
      ],
    );
  }
}