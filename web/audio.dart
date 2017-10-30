import 'dart:html' as html;
import 'dart:typed_data' as data;
import 'dart:web_audio' as audio;

import 'package:path/path.dart' as path;

audio.AudioContext context;
String baseUrl = './audio/';

class RegExpToBuffer {
  String description;
  RegExp regexp;
  String fileName;

  audio.AudioBuffer _buffer;

  RegExpToBuffer(this.description, this.regexp, this.fileName);

  load() async {
    var req = await html.HttpRequest.request(path.join(baseUrl, this.fileName),
        responseType: 'arraybuffer');

    var buffer = req.response as data.ByteBuffer;
    this._buffer = await context.decodeAudioData(buffer);
  }

  bool matches(String text) => regexp.hasMatch(text);

  get loaded => _buffer != null;
  get buffer => _buffer;

  @override
  String toString() => description;
}

List<RegExpToBuffer> buffers = [
  new RegExpToBuffer(
      'First person',
      new RegExp(r"^(i('?m)?|me)$", caseSensitive: false),
      'SFX_StarNoise_Loud_01.ogg'),
  new RegExpToBuffer(
      'Second person',
      new RegExp(r"^(you'?(re?)?)$", caseSensitive: false),
      'SFX_StarNoise_Loud_02.ogg'),
  new RegExpToBuffer(
      'Third person',
      new RegExp(r"^(her?|she|the(y|ir))$", caseSensitive: false),
      'SFX_StarNoise_Loud_04.ogg'),
];

initAudio() async {
  context = new audio.AudioContext();

  // Load audio files
  // There's got to be a better way to do this right? (i.e. not awaiting)
  buffers.forEach((buffer) async => await buffer.load());
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
    print('Matched $foundBuffer');
    createSourceBuffer()
      ..buffer = foundBuffer.buffer
      ..start(context.currentTime);
  }
}
