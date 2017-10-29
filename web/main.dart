import 'dart:html' as html;

import './audio.dart' as audio;

var punctuation = '.!?,';
var punctuationRegex = new RegExp('[$punctuation]');
var seperatorsRegex =
    new RegExp('[\\s$punctuation]'); // Punctuation plus whitespace

init() {
  // Clear loading indicator and show content as soon as we're running
  html.document
    ..getElementById('loading-indicator').style.setProperty('display', 'none')
    ..getElementById('post-load').style.setProperty('display', 'initial')
    ..getElementById('type').focus();

  audio.initAudio();
}

/// Split the string with the given pattern but keep the characters that
/// are being split on. They keep appended to the split before them.
List<String> splitKeepChars(String text, Pattern splitChars) {
  var split = new List<String>();
  var textList = text.split('');

  var shouldSplit = (String char) => char.contains(splitChars);

  var curRun = ''; // Accumulates chars between splits
  textList.forEach((char) {
    if (shouldSplit(char)) {
      // Keep the char we're splitting on in the previous split
      split.add(curRun + char);
      curRun = '';
    } else {
      // Nothin special, just keep track of it
      curRun += char;
    }
  });

  // Append whatever was left over
  split.add(curRun);

  return split;
}

onSentence(String sentence) {
  print('Sentence: "$sentence"');
}

onWord(String word) {
  print('Word: "$word"');
  audio.play(word);
}

/// Build the html based on what text is entered
///
/// What happens:
///  * All sentences (text ended by a period) get wrapped in
///    <span class="sentence">
String generateHtml(String text) {
  var builtHtml = text;

  var split = splitKeepChars(text, punctuationRegex);
  if (split.length > 1) {
    var last = split[split.length - 1];
    builtHtml = split.getRange(0, split.length - 1).map((t) {
      return '<span class="sentence">' + t;
    }).toList();

    builtHtml.add(last);
    builtHtml = builtHtml.join('</span>');
  }

  return builtHtml;
}

/// Figure out what to do based on the given character
handleChar(String char, String text) {
  print('char: $char');
  print('text: $text');
  if (char.contains(punctuationRegex)) {
    // Punctuation, handle sentence
    var split = text.split(punctuationRegex);

    if (split.length > 0) {
      var lastSentence = split[split.length - 1].trim();

      if (lastSentence.isNotEmpty) {
        onSentence(lastSentence);
      }
    }
  } else if (char.contains(seperatorsRegex)) {
    // Seperater, handle a single word
    var split = text.split(seperatorsRegex);
    print('split: $split');

    if (split.length > 0) {
      var lastWord = split[split.length - 1].trim();

      if (lastWord.isNotEmpty) {
        onWord(lastWord);
      }
    }
  }
}

/// Figure out what was last typed and what to do about it
/// Returns any change to the element text that is required
String handleTyped(String elText, String lastText) {
  if (elText.length > lastText.length) {
    // Iterate over each of the entered in characters (usually but not always
    // just a single character)
    for (var i = 0; i < elText.length - lastText.length; i++) {
      // Get the current charaacter, then all of the text before it
      // This includes any text that was also entered this frame
      var char = elText[lastText.length + i];
      var precedingText = elText.substring(0, lastText.length + i);
      handleChar(char, precedingText);
    }
  } else {
    // Deleted stuff
  }

  // Return it in case anything changed
  return elText;
}

buildOnTypeFunction(html.Element el) {
  var lastText = '';
  return (html.Event e) {
    try {
      el.text = handleTyped(el.text, lastText);
    } catch (e) {
      el.text += ' ERROR: $e';
      print('ERROR: $e');
    }

    el.setInnerHtml(generateHtml(el.text));

    // Set cursor to end of text
    var range = html.document.createRange()
      ..selectNodeContents(el)
      ..collapse(false);
    html.window.getSelection()
      ..removeAllRanges()
      ..addRange(range);

    lastText = el.text;
  };
}

main() {
  init();

  var el = html.document.getElementById('type');
  el.onInput.listen(buildOnTypeFunction(el));
}
