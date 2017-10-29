import 'dart:html' as html;
import 'dart:typed_data' as data;
import 'dart:web_audio' as audio;

import 'package:path/path.dart' as path;

audio.AudioContext context;
String baseUrl = './audio/';

class RegExpToBuffer {
  RegExp regexp;
  audio.AudioBuffer buffer;
  RegExpToBuffer(this.regexp, this.buffer);

  bool matches(String text) => regexp.hasMatch(text);
}

List<RegExpToBuffer> buffers = new List();

initAudio() async {
  context = new audio.AudioContext();

  // Load audio files
  var req = await html.HttpRequest.request(
      path.join(baseUrl, 'SFX_StarNoise_Loud_01.ogg'),
      responseType: 'arraybuffer');

  var buffer = req.response as data.ByteBuffer;
  var audioBuffer = await context.decodeAudioData(buffer);

  buffers.add(
      new RegExpToBuffer(new RegExp(r'hi', caseSensitive: false), audioBuffer));
}

audio.AudioBufferSourceNode createSourceBuffer() {
  var source = context.createBufferSource();
  return source
    ..connectNode(context.destination)
    ..onEnded.first.whenComplete(() => source.disconnect(context.destination));
}

play(String word) async {
  var foundBuffer =
      buffers.firstWhere((buffer) => buffer.matches(word), orElse: () => null);
  if (foundBuffer != null) {
    print(1);
    createSourceBuffer()
      ..buffer = foundBuffer.buffer
      ..start(context.currentTime);
  }
}
