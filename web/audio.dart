import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data' as data;
import 'dart:web_audio' as audio;

import 'package:path/path.dart' as path;

audio.AudioContext context;
String baseUrl = './audio/';

int numTracks = 25;
int startTrack = 1;

List<audio.AudioBuffer> wordBuffers;
List<audio.AudioBuffer> sentenceBuffers;

loadBuffers() async {
  List<String> wordTrackNames;
  {
    // Cheat a bit and make this a seperate block to use the variable i twice
    int i = startTrack;
    wordTrackNames = new List<String>(numTracks)
        .map((_) => 'WordPing${i++}.ogg');
  }

  List<String> sentenceTrackNames;
  {
    // Same as above
    int i = startTrack;
    sentenceTrackNames = new List<String>(numTracks)
        .map((_) => 'SentPad${i++}.ogg');
  }

  var loadTracks = (names) => Future.wait(names.map((name) async {
        var req = await html.HttpRequest
            .request(path.join(baseUrl, name), responseType: 'arraybuffer');

        var bytebuffer = req.response as data.ByteBuffer;
        return await context.decodeAudioData(bytebuffer);
      }));

  wordBuffers = await loadTracks(wordTrackNames);
  sentenceBuffers = await loadTracks(sentenceTrackNames);
}

initAudio() async {
  context = new audio.AudioContext();

  loadBuffers();
}

audio.AudioBufferSourceNode createSourceBuffer() {
  var source = context.createBufferSource();
  return source
    ..connectNode(context.destination)
    ..onEnded.first.whenComplete(() => source.disconnect(context.destination));
}

/// Given an arbitrarily large number, modulo it and play a buffer based on it
/// If isWord is true, plays the word sound, if false, plays the sentence sound
play(int num, bool isWord) {
  createSourceBuffer()
    ..buffer = (isWord ? wordBuffers : sentenceBuffers)[num]
    ..start(context.currentTime);
}

/// Deterministically generated an abitrarily fuzzy hash based on the given
/// bigrams
int genAudioHash(List<String> bigrams) {
  var sum = (List<int> nums) => nums.reduce((v, e) => v + e);
  var bigramToInt = (String bigram) => sum(bigram.codeUnits);

  return sum(bigrams.map(bigramToInt)) % numTracks;
}