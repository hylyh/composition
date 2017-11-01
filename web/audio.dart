import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data' as data;
import 'dart:web_audio' as audio;

import 'package:path/path.dart' as path;

audio.AudioContext context;
String baseUrl = './audio/';

int numTracks = 7;
int track = 1;

List<String> trackNames = new List<String>(numTracks)
    .map((_) => 'SFX_StarNoise_Loud_0${track++}.ogg');

List<audio.AudioBuffer> buffers;

loadBuffers() async {
  buffers = await Future.wait(trackNames.map((name) async {
    var req = await html.HttpRequest
        .request(path.join(baseUrl, name), responseType: 'arraybuffer');

    var bytebuffer = req.response as data.ByteBuffer;
    return await context.decodeAudioData(bytebuffer);
  }));
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
play(int num) {
  createSourceBuffer()
    ..buffer = buffers[num % buffers.length]
    ..start(context.currentTime);
}
