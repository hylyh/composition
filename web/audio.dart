import 'dart:web_audio' as audio;
import 'dart:html' as html;
import 'dart:typed_data' as data;

import 'package:path/path.dart' as path;

audio.AudioContext context;
String baseUrl = './audio/';

Map<String, audio.AudioBuffer> bufferSources = new Map();

initAudio() async {
  context = new audio.AudioContext();

  // Load audio files
  var req = await html.HttpRequest.request(
      path.join(baseUrl, 'SFX_StarNoise_Loud_01.ogg'),
      responseType: 'arraybuffer');

  var buffer = req.response as data.ByteBuffer;
  var audioBuffer = await context.decodeAudioData(buffer);

  bufferSources['1'] = audioBuffer;
}

audio.AudioBufferSourceNode createSourceBuffer() {
  var source = context.createBufferSource();
  return source
    ..connectNode(context.destination)
    ..onEnded.first.whenComplete(() => source.disconnect(context.destination));
}

play() async {
  createSourceBuffer()
    ..buffer = bufferSources['1']
    ..start(context.currentTime);
}
