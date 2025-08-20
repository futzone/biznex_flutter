/*
import 'dart:developer';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class NumberAudioPlayer {
  final AudioPlayer _player = AudioPlayer();
  final String audioFile = "audio/numbers.mp3";

  final Map<String, Map<String, double>> numbers = {
    "1": {"start": 0.0, "end": 0.395},
    "2": {"start": 0.395, "end": 0.950},
    "3": {"start": 0.950, "end": 1.315},
    "4": {"start": 1.315, "end": 1.820},
    "5": {"start": 1.820, "end": 2.360},
    "6": {"start": 2.360, "end": 3.0},
    "7": {"start": 3.0, "end": 3.690},
    "8": {"start": 3.690, "end": 4.500},
    "9": {"start": 4.500, "end": 5.330},
    "10": {"start": 5.330, "end": 5.760}, // For the number 10 itself
    "10_lik": {"start": 5.330, "end": 5.760}, // For "o'n" in 11-19
    "20": {"start": 5.760, "end": 6.530},
    "30": {"start": 6.530, "end": 7.300},
    "40": {"start": 7.300, "end": 7.822},
    "50": {"start": 7.822, "end": 8.553},
    "60": {"start": 8.553, "end": 9.392},
    "70": {"start": 9.392, "end": 10.223},
    "80": {"start": 10.223, "end": 11.0},
    "90": {"start": 11.0, "end": 11.747},
    "hundred": {"start": 11.747, "end": 12.370},
    "100": {"start": 12.370, "end": 13.076},
    "200": {"start": 13.076, "end": 13.951},
    "300": {"start": 13.951, "end": 14.683},
    "400": {"start": 14.683, "end": 15.400},
    "500": {"start": 15.400, "end": 16.223},
    "600": {"start": 16.223, "end": 17.049},
    "700": {"start": 17.049, "end": 18.0},
    "800": {"start": 18.0, "end": 19.0},
    "900": {"start": 19.0, "end": 19.891},
    "thousand": {"start": 19.891, "end": 20.460},
    "1000": {"start": 20.460, "end": 21.154},
    "2000": {"start": 21.154, "end": 21.918},
    "3000": {"start": 21.918, "end": 22.498},
    "4000": {"start": 22.498, "end": 23.082},
    "5000": {"start": 23.082, "end": 23.717},
    "6000": {"start": 23.717, "end": 24.426},
    "7000": {"start": 24.426, "end": 25.205},
    "8000": {"start": 25.205, "end": 26.087},
    "9000": {"start": 26.087, "end": 26.842},
    "10000": {"start": 26.842, "end": 27.437},
    "ready": {"start": 27.437, "end": 29.500}
  };

  Future<void> playNumber(int number, {bool useBot = true, bool useSong = true}) async {
    log('Playing number: $number');
    if (useSong) {
      final bgPlayer = AudioPlayer();
      await bgPlayer.play(AssetSource("audio/mixkit-software-interface-remove-2576.wav"));
      await Future.delayed(const Duration(milliseconds: 500));
      bgPlayer.dispose();
    }

    if (!useBot) return;

    try {
      await _player.setSource(AssetSource(audioFile));
      await _player.setVolume(1.0);
    } catch (e) {
      log('Error setting audio source: $e');
      return;
    }

    List<String> parts = _splitNumber(number);
    if (parts.isEmpty && number != 0) {
      log('Warning: Could not split number $number into parts.');
      if (number == 0 && !numbers.containsKey("0")) parts.add('ready');
    } else if (number != 0 || numbers.containsKey("0")) {
      parts.add('ready');
    }


    log('Audio parts: $parts');

    for (String part in parts) {
      final info = numbers[part];
      if (info == null || info['start'] == null || info['end'] == null) {
        log('Warning: Audio info not found or invalid for part "$part"');
        continue;
      }

      final start = Duration(milliseconds: (info['start']! * 1000).toInt());
      final end = Duration(milliseconds: (info['end']! * 1000).toInt());
      final duration = end - start;

      if (duration <= Duration.zero) {
        log('Warning: Invalid duration (<= 0) for part "$part"');
        continue;
      }

      try {
        if (_player.state == PlayerState.playing) {
          await _player.pause();
        }
        await _player.seek(start);
        await _player.resume();

        await Future.delayed(duration);

        if (part != parts.last) {
          await _player.pause();
          await Future.delayed(const Duration(milliseconds: 50));
        } else {
          await _player.pause();
        }

      } catch (e) {
        log('Error playing part "$part": $e');
        await _player.pause();
      }
    }
  }

  List<String> _splitNumber(int number) {
    List<String> result = [];

    if (number < 0) {
      number = number.abs();
    }

    if (number == 0) {
      if (numbers.containsKey("0")) return ["0"];
      return [];
    }

    if (number >= 1000) {
      if (number % 1000 == 0 && numbers.containsKey(number.toString())) {
        result.add(number.toString());
        number = 0;
      } else {
        int thousandsPart = (number ~/ 1000);
        result.addAll(_splitNumber(thousandsPart));
        result.add('thousand');
        number = number % 1000;
      }
    }

    if (number >= 100) {
      if (number % 100 == 0 && numbers.containsKey(number.toString())) {
        result.add(number.toString());
        number = 0;
      } else {
        int hundredsPart = (number ~/ 100);
        result.add(hundredsPart.toString());
        result.add('hundred');
        number = number % 100;
      }
    }

    if (number >= 20) {
      int tensPart = (number ~/ 10) * 10;
      result.add(tensPart.toString());
      number = number % 10;
    } else if (number >= 11) { // Handle 11 to 19
      result.add("10_lik"); // Add "o'n" part
      number = number % 10; // Get the unit digit (1-9)
      // The unit digit will be added by the next 'if' block
    } else if (number == 10) { // Handle exactly 10
      result.add("10");
      number = 0;
    }

    if (number > 0) {
      result.add(number.toString());
    }

    return result;
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}*/
